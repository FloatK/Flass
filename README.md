# Flass — Flutter 课表 App

一个轻量、美观、可高度自定义的课程表应用，使用 Flutter 构建。

## 功能

### 课表展示
- 按周展示课程表，支持上一周/下一周/回到当前周导航
- 课程块支持圆角、高度、间距自定义
- 点击课程弹出详情底部面板
- 深色模式自动压暗课程颜色

### 课程管理
- 添加/编辑/删除课程
- 每个课程支持多个时间段（不同日期、不同节次）
- 选择/全选/单周/双周上课周次
- 课程颜色选择器（8 种预设色）
- 调课功能：将课程移动到指定日期

### 课表管理
- 多课表支持（创建、重命名、删除、切换）
- 默认课表机制
- 每个课表独立设置显示天数和每日最大课程数
- 学期设置（开学日期、总周数）

### 导入功能
- **教务系统导入**：内置 WebView 访问教务系统，抓取课表页面自动解析
- **文本导入**：粘贴紧凑码（GZip + base64 编码），一键导入课表
- 导入时支持「覆盖当前课表」或「新建课表并导入」
- 桌面端支持粘贴 HTML 源代码解析

### 导出 & 分享
- 紧凑码编码：课表数据 → 短键 JSON → GZip → base64Url 单行文本
- 复制到剪贴板或分享文件

### 主题设置
- 跟随系统深色模式 / 手动切换亮暗
- 8 种主题色
- 课程圆角半径、课程块高度、课程间距、列间距
- 颜色深浅调节（HSL 亮度因子 0.5–1.8）
- 课表底板背景色跟随主题色

### 交互反馈
- 点击课程振动反馈（可关闭）
- 可配置工具栏按钮

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter + Material 3 |
| 状态管理 | Riverpod 2.x（StateProvider、FutureProvider、StreamProvider） |
| 数据库 | drift（SQLite ORM，支持流式查询） |
| 路由 | go\_router |
| 代码生成 | freezed（数据类）、json\_serializable、riverpod\_generator、drift\_dev |
| 本地化 | flutter\_localizations，中英双语 |
| 网络 | dio + retrofit（教务 API）、webview\_flutter（内置浏览器） |
| 存储 | SharedPreferences（主题设置持久化） |
| 其他 | uuid、share\_plus、path\_provider、html 解析 |

## 项目结构

```
lib/
├── app.dart                          # MaterialApp 入口（主题 + 本地化）
├── main.dart                         # 初始化（数据库、主题设置）
├── core/
│   ├── config/                       # AppBar 按钮配置、ActionItem 枚举
│   ├── constants/                    # AppStrings、AppColors 常量
│   ├── theme/                        # ThemeData 构建（动态主题色）
│   └── utils/                        # 公共工具类
│       ├── export_utils.dart         # 紧凑码编解码
│       ├── import_utils.dart         # 导入解析（纯 Dart，无 UI 依赖）
│       ├── ui_utils.dart             # SnackBar 等 UI 工具
│       ├── week_utils.dart           # 周次解析
│       ├── date_utils.dart           # 日期工具
│       ├── edu_system_webview_controller.dart  # 教务 WebView 控制器
│       └── edu_url_store.dart        # 教务 URL 持久化
├── data/
│   ├── datasources/
│   │   ├── database.dart             # drift 数据库定义 + 迁移
│   │   ├── edu_parser.dart           # 课表 HTML 解析接口
│   │   ├── edu_parser_qz.dart        # 强智教务系统解析实现
│   │   └── sample_data.dart          # 示例数据
│   ├── models/
│   │   ├── course.dart               # Course（freezed）
│   │   ├── schedule.dart             # Schedule（freezed）
│   │   └── ...
│   └── repositories/                 # 数据库访问实现
├── domain/
│   └── repositories/                 # 仓库接口定义
└── presentation/
    ├── pages/                        # 页面
    │   ├── week_schedule_page.dart    # 主课表页面
    │   ├── import_schedule_page.dart  # 教务导入页面
    │   ├── add_edit_course_page.dart  # 添加/编辑课程
    │   ├── schedule_list_page.dart    # 课表列表页面
    │   ├── schedule_edit_page.dart    # 课表编辑（学期设置）
    │   ├── settings_page.dart         # 设置页面
    │   └── about_page.dart            # 关于页面
    ├── providers/                     # Riverpod 状态管理
    │   ├── theme_provider.dart        # 主题设置模型 + 持久化
    │   ├── course_provider.dart       # 课程列表流
    │   ├── schedule_provider.dart     # 课表列表 + 当前课表
    │   └── semester_provider.dart     # 学期配置
    ├── utils/                         # 页面级工具
    │   └── import_helper.dart         # 导入流程（选择对话框、覆盖/新建）
    └── widgets/                       # UI 组件
        ├── course_grid_widget.dart    # 课程网格
        ├── course_detail_bottom_sheet.dart  # 课程详情底部面板
        ├── export_import_dialogs.dart  # 导出/文本导入对话框
        ├── swap_course_dialog.dart    # 调课对话框
        ├── theme_settings_dialog.dart # 主题设置弹窗
        └── schedule_popup.dart        # 工具栏弹出菜单
```

## 快速开始

```bash
# 克隆项目
git clone <repo-url>
cd flass

# 安装依赖
flutter pub get

# 代码生成（freezed、drift、json_serializable）
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run
```

> 注意：部分功能（如教务系统导入）需要 WebView 支持。在桌面端（Windows/Linux）会回退为粘贴 HTML 源代码的方式。

## 本地化

App 自动跟随系统语言显示中文或英文界面。支持语言：

- 简体中文（`zh`）
- 英文（`en`）

## 数据库

使用 drift（SQLite ORM），主要表结构：

| 表 | 说明 |
|----|------|
| `Courses` | 课程（id, name, teacher, location, color, scheduleId） |
| `TimeDetails` | 上课时间（courseId, dayOfWeek, startPeriod, duration, weeks, singleOrDouble） |
| `Schedules` | 课表（id, name, isDefault, createdAt, displayedWeekdays, maxCoursesPerDay） |
| `SemesterConfigs` | 学期配置（startDate, totalWeeks, isActive） |
