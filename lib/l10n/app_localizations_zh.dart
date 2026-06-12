// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flass';

  @override
  String get addCourse => '添加课程';

  @override
  String get editCourse => '编辑课程';

  @override
  String get semesterSettings => '学期设置';

  @override
  String get weekLabel => '第';

  @override
  String get weekSuffix => '周';

  @override
  String get noCourse => '暂无课程';

  @override
  String get allWeeks => '全选';

  @override
  String get singleWeek => '单周';

  @override
  String get doubleWeek => '双周';

  @override
  String get mon => '周一';

  @override
  String get tue => '周二';

  @override
  String get wed => '周三';

  @override
  String get thu => '周四';

  @override
  String get fri => '周五';

  @override
  String get sat => '周六';

  @override
  String get sun => '周日';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get confirmDeleteTitle => '确认删除';

  @override
  String get confirmDeleteMessage => '确定要删除';

  @override
  String get teacherLabel => '教师';

  @override
  String get locationLabel => '地点';

  @override
  String get timeSchedule => '上课时间';

  @override
  String get retry => '重试';

  @override
  String get loadFailed => '加载失败';

  @override
  String get everyWeek => '每周';

  @override
  String get importSchedule => '导入课表';

  @override
  String get exportSchedule => '导出课表';

  @override
  String get importFromEdu => '从教务系统导入';

  @override
  String get parseSchedule => '抓取课表';

  @override
  String get selectCourses => '选择课程';

  @override
  String get batchSave => '批量保存';

  @override
  String get parsing => '解析中...';

  @override
  String get parseSuccess => '解析成功';

  @override
  String get parseFailed => '解析失败';

  @override
  String get unsupportedPlatform => '当前平台暂不支持此功能';

  @override
  String get manageSchedules => '管理课表';

  @override
  String get newSchedule => '新建课表';

  @override
  String get renameSchedule => '重命名';

  @override
  String get scheduleName => '课表名称';

  @override
  String get defaultSchedule => '默认课表';

  @override
  String get cannotDeleteDefault => '默认课表不可删除';

  @override
  String get scheduleSwitched => '已切换课表';

  @override
  String get importJsonHint => '粘贴 JSON 内容...';

  @override
  String get basicInfo => '基本信息';

  @override
  String get courseName => '课程名称';

  @override
  String get enterCourseName => '请输入课程名称';

  @override
  String get teacher => '授课教师';

  @override
  String get enterTeacher => '请输入授课教师';

  @override
  String get locationOptional => '上课地点（选填）';

  @override
  String get courseColor => '课程颜色';

  @override
  String get timeSettings => '时间设置';

  @override
  String get weekday => '星期';

  @override
  String get startPeriod => '开始节次';

  @override
  String get duration => '持续';

  @override
  String get addTimeSlot => '添加时间段';

  @override
  String get save => '保存';

  @override
  String get courseUpdated => '课程已更新';

  @override
  String get courseAdded => '课程已添加';

  @override
  String get saveFailed => '保存失败';

  @override
  String timeSlotLabel(int index) {
    return '时间段 $index';
  }

  @override
  String periodLabel(int n) {
    return '第$n节';
  }

  @override
  String durationLabel(int n) {
    return '$n节';
  }

  @override
  String selectWeeksHint(int index) {
    return '时间段 $index 请选择上课周次';
  }

  @override
  String get editSchedule => '编辑课表';

  @override
  String get maxCoursesPerDay => '一天最多课程数';

  @override
  String get displayedWeekdays => '每周显示的天数';

  @override
  String get semesterSettingsLabel => '学期设置';

  @override
  String get startDate => '开学日期';

  @override
  String get totalWeeks => '总周数';

  @override
  String get enterScheduleName => '请输入课表名称';

  @override
  String get enterTotalWeeks => '请输入总周数';

  @override
  String get totalWeeksRange => '总周数请输入1-30之间的数字';

  @override
  String get selectStartDate => '请选择开学日期';

  @override
  String get startDateNotSet => '未设置开学日期';

  @override
  String get startDateNotSetHint => '请在课表设置中选择开学日期';

  @override
  String maxCoursesLabel(int n) {
    return '一天最多课程数 ($n节)';
  }

  @override
  String get fetchSchedule => '抓取课表';

  @override
  String get enterValidUrl => '请输入有效的 URL（如 http://...）';

  @override
  String get noCoursesFound => '未找到课程数据，请确认已登录并进入课表页面';

  @override
  String get importSuccess => '成功导入';

  @override
  String get coursesUnit => '门课程';

  @override
  String get confirmImport => '确认导入';

  @override
  String get scheduleNameHint => '留空则自动生成';

  @override
  String get eduSystemUrlHint => '教务系统课表页面 URL';

  @override
  String get desktopPasteHint => '桌面端暂不支持内置浏览器。请在系统浏览器中打开教务系统页面，查看网页源代码并粘贴到下方。';

  @override
  String get eduUrlSaveLabel => '教务系统 URL（用于保存）';

  @override
  String get pasteHtmlHint =>
      '在此粘贴教务系统课表页面的 HTML 源代码\n\n步骤：\n1. 在浏览器中打开教务系统并进入课表页面\n2. 右键 → 查看网页源代码（或 Ctrl+U）\n3. 全选复制 → 粘贴到这里\n4. 点击右上角「抓取课表」';

  @override
  String importCourseCount(int count) {
    return '成功导入 $count 门课程';
  }

  @override
  String parseFailedMsg(String error) {
    return '$error';
  }

  @override
  String get shareSchedule => '分享课表';

  @override
  String get chooseExportMethod => '选择导出方式：';

  @override
  String get copyCompactCode => '复制紧凑码';

  @override
  String get shareFile => '分享文件';

  @override
  String get copiedCompactCode => '已复制';

  @override
  String get characters => '字符';

  @override
  String get copyHint => '打开从文本导入粘贴即可';

  @override
  String get shareFailed => '分享失败';

  @override
  String get importFromText => '从文本导入';

  @override
  String get pasteCompactHint => '粘贴包含「紧凑码」的内容...';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get parse => '解析';

  @override
  String get invalidFormat => '无效的格式，请检查内容';

  @override
  String get importFailed => '导入失败';

  @override
  String get clearCache => '清除缓存';

  @override
  String get confirmClearCache => '确定要清除缓存吗？';

  @override
  String get cacheCleared => '缓存已清除（占位）';

  @override
  String get about => '关于';

  @override
  String copiedMessage(int length) {
    return '已复制 ($length 字符)，打开从文本导入粘贴即可';
  }

  @override
  String get selectSchedule => '选择课表';

  @override
  String get noSchedule => '暂无课表';

  @override
  String get createSchedule => '新建课表';

  @override
  String get apply => '应用';

  @override
  String get scheduleSwitchedTo => '已切换到';

  @override
  String get themeSettings => '主题设置';

  @override
  String get followSystemDarkMode => '跟随系统深色模式';

  @override
  String get followSystemSubtitle => '开启后自动跟随系统亮暗模式';

  @override
  String get themeMode => '主题模式';

  @override
  String get lightMode => '亮色';

  @override
  String get darkMode => '深色';

  @override
  String get themeColor => '主题颜色';

  @override
  String get courseCornerRadius => '课程圆角半径';

  @override
  String get courseBlockHeight => '课程块高度';

  @override
  String get courseSpacing => '课程间距';

  @override
  String get columnSpacing => '列间距';

  @override
  String get colorLightness => '颜色深浅';

  @override
  String get close => '关闭';

  @override
  String pxLabel(String label, int value) {
    return '$label (${value}px)';
  }

  @override
  String lightnessLabel(String value) {
    return '颜色深浅 (${value}x)';
  }

  @override
  String get configAppBarButtons => '配置 AppBar 按钮';

  @override
  String get resetDefault => '重置默认';

  @override
  String get config => '配置';

  @override
  String get maxItemsHint => '最多选择';

  @override
  String get more => '更多';

  @override
  String weekSliderLabel(int week) {
    return '第 $week 周';
  }

  @override
  String maxAppBarItemsHint(int max) {
    return '选择要在顶栏显示的按钮（最多 $max 个）';
  }

  @override
  String get importing => '导入中...';

  @override
  String get chooseImportMethod => '选择导入方式：';

  @override
  String get overwriteCurrentSchedule => '覆盖当前课表';

  @override
  String get createNewScheduleAndImport => '新建课表并导入';

  @override
  String courseCountTitle(int count) {
    return '共 $count 门课程';
  }

  @override
  String importFailedMsg(String error) {
    return '$error';
  }

  @override
  String get defaultScheduleName => '默认课表';

  @override
  String importedScheduleName(int month, int day, String time) {
    return '导入课表 $month月$day日 $time';
  }

  @override
  String get settings => '设置';

  @override
  String get interaction => '交互';

  @override
  String get vibration => '振动反馈';

  @override
  String get vibrationSubtitle => '点击时给予轻微振动反馈';

  @override
  String get others => '其他';

  @override
  String get setSemester => '设置学期';

  @override
  String get skip => '跳过';

  @override
  String get selectEduSystem => '选择教务系统';

  @override
  String get backgroundFollowsTheme => '背景颜色跟随主题色';

  @override
  String get backgroundFollowsThemeSubtitle => '开启后底板背景色跟随主题主色变化';

  @override
  String get notCurrentWeek => '(非本周)';

  @override
  String dateMonthDay(int month, int day) {
    return '$month月$day日';
  }

  @override
  String get courseTable => '课程表';

  @override
  String get developer => '开发者';

  @override
  String get independentDeveloper => '在校青春男大（笑';

  @override
  String get aboutApp => '关于应用';

  @override
  String get appDescription => 'Flass 是一款简洁高效的课程表应用，支持教务系统导入、紧凑码分享、多课表管理等功能。';

  @override
  String get mainFeatures => '主要功能';

  @override
  String get featureEduImport => '教务系统导入';

  @override
  String get featureCompactShare => '紧凑码分享';

  @override
  String get featureMultiSchedule => '多课表管理';

  @override
  String get featureThemeCustom => '主题自定义';

  @override
  String get featureWeekView => '周视图展示';

  @override
  String get swapCourse => '调课';

  @override
  String get swapCourseDescription => '将一天的课程移动到另一天（会覆盖目标日期的课程）';

  @override
  String get swapFrom => '从';

  @override
  String get swapTo => '到';

  @override
  String swapMoveCount(int count) {
    return '将移动 $count 门课程';
  }

  @override
  String get swapConfirm => '确认调课';

  @override
  String noCourseOnDate(String date) {
    return '$date没有课程';
  }

  @override
  String swapSuccess(String source, String target) {
    return '已将$source的课程移动到$target';
  }

  @override
  String get previousWeek => '上一周';

  @override
  String get nextWeek => '下一周';

  @override
  String get returnCurrentWeek => '返回当前周';

  @override
  String get theme => '主题';

  @override
  String get configToolbar => '配置工具栏';

  @override
  String exportCopyMessage(String compact) {
    return '将该条消息复制，点击从文本导入即可导入课表。\n「$compact」';
  }

  @override
  String get scheduleData => '课表数据';

  @override
  String get pasteHtmlFirst => '请先粘贴 HTML 源代码';

  @override
  String loadFailedWith(String error) {
    return '加载失败: $error';
  }

  @override
  String dateYearMonthDay(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String weekdayCourseCount(String weekday, int count) {
    return '$weekday · $count门课程';
  }

  @override
  String get keepAtLeastOneSchedule => '至少保留一个课表';

  @override
  String get cannotDeleteDefaultSchedule => '默认课表不可删除';

  @override
  String get deleteScheduleFailed => '删除课表失败';

  @override
  String get importTimetable => '从教务导入';

  @override
  String get shareTimetable => '分享课表';

  @override
  String get importFromTextAction => '从文本导入';

  @override
  String get previousWeekAction => '上一周';

  @override
  String get nextWeekAction => '下一周';

  @override
  String get goToCurrentWeekAction => '返回当前周';

  @override
  String get selectTimetableAction => '选择课表';

  @override
  String get themeAction => '主题';

  @override
  String get swapCourseAction => '调课';

  @override
  String get importHelpTooltip => '查看导入流程';

  @override
  String get importGuideTitle => '教务系统导入指南';

  @override
  String get importGuideStep1Title => '打开教务系统';

  @override
  String get importGuideStep1Desc => '在浏览器中登录学校教务系统，进入课表页面。确保课表数据已完全加载。';

  @override
  String get importGuideStep2Title => '获取课表页面';

  @override
  String get importGuideStep2Desc =>
      '在上方输入框中粘贴教务系统课表页面的 URL，点击箭头按钮访问。或直接在内置浏览器中导航到课表页面。';

  @override
  String get importGuideStep3Title => '抓取课表';

  @override
  String get importGuideStep3Desc =>
      '页面加载完成后，点击右上角「抓取课表」按钮。系统会自动识别教务系统类型并解析课表数据。';

  @override
  String get importGuideStep4Title => '选择导入方式';

  @override
  String get importGuideStep4Desc => '解析成功后，选择「覆盖当前课表」或「新建课表并导入」。建议首次导入选择新建课表。';

  @override
  String get importGuideStep5Title => '设置学期信息';

  @override
  String get importGuideStep5Desc => '导入完成后，设置开学日期和总周数，以便正确计算当前周次。';

  @override
  String get importGuideTip => '提示：如果自动解析失败，可以尝试手动选择教务系统类型。桌面端请粘贴 HTML 源代码。';

  @override
  String get gotIt => '知道了';
}
