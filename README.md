# WakeUp 课程表

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/license-Non--Commercial-red" alt="License">
</p>

一款基于 Flutter 的课程表 App，支持手动添加课程、教务系统导入、多课表管理、周视图展示、数据本地持久化。

> 当前处于 **第二期** 阶段，核心功能已完成，部分细节仍在修复中。

---

## 功能

### 第一期 MVP ✓

- **周视图课表** — 8 列 × 12 行网格，清晰展示每周课程
- **课程管理** — 添加、编辑、删除课程，支持多时间段配置
- **颜色标记** — 8 种预设颜色，课程一目了然
- **周次切换** — 左右箭头切换查看不同周次的课程
- **学期配置** — 设置开学日期和总周数，自动计算当前周
- **数据持久化** — SQLite 本地存储，重启不丢失
- **单双周支持** — 课程可设全周 / 单周 / 双周模式

### 第二期 ✓（进行中）

- **教务系统导入** — 强智教务系统 HTML 解析，WebView 内嵌浏览器抓取课表，支持 URL 持久化；桌面端降级为粘贴 HTML 源代码
- **多课表管理** — 新建、重命名、切换、删除课表，课程按课表分类
- **导出导入** — 课表 JSON 导出到剪贴板 / 粘贴 JSON 导入
- **示例数据** — 首次启动自动填充 5 门示例课程

### 规划中

| 阶段 | 功能 |
|------|------|
| 第三期 | 深色主题、Android 桌面小部件、上课提醒通知 |

---

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x + Dart 3 |
| 状态管理 | Riverpod（`@riverpod` 代码生成） |
| 数据库 | Drift（SQLite），schema v2 |
| 路由 | go_router |
| 序列化 | freezed + json_serializable |
| HTML 解析 | html（强智教务系统课表解析） |
| WebView | webview_flutter（教务系统登录抓取） |
| 文件/分享 | share_plus / file_picker |
| 架构 | Clean Architecture（core → data → domain → presentation） |

---

## 项目结构

```
lib/
├── main.dart                         # 入口，初始化数据库 & ProviderScope
├── app.dart                          # MaterialApp.router，主题 & 路由
├── core/
│   ├── constants/                    # AppColors, AppStrings
│   ├── theme/                        # Material 3 主题
│   └── utils/                        # date_utils, export_utils
├── data/
│   ├── models/                       # freezed 模型: Course, TimeDetail, Schedule
│   ├── datasources/                  # Drift 数据库、示例数据、edu_parser
│   └── repositories/                 # 仓库实现: course, schedule
├── domain/
│   └── repositories/                 # 仓库接口: course, schedule
└── presentation/
    ├── pages/                        # 页面: 周视图、添加/编辑、导入、学期设置
    ├── widgets/                      # 可复用组件
    └── providers/                    # Riverpod Provider: course, semester, schedule
```

---

## 数据模型

```dart
Course {
  String id;              // UUID
  String name;            // 课程名
  String teacher;         // 教师
  String? location;       // 教室（可选）
  int color;              // 背景色
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
  bool isDefault;         // 是否默认课表
  DateTime createdAt;     // 创建时间
}
```

---

## 已知问题（第二期待修）

- `webview_flutter` 仅支持 Android / iOS / macOS，Windows 桌面端使用粘贴 HTML 方式替代
- `retrofit_generator` 与当前 Dart SDK 不兼容，暂时注释；后续网络对接时再启用
- 课表切换弹窗首次点击偶尔仍显示 loading（Provider 预热时机问题）
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

# 生成代码（freezed, drift, riverpod）
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run
```

### 开发

```bash
# 持续代码生成
dart run build_runner watch --delete-conflicting-outputs

# 代码检查
flutter analyze
```

---

## 许可

本仓库仅用于学习与个人用途。未经许可不得商用。
