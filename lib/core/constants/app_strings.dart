class AppStrings {
  AppStrings._();

  static const String appTitle = 'Flass';
  static const String addCourse = '添加课程';
  static const String editCourse = '编辑课程';
  static const String semesterSettings = '学期设置';
  static const String weekLabel = '第';
  static const String weekSuffix = '周';
  static const String noCourse = '暂无课程';
  static const String allWeeks = '全选';
  static const String singleWeek = '单周';
  static const String doubleWeek = '双周';

  // Day labels
  static const String mon = '周一';
  static const String tue = '周二';
  static const String wed = '周三';
  static const String thu = '周四';
  static const String fri = '周五';
  static const String sat = '周六';
  static const String sun = '周日';

  static const List<String> dayLabels = [mon, tue, wed, thu, fri, sat, sun];

  /// 根据 dayOfWeek (1-7) 返回星期标签。
  static String dayLabel(int dayOfWeek) => dayLabels[dayOfWeek - 1];

  // UI actions
  static const String edit = '编辑';
  static const String delete = '删除';
  static const String cancel = '取消';
  static const String confirm = '确定';

  // Dialog
  static const String confirmDeleteTitle = '确认删除';
  static const String confirmDeleteMessage = '确定要删除';

  // Labels
  static const String teacherLabel = '教师';
  static const String locationLabel = '地点';
  static const String timeSchedule = '上课时间';

  // State
  static const String retry = '重试';
  static const String loadFailed = '加载失败';
  static const String everyWeek = '每周';

  // Phase 2 — Import & Export
  static const String importSchedule = '导入课表';
  static const String exportSchedule = '导出课表';
  static const String importFromEdu = '从教务系统导入';
  static const String parseSchedule = '抓取课表';
  static const String selectCourses = '选择课程';
  static const String batchSave = '批量保存';
  static const String parsing = '解析中...';
  static const String parseSuccess = '解析成功';
  static const String parseFailed = '解析失败';
  static const String unsupportedPlatform = '当前平台暂不支持此功能';

  // Phase 2 — Schedule Management
  static const String manageSchedules = '管理课表';
  static const String newSchedule = '新建课表';
  static const String renameSchedule = '重命名';
  static const String scheduleName = '课表名称';
  static const String defaultSchedule = '默认课表';
  static const String cannotDeleteDefault = '默认课表不可删除';
  static const String scheduleSwitched = '已切换课表';
  static const String importJsonHint = '粘贴 JSON 内容...';

  // ---- Add / Edit Course ----
  static const String basicInfo = '基本信息';
  static const String courseName = '课程名称';
  static const String enterCourseName = '请输入课程名称';
  static const String teacher = '授课教师';
  static const String enterTeacher = '请输入授课教师';
  static const String locationOptional = '上课地点（选填）';
  static const String courseColor = '课程颜色';
  static const String timeSettings = '时间设置';
  static const String weekday = '星期';
  static const String startPeriod = '开始节次';
  static const String duration = '持续';
  static const String addTimeSlot = '添加时间段';
  static const String save = '保存';
  static const String courseUpdated = '课程已更新';
  static const String courseAdded = '课程已添加';
  static const String saveFailed = '保存失败';

  static String timeSlotLabel(int index) => '时间段 $index';
  static String periodLabel(int n) => '第$n节';
  static String durationLabel(int n) => '$n节';
  static String selectWeeksHint(int index) => '时间段 $index 请选择上课周次';

  // ---- Schedule Edit ----
  static const String editSchedule = '编辑课表';
  static const String maxCoursesPerDay = '一天最多课程数';
  static const String displayedWeekdays = '每周显示的天数';
  static const String semesterSettingsLabel = '学期设置';
  static const String startDate = '开学日期';
  static const String totalWeeks = '总周数';
  static const String enterScheduleName = '请输入课表名称';
  static const String enterTotalWeeks = '请输入总周数';
  static const String totalWeeksRange = '总周数请输入1-30之间的数字';
  static const String selectStartDate = '请选择开学日期';

  static String maxCoursesLabel(int n) => '一天最多课程数 ($n节)';

  // ---- Import ----
  static const String fetchSchedule = '抓取课表';
  static const String enterValidUrl = '请输入有效的 URL（如 http://...）';
  static const String noCoursesFound = '未找到课程数据，请确认已登录并进入课表页面';
  static const String importSuccess = '成功导入';
  static const String coursesUnit = '门课程';
  static const String confirmImport = '确认导入';
  static const String scheduleNameHint = '留空则自动生成';
  static const String eduSystemUrlHint = '教务系统课表页面 URL';
  static const String desktopPasteHint =
      '桌面端暂不支持内置浏览器。请在系统浏览器中打开教务系统页面，查看网页源代码并粘贴到下方。';
  static const String eduUrlSaveLabel = '教务系统 URL（用于保存）';
  static const String pasteHtmlHint =
      '在此粘贴教务系统课表页面的 HTML 源代码\n\n步骤：\n1. 在浏览器中打开教务系统并进入课表页面\n2. 右键 → 查看网页源代码（或 Ctrl+U）\n3. 全选复制 → 粘贴到这里\n4. 点击右上角「抓取课表」';

  static String importCourseCount(int count) => '成功导入 $count 门课程';
  static String parseFailedMsg(String error) => '$parseFailed: $error';

  // ---- Export ----
  static const String shareSchedule = '分享课表';
  static const String chooseExportMethod = '选择导出方式：';
  static const String copyCompactCode = '复制紧凑码';
  static const String shareFile = '分享文件';
  static const String copiedCompactCode = '已复制';
  static const String characters = '字符';
  static const String copyHint = '打开从文本导入粘贴即可';
  static const String shareFailed = '分享失败';
  static const String importFromText = '从文本导入';
  static const String pasteCompactHint = '粘贴包含「紧凑码」的内容...';
  static const String pasteFromClipboard = '从剪贴板粘贴';
  static const String parse = '解析';
  static const String invalidFormat = '无效的格式，请检查内容';
  static const String importFailed = '导入失败';
  static const String clearCache = '清除缓存';
  static const String confirmClearCache = '确定要清除缓存吗？';
  static const String cacheCleared = '缓存已清除（占位）';
  static const String about = '关于';

  static String copiedMessage(int length) => '已复制 ($length 字符)，打开从文本导入粘贴即可';

  // ---- Schedule List ----
  static const String selectSchedule = '选择课表';
  static const String noSchedule = '暂无课表';
  static const String createSchedule = '新建课表';
  static const String apply = '应用';
  static const String scheduleSwitchedTo = '已切换到';

  // ---- Theme Settings ----
  static const String themeSettings = '主题设置';
  static const String followSystemDarkMode = '跟随系统深色模式';
  static const String followSystemSubtitle = '开启后自动跟随系统亮暗模式';
  static const String themeMode = '主题模式';
  static const String lightMode = '亮色';
  static const String darkMode = '深色';
  static const String themeColor = '主题颜色';
  static const String courseCornerRadius = '课程圆角半径';
  static const String courseBlockHeight = '课程块高度';
  static const String courseSpacing = '课程间距';
  static const String columnSpacing = '列间距';
  static const String colorLightness = '颜色深浅';
  static const String close = '关闭';

  static String pxLabel(String label, int value) => '$label (${value}px)';
  static String lightnessLabel(double value) => '颜色深浅 (${value.toStringAsFixed(1)}x)';

  // ---- AppBar Config ----
  static const String configAppBarButtons = '配置 AppBar 按钮';
  static const String resetDefault = '重置默认';
  static const String config = '配置';
  static const String maxItemsHint = '最多选择';
  static const String more = '更多';

  static String weekSliderLabel(int week) => '第 $week 周';
  static String maxAppBarItemsHint(int max) => '选择要在顶栏显示的按钮（最多 $max 个）';

  // ---- Import Helper ----
  static const String importing = '导入中...';
  static const String chooseImportMethod = '选择导入方式：';
  static const String overwriteCurrentSchedule = '覆盖当前课表';
  static const String createNewScheduleAndImport = '新建课表并导入';

  static String courseCountTitle(int count) => '共 $count 门课程';
  static String importFailedMsg(String error) => '$importFailed: $error';

  // ---- Schedule Edit (extra) ----
  static const String defaultScheduleName = '课表1';
  static String importedScheduleName(int month, int day, String time) =>
      '导入课表 $month月$day日 $time';
}
