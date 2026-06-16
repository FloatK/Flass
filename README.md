# Flass — Flutter 课表 App

一个轻量、美观、可高度自定义的课程表应用，使用 Flutter + sqflite + Riverpod 构建。

## 功能

### 课表展示
- 按周展示课程表，支持左滑右滑切换周次
- 课程块支持圆角、高度、间距自定义
- 点击课程弹出详情底部面板
- 深色模式自动压暗课程颜色
- AppBar 弹出菜单（可配置的工具栏按钮网格）

### 课程管理
- 添加/编辑/删除课程
- 每个课程支持多个时间段（不同日期、不同节次）
- 选择/全选/单周/双周上课周次
- 课程颜色选择器（8 种预设色）
- 调课功能：将课程移动到指定日期
- 同名课程颜色批量同步

### 课表管理
- 多课表支持（创建、重命名、删除、切换）
- 默认课表机制
- 每个课表独立设置显示天数、每日最大课程数、开学日期、总周数
- 切换课表自动恢复上次使用的课表

### 导入功能
- **教务系统导入**：内置 WebView 访问教务系统，抓取课表页面自动解析（支持强智、正方、青果）
- **文本导入**：粘贴紧凑码，一键导入课表
- **HTML 导入**：桌面端支持粘贴 HTML 源代码解析
- 导入时支持「覆盖当前课表」或「新建课表并导入」
- 导入流程分步引导（含帮助按钮）

### 导出 & 分享
- 紧凑码编码：课表数据 → 短键 JSON → GZip → base64Url 单行文本
- 复制到剪贴板或分享文件
- 可插拔导入/导出格式注册机制（FormatRegistry）

### 主题设置
- 跟随系统深色模式 / 手动切换亮暗
- 8 种主题色
- 课程圆角半径、课程块高度、课程间距、列间距
- 颜色深浅调节（HSL 亮度因子 0.5–1.8）
- 课表底板背景色跟随主题色
- 可配置 AppBar 工具栏按钮顺序（拖拽排序）

### 交互反馈
- 点击课程振动反馈（可关闭）

### 跨平台 + 鸿蒙
- 支持 Android、iOS、Windows、Linux、macOS
- 支持 HarmonyOS（通过 OpenHarmony-SIG 适配）

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter + Material 3 |
| 状态管理 | Riverpod 2.x（riverpod_generator） |
| 数据库 | sqflite（DAO 模式：CourseDao、ScheduleDao、SemesterConfigDao） |
| 路由 | go\_router |
| 代码生成 | freezed（数据类）、json\_serializable、riverpod\_generator |
| 本地化 | flutter\_localizations，仅简体中文（l10n/app\_zh.arb） |
| 网络 | dio + retrofit（教务 API）、webview\_flutter |
| 存储 | SharedPreferences（AppBar 配置持久化） |
| 其他 | uuid、share\_plus、path\_provider、html 解析 |

## 项目结构

```
lib/
├── app.dart                          # MaterialApp.router（GoRouter + 主题 + 本地化）
├── main.dart                         # 入口：DB 初始化、ProviderScope
├── core/
│   ├── config/                       # app_bar_config（持久化）、action_item（注册表）
│   ├── constants/                    # AppColors 常量
│   ├── theme/                        # ThemeData 构建（buildTheme）
│   └── utils/                        # 公共工具类
│       ├── export_utils.dart         # 紧凑码编解码
│       ├── import_utils.dart         # 导入解析
│       ├── format_registry.dart      # 可插拔导入/导出格式注册
│       ├── ui_utils.dart             # SnackBar 等 UI 工具
│       ├── week_utils.dart           # 周次解析
│       ├── date_utils.dart           # 日期工具
│       ├── l10n_utils.dart           # 星期标签助手
│       ├── vibrate.dart              # 振动控制
│       ├── edu_system_webview_controller.dart  # 教务 WebView 控制器
│       ├── schedule_webview_helper.dart       # 课表 WebView 集成
│       └── edu_url_store.dart        # 教务 URL 持久化
├── data/
│   ├── datasources/
│   │   ├── database.dart             # sqflite 数据库定义 + 迁移
│   │   ├── course_dao.dart           # 课程 DAO（含 JOIN 查询）
│   │   ├── schedule_dao.dart         # 课表 DAO
│   │   ├── semester_config_dao.dart  # 学期配置 DAO
│   │   ├── edu_parser.dart           # 课表 HTML 解析接口
│   │   ├── edu_parser_mixin.dart     # 解析器共享逻辑
│   │   ├── edu_parser_qz.dart        # 强智教务系统解析
│   │   ├── edu_parser_zf.dart        # 正方教务系统解析
│   │   ├── edu_parser_qg.dart        # 青果教务系统解析
│   │   └── sample_data.dart          # 示例数据
│   ├── models/
│   │   ├── course.dart               # Course（freezed，含 metadata 字段）
│   │   ├── schedule.dart             # Schedule（freezed）
│   │   ├── schedule_data.dart        # ScheduleData（freezed）
│   │   ├── semester_config.dart      # SemesterConfig（freezed）
│   │   ├── theme_settings.dart       # ThemeSettings（freezed，JSON 持久化）
│   │   └── time_detail.dart          # TimeDetail（freezed）
│   └── repositories/                 # 仓库实现（bridging DAO → domain 接口）
│       ├── course_repository_impl.dart
│       └── schedule_repository_impl.dart
├── domain/
│   ├── entities/                     # 跨层 re-export（data models → domain）
│   │   ├── course_entities.dart
│   │   ├── schedule_entities.dart
│   │   ├── database_entities.dart
│   │   └── edu_parser_entities.dart
│   └── repositories/                 # 仓库接口（Clean Architecture 边界）
│       ├── course_repository.dart
│       ├── schedule_repository.dart
│       └── crud_repository.dart       # 通用 CRUD 接口
├── presentation/
│   ├── pages/                        # 页面
│   │   ├── week_schedule_page.dart    # 主课表页面（PageView 周次切换）
│   │   ├── import_schedule_page.dart  # 教务导入页面（含分步引导帮助）
│   │   ├── add_edit_course_page.dart  # 添加/编辑课程
│   │   ├── schedule_list_page.dart    # 课表列表
│   │   ├── schedule_edit_page.dart    # 课表编辑（含日期周次设置）
│   │   ├── settings_page.dart         # 设置页面
│   │   └── about_page.dart            # 关于页面
│   ├── providers/                     # Riverpod 状态管理
│   │   ├── course_provider.dart       # 课程列表流（StreamProvider）
│   │   ├── schedule_provider.dart     # 课表列表
│   │   ├── semester_provider.dart     # 学期配置
│   │   └── theme_provider.dart        # 主题设置（ThemeSettings）
│   ├── utils/                         # 页面级工具
│   │   └── import_helper.dart         # 导入流程编排
│   └── widgets/                       # UI 组件
│       ├── course_grid_widget.dart    # 课程网格（主课表）
│       ├── course_block_widget.dart   # 单课程块（可复用）
│       ├── course_detail_bottom_sheet.dart  # 课程详情底部面板
│       ├── export_import_dialogs.dart # 导出/文本导入对话框
│       ├── swap_course_dialog.dart    # 调课对话框
│       ├── theme_settings_dialog.dart # 主题设置弹窗
│       ├── app_dialogs.dart           # 通用确认/输入对话框
│       ├── schedule_popup.dart        # AppBar 弹出菜单（周次滑块 + 工具栏）
│       └── edu_system_selection_dialog.dart  # 教务系统选择
├── l10n/                              # 本地化
│   ├── app_zh.arb                     # 中文翻译资源（~350 条键）
│   ├── app_localizations.dart         # 生成代码
│   └── app_localizations_zh.dart      # 生成代码
└── ohos/                              # HarmonyOS 构建配置
    └── pubspec_overrides.yaml         # OpenHarmony-SIG 依赖覆盖
```

## 快速开始

```bash
# 克隆项目
git clone <repo-url>
cd flass

# 安装依赖
flutter pub get

# 代码生成（freezed、json_serializable、riverpod_generator）
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run
```

### HarmonyOS

```bash
cp ohos/pubspec_overrides.yaml pubspec_overrides.yaml
flutter pub get
flutter run -d ohos
```

> 注意：教务系统导入需要 WebView 支持。桌面端（Windows/Linux）会回退为粘贴 HTML 源代码的方式。

## 本地化

仅支持简体中文（`zh`），使用 `flutter_localizations` + ARB 文件。

```bash
# 修改 .arb 文件后刷新生成代码
flutter gen-l10n
```

## 数据库

使用 sqflite（SQLite），DAO 模式。主要表结构：

| 表 | 说明 |
|----|------|
| `courses` | 课程（id, name, teacher, location, color, scheduleId, metadata） |
| `time_details` | 上课时间（courseId, dayOfWeek, startPeriod, duration, weeks, singleOrDouble） |
| `schedules` | 课表（id, name, isDefault, createdAt, displayedWeekdays, maxCoursesPerDay, displayWeeks, startDate, totalWeeks） |
| `semester_configs` | 学期配置（startDate, totalWeeks, isActive） |

## 构建

```bash
# Android APK（arm64）
flutter build apk --target-platform android-arm64

# Windows
flutter build windows

# iOS（需 macOS）
flutter build ios

# macOS
flutter build macos

# Linux
flutter build linux
```

## 数据库迁移历史

| 版本 | 变更 |
|------|------|
| 1 | 初始表结构 |
| 2 | 添加 metadata 字段到 courses 表 |
| 3 | schedules 表添加 displayWeeks 字段 |

## 扩展机制

- **ActionItem 注册表**：全局注册 + 页面级回调覆盖
- **FormatRegistry**：可插拔的导入/导出格式扩展
- **CrudRepository**：通用 CRUD 接口基类
- **EduParserRegistry**：自动注册 + 手动选择的教务系统解析器
