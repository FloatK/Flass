import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/edu_system_webview_controller.dart';
import '../../core/utils/edu_url_store.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../domain/entities/edu_parser_entities.dart';
import '../../l10n/app_localizations.dart';
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

  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
      showAppSnackBar(context, l10n.enterValidUrl, isError: true);
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
      showAppSnackBar(context, l10n.pasteHtmlFirst, isError: true);
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
        showAppSnackBar(context, l10n.noCoursesFound);
      } else {
        _showImportDialog(parsed);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, '${l10n.parseFailed}: $e', isError: true);
      }
    }
  }

  /// 显示解析器选择对话框。
  Future<EduParser?> _showParserSelectionDialog() async {
    final parsers = _eduController!.getAvailableParsers();
    if (parsers.isEmpty) return null;
    return EduSystemSelectionDialog.show(context, parsers);
  }

  /// 显示导入流程指南对话框
  void _showImportGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, size: 24),
            const SizedBox(width: 8),
            Text(l10n.importGuideTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGuideStep(1, l10n.importGuideStep1Title, l10n.importGuideStep1Desc),
              const SizedBox(height: 16),
              _buildGuideStep(2, l10n.importGuideStep2Title, l10n.importGuideStep2Desc),
              const SizedBox(height: 16),
              _buildGuideStep(3, l10n.importGuideStep3Title, l10n.importGuideStep3Desc),
              const SizedBox(height: 16),
              _buildGuideStep(4, l10n.importGuideStep4Title, l10n.importGuideStep4Desc),
              const SizedBox(height: 16),
              _buildGuideStep(5, l10n.importGuideStep5Title, l10n.importGuideStep5Desc),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.importGuideTip,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () { Vibrate.light(); Navigator.pop(ctx); },
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(int step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
          showAppSnackBar(context, l10n.importCourseCount(courses.length));
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
        title: Text(l10n.importFromEdu),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            tooltip: l10n.importHelpTooltip,
            onPressed: () { Vibrate.light(); _showImportGuide(context); },
          ),
          TextButton.icon(
            onPressed: isParsing ? null : () { Vibrate.light(); _parseSchedule(); },
            icon: const Icon(Icons.download, size: 18),
            label: Text(l10n.fetchSchedule),
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
                    hintText: l10n.eduSystemUrlHint,
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
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text(l10n.parsing,
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
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.desktopPasteHint,
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
              labelText: l10n.eduUrlSaveLabel,
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
                hintText: l10n.pasteHtmlHint,
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
                    Text(l10n.parsing),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
