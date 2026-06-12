# Flass 鸿蒙 (OHOS) 构建指南

## 现状

主应用已使用 **sqflite** 作为跨平台数据库，原生支持 OHOS，无需额外适配。

## 快速开始

```bash
# 1. 复制 OHOS 依赖覆盖（使用 OpenHarmony-SIG 适配的插件）
cp ohos/pubspec_overrides.yaml pubspec_overrides.yaml

# 2. 获取依赖
flutter pub get

# 3. 运行
flutter run -d ohos
```

或使用构建脚本：
```bash
.\build_ohos.ps1          # 调试版
.\build_ohos.ps1 -Release # Release 版
```

## 环境准备

### 1. 安装 DevEco Studio
- 下载：https://developer.huawei.com/consumer/cn/deveco-studio/
- 版本要求：5.0+ (API 12+)

### 2. 安装 Flutter OHOS SDK
```bash
git clone https://gitee.com/openharmony-sig/flutter.git -b oh-3.27.4
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor
```

### 3. 配置鸿蒙开发环境
```bash
export OHOS_SDK_PATH="/path/to/HarmonyOS-SDK"
```

## 依赖说明

`pubspec_overrides.yaml` 使用 OpenHarmony-SIG 适配的插件版本：

| 依赖 | 来源 |
|------|------|
| sqflite | openharmony-sig/flutter_sqflite |
| shared_preferences | openharmony-sig/flutter_packages |
| path_provider | openharmony-sig/flutter_packages |
| url_launcher | openharmony-sig/flutter_packages |
| share_plus | openharmony-sig/flutter_packages |
| file_picker | openharmony-sig/flutter_packages |
| webview_flutter | openharmony-tpc/flutter_packages |

## 构建命令

```bash
# 调试版
flutter run -d ohos

# Release 版
flutter build hap --release

# 安装到设备
flutter install
```

## 已知问题

1. **WebView 行为差异** — webview_flutter OHOS fork 可能有 JS 注入、Cookie 等行为差异，需实际测试
2. **振动反馈** — HapticFeedback.lightImpact() 在鸿蒙设备上可能不支持，已静默处理
3. **文件分享样式** — share_plus OHOS fork 的分享 Sheet 可能与 Android/iOS 不同

## 测试清单

- [ ] App 启动正常
- [ ] 课表显示正常
- [ ] 添加/编辑/删除课程
- [ ] 切换课表
- [ ] 设置页面功能
- [ ] 文本导入课表
- [ ] 导出分享功能
- [ ] 教务系统导入（WebView）
- [ ] 振动反馈
- [ ] 主题切换
- [ ] 周次切换

## 回滚方案

如需切换回常规构建：
```bash
rm pubspec_overrides.yaml
flutter pub get
```

## 参考资料

- [Flutter OHOS 官方仓库](https://gitee.com/openharmony-sig/flutter)
- [OpenHarmony-SIG Flutter Packages](https://gitee.com/openharmony-sig/flutter_packages)
- [Flutter 鸿蒙开发者文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/flutter-dev-V5)
