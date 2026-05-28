import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/edu_system_webview_controller.dart';
import '../../core/utils/edu_url_store.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../data/datasources/edu_parser.dart';
import '../utils/import_helper.dart';
import '../widgets/edu_system_selection_dialog.dart';

class ImportSchedulePage extends ConsumerStatefulWidget {
  const ImportSchedulePage({super.key});

  @override
  ConsumerState<ImportSchedulePage> createState() =>
      _ImportSchedulePageState();
}

class _ImportSchedulePageState extends ConsumerState<ImportSchedulePage> {
  EduSystemWebViewController? _eduController;
  final _urlController = TextEditingController();
  final _pasteController = TextEditingController();

  bool get _isWebViewSupported => _eduController != null;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _loadSavedUrl();
  }

  void _initWebView() {
    try {
      _eduController = EduSystemWebViewController.create(
        onStateChanged: () {
          if (mounted) setState(() {});
        },
        onError: (message, {isError = false}) {
          if (mounted) showAppSnackBar(context, message, isError: isError);
        },
      );
    } catch (_) {
      // WebView 不支持的平台（如 Windows/Linux）
      _eduController = null;
    }
  }

  Future<void> _loadSavedUrl() async {
    final url = await EduUrlStore.load();
    if (url != null && mounted) {
      _urlController.text = url;
      _eduController?.loadUrl(url);
    }
  }

  void _navigateToUrl() {
    if (!_isWebViewSupported) return;
    final text = _urlController.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) {
      showAppSnackBar(context, AppStrings.enterValidUrl, isError: true);
      return;
    }
    _eduController!.loadUrl(text);
    EduUrlStore.save(text);
    FocusScope.of(context).unfocus();
  }

  Future<void> _parseSchedule() async {
    final pastedHtml =
        _isWebViewSupported ? null : _pasteController.text.trim();
    if (!_isWebViewSupported && (pastedHtml == null || pastedHtml.isEmpty)) {
      showAppSnackBar(context, '请先粘贴 HTML 源代码', isError: true);
      return;
    }

    try {
      // 第一次尝试：自动识别解析器
      var parsed = await _eduController!.parseSchedule(pastedHtml: pastedHtml);

      if (!mounted) return;

      // 如果自动识别失败（0个课程），让用户手动选择解析器
      if (parsed.isEmpty && pastedHtml != null) {
        final selectedParser = await _showParserSelectionDialog();
        if (selectedParser != null && mounted) {
          // 使用手动选择的解析器重试
          parsed = await _eduController!.parseSchedule(
            pastedHtml: pastedHtml,
            selectedParser: selectedParser,
          );
        }
      }

      if (!mounted) return;

      if (parsed.isEmpty) {
        showAppSnackBar(context, AppStrings.noCoursesFound);
      } else {
        _showImportDialog(parsed);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, '${AppStrings.parseFailed}: $e', isError: true);
      }
    }
  }

  /// 显示解析器选择对话框。
  Future<EduParser?> _showParserSelectionDialog() async {
    final parsers = _eduController!.getAvailableParsers();
    if (parsers.isEmpty) return null;
    return EduSystemSelectionDialog.show(context, parsers);
  }

  void _showImportDialog(List<ParsedCourse> parsedCourses) {
    final uuid = const Uuid();
    // 按课程名称分配颜色：同名课程使用相同颜色，不同名课程尽量不同
    final colorMap = <String, int>{};
    var colorIndex = 0;
    for (final pc in parsedCourses) {
      if (!colorMap.containsKey(pc.name)) {
        colorMap[pc.name] = AppColors
            .presetCourseColors[colorIndex % AppColors.presetCourseColors.length];
        colorIndex++;
      }
    }
    final courses = List.generate(parsedCourses.length, (i) {
      return parsedCourses[i].toCourse(
        id: uuid.v4(),
        color: colorMap[parsedCourses[i].name]!,
      );
    });

    ImportHelper.showChoiceDialogAndImport(
      context: context,
      courseCount: courses.length,
      courses: courses,
      onOverwrite: overwriteImport,
      onNewSchedule: (r, c, scheduleName) async {
        await newScheduleImport(r, c, scheduleName: scheduleName);
      },
      onComplete: () {
        if (mounted) {
          showAppSnackBar(context, AppStrings.importCourseCount(courses.length));
          if (mounted) context.pop();
        }
      },
    );
  }

  @override
  void dispose() {
    _eduController?.dispose();
    _urlController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isParsing = _eduController?.isParsing ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.importFromEdu),
        actions: [
          TextButton.icon(
            onPressed: isParsing ? null : () { Vibrate.light(); _parseSchedule(); },
            icon: const Icon(Icons.download, size: 18),
            label: const Text(AppStrings.fetchSchedule),
          ),
        ],
      ),
      body: _isWebViewSupported
          ? _buildWebViewBody(colorScheme)
          : _buildDesktopBody(colorScheme),
    );
  }

  Widget _buildWebViewBody(ColorScheme colorScheme) {
    final isLoading = _eduController?.isLoading ?? false;
    final isParsing = _eduController?.isParsing ?? false;

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
                    hintText: AppStrings.eduSystemUrlHint,
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
                onPressed: () { Vibrate.light(); _navigateToUrl(); },
                icon: const Icon(Icons.arrow_forward, size: 20),
                style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _eduController!.webView),
              if (isLoading)
                const Center(child: CircularProgressIndicator()),
              if (isParsing)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text(AppStrings.parsing,
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
    final isParsing = _eduController?.isParsing ?? false;

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
                    AppStrings.desktopPasteHint,
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
              labelText: AppStrings.eduUrlSaveLabel,
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
                hintText: AppStrings.pasteHtmlHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          if (isParsing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 4),
                    Text(AppStrings.parsing),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
