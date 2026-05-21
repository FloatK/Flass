import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/schedule_webview_helper.dart';
import '../../data/datasources/database.dart' hide Course, TimeDetail, Schedule;
import '../../data/datasources/edu_parser.dart';
import '../../data/datasources/edu_parser_qz.dart';
import '../../data/models/course.dart';
import '../providers/semester_provider.dart';
import '../utils/import_helper.dart';

const _urlStoreFile = 'edu_url.json';

class ImportSchedulePage extends ConsumerStatefulWidget {
  const ImportSchedulePage({super.key});

  @override
  ConsumerState<ImportSchedulePage> createState() =>
      _ImportSchedulePageState();
}

class _ImportSchedulePageState extends ConsumerState<ImportSchedulePage> {
  WebViewController? _controller;
  ScheduleWebViewHelper? _webViewHelper;
  final _urlController = TextEditingController();
  final _pasteController = TextEditingController();
  bool _isLoading = false;
  bool _isParsing = false;
  List<ParsedCourse> _parsedCourses = [];
  final EduParser _parser = const QiangZhiEduParser();

  bool get _isWebViewSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    if (_isWebViewSupported) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        )
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) async {
            if (mounted) setState(() => _isLoading = false);
            await _webViewHelper?.detectAndRedirect();
          },
          onWebResourceError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${AppStrings.loadFailed}: ${error.description}'),
                ),
              );
            }
          },
        ));
    _webViewHelper = ScheduleWebViewHelper(_controller!);
    }
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_urlStoreFile');
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        final url = data['url'] as String?;
        if (url != null && url.isNotEmpty) {
          _urlController.text = url;
          // Auto-navigate to saved URL
          final uri = Uri.tryParse(url);
          if (uri != null && uri.hasScheme) {
            _controller?.loadRequest(uri);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _saveUrl(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_urlStoreFile');
      await file.writeAsString(jsonEncode({'url': url}));
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.clearCache();
    _urlController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  void _navigateToUrl() {
    if (!_isWebViewSupported) return;
    final text = _urlController.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的 URL（如 http://...）')),
      );
      return;
    }
    _controller!.loadRequest(uri);
    _saveUrl(text);
    FocusScope.of(context).unfocus();
  }

  Future<void> _parseSchedule([String? pastedHtml]) async {
    setState(() {
      _isParsing = true;
      _parsedCourses = [];
    });

    try {
      String html = '';
      if (pastedHtml != null) {
        html = pastedHtml;
      } else {
        final extracted = await _webViewHelper?.extractScheduleHtml(
              maxAttempts: 8,
              interval: const Duration(milliseconds: 500),
            );
        html = extracted ?? '';
      }

      final courses = _parser.parse(html);

      if (!mounted) return;
      setState(() {
        _parsedCourses = courses;
        _isParsing = false;
      });

      if (courses.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到课程数据，请确认已登录并进入课表页面')),
        );
      } else if (courses.isNotEmpty) {
        _showImportChoiceDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isParsing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.parseFailed}: $e')),
      );
    }
  }

  void _showImportChoiceDialog() {
    final courseList = _buildCourseList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('共 ${courseList.length} 门课程'),
        content: const Text('选择导入方式：'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showImportConfig('overwrite', courseList);
            },
            child: const Text('覆盖当前课表'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showImportConfig('new', courseList);
            },
            child: const Text('新建课表并导入'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  List<Course> _buildCourseList() {
    final uuid = const Uuid();
    return List.generate(_parsedCourses.length, (i) {
      return _parsedCourses[i].toCourse(
        id: uuid.v4(),
        color: AppColors.presetCourseColors[
            i % AppColors.presetCourseColors.length],
      );
    });
  }

  void _showImportConfig(String mode, List<Course> courses) {
    final currentSemester = ref.read(activeSemesterProvider).valueOrNull;
    final initialDate = currentSemester?.startDate.isNotEmpty == true
        ? (DateTime.tryParse(currentSemester!.startDate.substring(0, 10)) ??
            DateTime.now())
        : DateTime.now();
    final dateCtrl =
        TextEditingController(text: initialDate.toIso8601String().substring(0, 10));
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(mode == 'overwrite' ? '覆盖当前课表' : '新建课表'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '开学日期',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.parse(dateCtrl.text),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  dateCtrl.text = date.toIso8601String().substring(0, 10);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: '课表名称',
                hintText: mode == 'overwrite'
                    ? '留空则保留当前名称'
                    : '留空则自动生成',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Update semester config with chosen start date
              final semester = ref.read(activeSemesterProvider).valueOrNull;
              await ref.read(activeSemesterProvider.notifier).setConfig(
                    SemesterConfigsCompanion(
                      name: drift.Value(semester?.name ?? '默认学期'),
                      startDate: drift.Value('${dateCtrl.text}T00:00:00'),
                      totalWeeks: drift.Value(semester?.totalWeeks ?? 20),
                    ),
                  );

              if (mode == 'overwrite') {
                await overwriteImport(ref, courses);
              } else {
                final scheduleName = nameCtrl.text.trim();
                await newScheduleImport(ref, courses,
                    scheduleName: scheduleName.isNotEmpty ? scheduleName : null);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('成功导入 ${courses.length} 门课程')),
                );
                if (mounted) context.pop();
              }
            },
            child: const Text('确认导入'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('从教务系统导入'),
        actions: [
          TextButton.icon(
            onPressed: _isParsing
                ? null
                : () => _isWebViewSupported
                    ? _parseSchedule()
                    : _parseSchedule(_pasteController.text),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('抓取课表'),
          ),
        ],
      ),
      body: _isWebViewSupported ? _buildWebViewBody(colorScheme) : _buildDesktopBody(colorScheme),
    );
  }

  Widget _buildWebViewBody(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: '教务系统课表页面 URL',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  style: const TextStyle(fontSize: 13),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _navigateToUrl(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _navigateToUrl,
                icon: const Icon(Icons.arrow_forward, size: 20),
                style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller!),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              if (_isParsing)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text('解析中...',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withAlpha(100)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '桌面端暂不支持内置浏览器。请在系统浏览器中打开教务系统页面，查看网页源代码并粘贴到下方。',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: '教务系统 URL（用于保存）',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _pasteController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: '在此粘贴教务系统课表页面的 HTML 源代码\n\n步骤：\n1. 在浏览器中打开教务系统并进入课表页面\n2. 右键 → 查看网页源代码（或 Ctrl+U）\n3. 全选复制 → 粘贴到这里\n4. 点击右上角「抓取课表」',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          if (_isParsing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 4),
                    Text('解析中...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
