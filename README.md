# WakeUp 课程表

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/license-Non--Commercial-red" alt="License">
</p>

一款基于 Flutter 的跨平台课程表 App。支持教务系统导入、紧凑码分享、多课表管理、主题自定义、周视图展示，数据全量本地持久化。

---

## 功能

### ✓ 已完成

| 模块 | 功能 |
|------|------|
| **周视图课表** | 8 列 × 12 行网格，左右滑动切换周次，自动定位当前周，「回到本周」按钮，日期范围标注 |
| **课程管理** | 添加、编辑、删除课程，支持多时间段（跨天/多周次），单双周全周模式，预设颜色标记 |
| **教务系统导入** | 强智教务系统 HTML 解析，WebView 内嵌浏览器登录抓取，支持 URL 持久化；桌面端降级为粘贴 HTML 源代码 |
| **文本导入** | 支持紧凑码和 JSON 两种格式粘贴导入，自动识别格式 |
| **紧凑码分享** | 短键 JSON → GZip → base64Url 压缩编码，单行复制分享，支持从聊天消息提取导入 |
| **多课表管理** | 创建、重命名、切换、删除课表，课程按课表隔离 |
| **主题自定义** | 深色/亮色模式切换 + 主题色选择板 + 课程块圆角/高度/间距滑块 + 颜色明度调节；滑块拖拽时防 ScrollView 跳位 |
| **AppBar 自定义** | 最多 4 个自定义快捷按钮，持久化记忆 |
| **学期配置** | 开学日期 + 总周数设置，自动计算当前周，无课表时自动填充示例数据 |

### 📋 规划中

- Android 桌面小部件
- 上课提醒通知
---

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x + Dart 3 |
| 状态管理 | Riverpod（`@riverpod` 代码生成） |
| 数据库 | Drift（SQLite），schema v2 |
| 路由 | go_router |
| 序列化 | freezed + json_serializable |
| HTML 解析 | 强智教务系统课表解析 |
| WebView | webview_flutter（教务系统登录抓取） |
| 持久化偏好 | SharedPreferences（主题、AppBar 配置） |
| 文件/分享 | share_plus / file_picker |
| 架构 | Clean Architecture（core → data → domain → presentation） |

---

## 项目结构

```
lib/
├── main.dart                         # 入口，初始化数据库 & ProviderScope
├── app.dart                          # MaterialApp.router，主题 & 路由
├── core/
│   ├── config/                       # ActionItem 枚举，AppBarConfig 持久化
│   ├── constants/                    # AppColors, AppStrings
│   ├── theme/                        # Material 3 主题构建
│   └── utils/                        # date_utils, export_utils
├── data/
│   ├── models/                       # freezed 模型: Course, TimeDetail, Schedule
│   ├── datasources/                  # Drift 数据库、示例数据、edu_parser
│   └── repositories/                 # 仓库实现: course, schedule
├── domain/
│   └── repositories/                 # 仓库接口
└── presentation/
    ├── pages/                        # 周视图、添加/编辑、教务导入、课表列表/编辑
    ├── widgets/                      # 课程块、主题弹窗、浮窗、学期配置
    ├── utils/                        # import_helper（共享导入逻辑）
    └── providers/                    # Riverpod Provider: course, schedule, semester, theme
```

---

## 数据模型

```dart
Course {
  String id;              // UUID
  String name;            // 课程名
  String teacher;         // 教师
  String? location;       // 教室（可选）
  int color;              // 背景色 ARGB int（现可通过主题色明度调节联动）
  List<TimeDetail> timeDetails;  // 时间段列表
}

TimeDetail {
  int dayOfWeek;          // 1=周一, 7=周日
  int startPeriod;        // 起始节次 1-12
  int duration;           // 持续节数 1-3
  List<int> weeks;        // 上课周次
  String singleOrDouble;  // 'all' | 'single' | 'double'
}

Schedule {
  String id;              // UUID
  String name;            // 课表名称
  DateTime createdAt;     // 创建时间
  DateTime? semesterStart;   // 学期开学日期
  int? totalWeeks;        // 总周数
  int? maxCoursesPerDay;  // 每日最大课程数
  int? displayedWeekdays; // 显示周天数
}
```

---

## 紧凑码格式

用于课表分享的压缩编码格式：

```
原数据 → 短键 JSON → GZip 压缩 → base64Url 编码 → 「 内嵌 」

示例：
将该条消息复制，点击从文本导入即可导入课表。
「H4sIAAAA...w==」
```

### 特点
- URL 安全，无特殊字符
- 单行文本，方便复制粘贴
- 可嵌入聊天消息（用 `「…」` 包裹）
- 导入时自动提取编码内容解码

---

## 已知问题

- `webview_flutter` 仅支持 Android / iOS / macOS，Windows暂无支持计划（以后应该也不会支持）
- 教务导入在不同学校的强智系统版本间可能存在 HTML 结构差异

---

## 快速开始

### 环境要求

- Flutter 3.x
- Dart 3.x
- Windows / macOS / Linux / Android / iOS

### 运行

```bash
# 安装依赖
flutter pub get
# 运行
flutter run
```

### 开发

```bash
# 代码检查
flutter analyze
```

---

## 许可

本仓库仅用于学习与个人用途。未经许可不得商用。
