import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/datasources/edu_parser.dart';
import '../../data/datasources/edu_parser_qz.dart';
import '../providers/course_provider.dart';

const _urlStoreFile = 'edu_url.json';

class ImportSchedulePage extends ConsumerStatefulWidget {
  const ImportSchedulePage({super.key});

  @override
  ConsumerState<ImportSchedulePage> createState() =>
      _ImportSchedulePageState();
}

class _ImportSchedulePageState extends ConsumerState<ImportSchedulePage> {
  WebViewController? _controller;
  final _urlController = TextEditingController();
  final _pasteController = TextEditingController();
  bool _isLoading = true;
  bool _isParsing = false;
  List<ParsedCourse> _parsedCourses = [];
  final Set<int> _selectedIndices = {};
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
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
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
      _selectedIndices.clear();
    });

    try {
      String html;
      if (pastedHtml != null) {
        html = pastedHtml;
      } else {
        final result = await _controller!.runJavaScriptReturningResult(
          'document.documentElement.outerHTML',
        );
        html = (result as String?) ?? '';
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
        _showParseResults();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isParsing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.parseFailed}: $e')),
      );
    }
  }

  void _showParseResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '共 ${_parsedCourses.length} 门课程',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (_selectedIndices.isNotEmpty)
                          FilledButton(
                            onPressed: () async {
                              await _batchSave();
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: Text('导入已选 (${_selectedIndices.length})'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _parsedCourses.length,
                      itemBuilder: (context, index) {
                        final course = _parsedCourses[index];
                        final isSelected =
                            _selectedIndices.contains(index);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (v) {
                            setSheetState(() {
                              setState(() {
                                if (v == true) {
                                  _selectedIndices.add(index);
                                } else {
                                  _selectedIndices.remove(index);
                                }
                              });
                            });
                          },
                          title: Text(course.name),
                          subtitle: Text(
                            '${course.teacher}  ${course.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondary: CircleAvatar(
                            backgroundColor: Color(
                              AppColors.presetCourseColors[index %
                                  AppColors.presetCourseColors.length],
                            ),
                            radius: 16,
                            child: Text(
                              course.name.isNotEmpty ? course.name[0] : '?',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _batchSave() async {
    final notifier = ref.read(courseListProvider.notifier);
    final uuid = const Uuid();
    int saved = 0;

    for (final index in _selectedIndices) {
      final parsed = _parsedCourses[index];
      final course = parsed.toCourse(
        id: uuid.v4(),
        color: AppColors.presetCourseColors[
            index % AppColors.presetCourseColors.length],
      );
      try {
        await notifier.addCourse(course);
        saved++;
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功导入 $saved 门课程')),
      );
      if (mounted) context.pop();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, size: 22),
            SizedBox(width: 8),
            Text('使用说明'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 在上方输入教务系统课表页面的 URL'),
              SizedBox(height: 8),
              Text('2. 在下方浏览器中登录教务系统，进入课表页面'),
              SizedBox(height: 8),
              Text('3. 点击右上角「抓取课表」解析课程'),
              SizedBox(height: 8),
              Text('4. 勾选要导入的课程，点击「导入已选」'),
              SizedBox(height: 12),
              Text(
                '提示：链接会自动保存，下次打开无需重新输入。',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showHelpDialog,
        child: const Icon(Icons.help_outline),
      ),
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
