// =============================================================================
// Flass 平台检测工具
//
// 此文件提供平台检测功能，用于在不同平台上使用不同的实现
// =============================================================================

import 'dart:io';

/// 平台类型枚举
enum FlassPlatform {
  android,
  ios,
  windows,
  linux,
  macos,
  ohos,
  unknown,
}

/// 平台检测工具类
class PlatformUtils {
  PlatformUtils._();
  
  /// 获取当前平台
  static FlassPlatform get currentPlatform {
    if (Platform.isAndroid) return FlassPlatform.android;
    if (Platform.isIOS) return FlassPlatform.ios;
    if (Platform.isWindows) return FlassPlatform.windows;
    if (Platform.isLinux) return FlassPlatform.linux;
    if (Platform.isMacOS) return FlassPlatform.macos;
    
    // 鸿蒙系统检测
    // 注意：Platform.operatingSystem 在鸿蒙上可能返回 'android' 或 'ohos'
    // 需要根据实际情况调整
    if (Platform.operatingSystem == 'ohos') return FlassPlatform.ohos;
    
    return FlassPlatform.unknown;
  }
  
  /// 是否是鸿蒙平台
  static bool get isOhos => currentPlatform == FlassPlatform.ohos;
  
  /// 是否是移动平台（Android/iOS/鸿蒙）
  static bool get isMobile {
    return currentPlatform == FlassPlatform.android ||
           currentPlatform == FlassPlatform.ios ||
           currentPlatform == FlassPlatform.ohos;
  }
  
  /// 是否是桌面平台（Windows/Linux/macOS）
  static bool get isDesktop {
    return currentPlatform == FlassPlatform.windows ||
           currentPlatform == FlassPlatform.linux ||
           currentPlatform == FlassPlatform.macos;
  }
  
  /// 是否支持 WebView
  static bool get supportsWebView {
    // 鸿蒙平台支持 WebView，但需要使用专用 fork
    return currentPlatform == FlassPlatform.android ||
           currentPlatform == FlassPlatform.ios ||
           currentPlatform == FlassPlatform.ohos;
  }
  
  /// 是否支持文件选择器
  static bool get supportsFilePicker {
    return currentPlatform != FlassPlatform.unknown;
  }
  
  /// 是否支持分享功能
  static bool get supportsShare {
    return currentPlatform != FlassPlatform.unknown;
  }
  
  /// 是否支持振动反馈
  static bool get supportsHaptics {
    // 鸿蒙设备可能不支持 HapticFeedback
    // 需要实际测试
    return currentPlatform == FlassPlatform.android ||
           currentPlatform == FlassPlatform.ios;
  }
  
  /// 获取平台名称
  static String get platformName {
    switch (currentPlatform) {
      case FlassPlatform.android:
        return 'Android';
      case FlassPlatform.ios:
        return 'iOS';
      case FlassPlatform.windows:
        return 'Windows';
      case FlassPlatform.linux:
        return 'Linux';
      case FlassPlatform.macos:
        return 'macOS';
      case FlassPlatform.ohos:
        return 'HarmonyOS';
      case FlassPlatform.unknown:
        return 'Unknown';
    }
  }
  
  /// 获取数据库实现类型
  /// 
  /// 返回值：
  /// - 'drift': 使用 Drift ORM (Android/iOS/桌面)
  /// - 'sqflite': 使用 sqflite (鸿蒙)
  static String get databaseType {
    if (isOhos) return 'sqflite';
    return 'drift';
  }
}
