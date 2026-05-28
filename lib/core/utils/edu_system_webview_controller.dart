import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/datasources/edu_parser.dart';
import '../../data/datasources/edu_parser_qg.dart';
import '../../data/datasources/edu_parser_qz.dart';
import '../../data/datasources/edu_parser_zf.dart';
import 'schedule_webview_helper.dart';

/// 教务系统 WebView 控制器，封装 WebView 初始化、状态管理和 HTML 解析。
class EduSystemWebViewController {
  final WebViewController webView;
  final ScheduleWebViewHelper helper;

  bool _isLoading = false;
  bool _isParsing = false;
  List<ParsedCourse> _parsedCourses = [];

  bool get isLoading => _isLoading;
  bool get isParsing => _isParsing;
  List<ParsedCourse> get parsedCourses => _parsedCourses;

  VoidCallback? _onStateChanged;

  EduSystemWebViewController._({
    required this.webView,
    required this.helper,
  });

  /// 初始化解析器注册表（应用启动时调用一次）。
  static void initParserRegistry() {
    final registry = EduParserRegistry.instance;
    // 避免重复注册
    if (registry.getAll().isEmpty) {
      registry.register(const QiangZhiEduParser());
      registry.register(const ZhengFangEduParser());
      registry.register(const QingGuoEduParser());
    }
  }

  /// 创建控制器。[onStateChanged] 会在状态变化时被调用，用于触发 UI 刷新。
  factory EduSystemWebViewController.create({
    required VoidCallback onStateChanged,
    required void Function(String message, {bool isError}) onError,
  }) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      );

    final helper = ScheduleWebViewHelper(controller);
    final instance = EduSystemWebViewController._(
      webView: controller,
      helper: helper,
    );
    instance._onStateChanged = onStateChanged;

    controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (_) {
        instance._isLoading = true;
        onStateChanged();
      },
      onPageFinished: (_) async {
        instance._isLoading = false;
        onStateChanged();
        await helper.detectAndRedirect();
      },
      onWebResourceError: (error) {
        onError('加载失败: ${error.description}', isError: true);
      },
    ));

    return instance;
  }

  /// 加载指定 URL。
  void loadUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      webView.loadRequest(uri);
    }
  }

  /// 从 WebView 或粘贴的 HTML 解析课程。
  ///
  /// [pastedHtml]：粘贴的 HTML 源代码（桌面端）。
  /// [selectedParser]：手动选择的解析器（优先使用）。
  ///
  /// 返回解析出的课程列表，若无课程则返回空列表。
  Future<List<ParsedCourse>> parseSchedule({
    String? pastedHtml,
    EduParser? selectedParser,
  }) async {
    _isParsing = true;
    _parsedCourses = [];
    _onStateChanged?.call();

    try {
      String html;
      if (pastedHtml != null) {
        html = pastedHtml;
      } else {
        html = await helper.extractScheduleHtml(
              maxAttempts: 8,
              interval: const Duration(milliseconds: 500),
            ) ??
            '';
      }

      if (html.isEmpty) {
        _isParsing = false;
        _onStateChanged?.call();
        return [];
      }

      // 选择解析器：手动选择 > 自动识别 > 默认（强智）
      EduParser parser;
      if (selectedParser != null) {
        parser = selectedParser;
      } else {
        parser = EduParserRegistry.instance.detectFromHtml(html) ??
            const QiangZhiEduParser();
      }

      _parsedCourses = parser.parse(html);
      _isParsing = false;
      _onStateChanged?.call();
      return _parsedCourses;
    } catch (e) {
      _isParsing = false;
      _onStateChanged?.call();
      rethrow;
    }
  }

  /// 获取当前可用的解析器列表。
  List<EduParser> getAvailableParsers() {
    return EduParserRegistry.instance.getAll();
  }

  void dispose() {
    webView.clearCache();
  }
}
