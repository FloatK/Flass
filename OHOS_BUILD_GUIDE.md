# Flass 鸿蒙 (OHOS) 构建指南

## 前置条件

### 1. 安装 DevEco Studio 5.0+

下载地址：https://developer.huawei.com/consumer/cn/deveco-studio/

### 2. 安装 Flutter OHOS SDK

```bash
# 克隆 Flutter OHOS 分支
git clone https://gitee.com/openharmony-sig/flutter.git -b oh-3.27.4

# 设置环境变量
export PATH="$PATH:/path/to/flutter/bin"

# 验证
flutter doctor
```

### 3. 配置鸿蒙开发环境

```bash
# 设置 OHOS SDK 路径
export OHOS_SDK_PATH="/path/to/HarmonyOS-SDK"

# 验证
flutter doctor -v
```

---

## 构建步骤

### 方法一：使用构建脚本（推荐）

```bash
# 运行调试版
.\build_ohos.ps1

# 构建 Release 版
.\build_ohos.ps1 -Release

# 清理后构建
.\build_ohos.ps1 -Clean -Release
```

### 方法二：手动构建

```bash
# 1. 确保 pubspec_overrides.yaml 存在
# 这个文件已经包含在项目中，包含 OHOS 专用依赖配置

# 2. 获取依赖
flutter pub get

# 3. 运行调试版
flutter run -d ohos

# 4. 构建 Release 版
flutter build hap --release
```

---

## 切换回常规平台

当需要构建 Android/iOS/Windows/Linux/macOS 版本时：

```bash
# 使用常规构建脚本
.\build_regular.ps1

# 或手动操作：
# 1. 临时重命名 pubspec_overrides.yaml
mv pubspec_overrides.yaml pubspec_overrides.yaml.ohos

# 2. 获取依赖
flutter pub get

# 3. 运行
flutter run
```

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `pubspec_overrides.yaml` | OHOS 专用依赖覆盖配置 |
| `build_ohos.ps1` | 鸿蒙构建脚本 |
| `build_regular.ps1` | 常规平台构建脚本 |
| `OHOS_BUILD_GUIDE.md` | 本文档 |

---

## 依赖说明

| 包名 | 常规版本 | OHOS 版本 | 说明 |
|------|---------|-----------|------|
| sqflite | pub.dev | OpenHarmony-SIG | SQLite 数据库 |
| shared_preferences | pub.dev | OpenHarmony-SIG | 键值存储 |
| path_provider | pub.dev | OpenHarmony-SIG | 文件路径 |
| url_launcher | pub.dev | OpenHarmony-SIG | 链接打开 |
| share_plus | pub.dev | OpenHarmony-SIG | 分享功能 |
| file_picker | pub.dev | OpenHarmony-SIG | 文件选择 |
| webview_flutter | pub.dev | openharmony-tpc | WebView |

---

## 常见问题

### Q: 找不到 Flutter OHOS 命令

A: 确保已正确安装 Flutter OHOS SDK 并设置环境变量。

### Q: 依赖获取失败

A: 检查网络连接，确保可以访问 Gitee 和 GitCode。

### Q: 构建失败

A: 尝试清理构建缓存：
```bash
flutter clean
flutter pub get
flutter build hap --release
```

### Q: 如何在真机上调试

A: 连接鸿蒙设备后运行：
```bash
flutter run -d ohos
```

---

## 注意事项

1. **首次构建**：OHOS 首次构建可能需要较长时间，请耐心等待
2. **签名配置**：Release 版本需要配置签名信息
3. **权限申请**：某些功能可能需要在 `module.json5` 中申请权限
4. **数据迁移**：从 Android/iOS 迁移时，数据库会自动创建，旧数据不会迁移
