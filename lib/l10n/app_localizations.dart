import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('zh')];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Flass'**
  String get appTitle;

  /// No description provided for @addCourse.
  ///
  /// In zh, this message translates to:
  /// **'添加课程'**
  String get addCourse;

  /// No description provided for @editCourse.
  ///
  /// In zh, this message translates to:
  /// **'编辑课程'**
  String get editCourse;

  /// No description provided for @semesterSettings.
  ///
  /// In zh, this message translates to:
  /// **'学期设置'**
  String get semesterSettings;

  /// No description provided for @weekLabel.
  ///
  /// In zh, this message translates to:
  /// **'第'**
  String get weekLabel;

  /// No description provided for @weekSuffix.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get weekSuffix;

  /// No description provided for @noCourse.
  ///
  /// In zh, this message translates to:
  /// **'暂无课程'**
  String get noCourse;

  /// No description provided for @allWeeks.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get allWeeks;

  /// No description provided for @singleWeek.
  ///
  /// In zh, this message translates to:
  /// **'单周'**
  String get singleWeek;

  /// No description provided for @doubleWeek.
  ///
  /// In zh, this message translates to:
  /// **'双周'**
  String get doubleWeek;

  /// No description provided for @mon.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get sun;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除'**
  String get confirmDeleteMessage;

  /// No description provided for @teacherLabel.
  ///
  /// In zh, this message translates to:
  /// **'教师'**
  String get teacherLabel;

  /// No description provided for @locationLabel.
  ///
  /// In zh, this message translates to:
  /// **'地点'**
  String get locationLabel;

  /// No description provided for @timeSchedule.
  ///
  /// In zh, this message translates to:
  /// **'上课时间'**
  String get timeSchedule;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  /// No description provided for @everyWeek.
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get everyWeek;

  /// No description provided for @importSchedule.
  ///
  /// In zh, this message translates to:
  /// **'导入课表'**
  String get importSchedule;

  /// No description provided for @exportSchedule.
  ///
  /// In zh, this message translates to:
  /// **'导出课表'**
  String get exportSchedule;

  /// No description provided for @importFromEdu.
  ///
  /// In zh, this message translates to:
  /// **'从教务系统导入'**
  String get importFromEdu;

  /// No description provided for @parseSchedule.
  ///
  /// In zh, this message translates to:
  /// **'抓取课表'**
  String get parseSchedule;

  /// No description provided for @selectCourses.
  ///
  /// In zh, this message translates to:
  /// **'选择课程'**
  String get selectCourses;

  /// No description provided for @batchSave.
  ///
  /// In zh, this message translates to:
  /// **'批量保存'**
  String get batchSave;

  /// No description provided for @parsing.
  ///
  /// In zh, this message translates to:
  /// **'解析中...'**
  String get parsing;

  /// No description provided for @parseSuccess.
  ///
  /// In zh, this message translates to:
  /// **'解析成功'**
  String get parseSuccess;

  /// No description provided for @parseFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析失败'**
  String get parseFailed;

  /// No description provided for @unsupportedPlatform.
  ///
  /// In zh, this message translates to:
  /// **'当前平台暂不支持此功能'**
  String get unsupportedPlatform;

  /// No description provided for @manageSchedules.
  ///
  /// In zh, this message translates to:
  /// **'管理课表'**
  String get manageSchedules;

  /// No description provided for @newSchedule.
  ///
  /// In zh, this message translates to:
  /// **'新建课表'**
  String get newSchedule;

  /// No description provided for @renameSchedule.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get renameSchedule;

  /// No description provided for @scheduleName.
  ///
  /// In zh, this message translates to:
  /// **'课表名称'**
  String get scheduleName;

  /// No description provided for @defaultSchedule.
  ///
  /// In zh, this message translates to:
  /// **'默认课表'**
  String get defaultSchedule;

  /// No description provided for @cannotDeleteDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认课表不可删除'**
  String get cannotDeleteDefault;

  /// No description provided for @scheduleSwitched.
  ///
  /// In zh, this message translates to:
  /// **'已切换课表'**
  String get scheduleSwitched;

  /// No description provided for @importJsonHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 JSON 内容...'**
  String get importJsonHint;

  /// No description provided for @basicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInfo;

  /// No description provided for @courseName.
  ///
  /// In zh, this message translates to:
  /// **'课程名称'**
  String get courseName;

  /// No description provided for @enterCourseName.
  ///
  /// In zh, this message translates to:
  /// **'请输入课程名称'**
  String get enterCourseName;

  /// No description provided for @teacher.
  ///
  /// In zh, this message translates to:
  /// **'授课教师'**
  String get teacher;

  /// No description provided for @enterTeacher.
  ///
  /// In zh, this message translates to:
  /// **'请输入授课教师'**
  String get enterTeacher;

  /// No description provided for @locationOptional.
  ///
  /// In zh, this message translates to:
  /// **'上课地点（选填）'**
  String get locationOptional;

  /// No description provided for @courseColor.
  ///
  /// In zh, this message translates to:
  /// **'课程颜色'**
  String get courseColor;

  /// No description provided for @timeSettings.
  ///
  /// In zh, this message translates to:
  /// **'时间设置'**
  String get timeSettings;

  /// No description provided for @weekday.
  ///
  /// In zh, this message translates to:
  /// **'星期'**
  String get weekday;

  /// No description provided for @startPeriod.
  ///
  /// In zh, this message translates to:
  /// **'开始节次'**
  String get startPeriod;

  /// No description provided for @duration.
  ///
  /// In zh, this message translates to:
  /// **'持续'**
  String get duration;

  /// No description provided for @addTimeSlot.
  ///
  /// In zh, this message translates to:
  /// **'添加时间段'**
  String get addTimeSlot;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @courseUpdated.
  ///
  /// In zh, this message translates to:
  /// **'课程已更新'**
  String get courseUpdated;

  /// No description provided for @courseAdded.
  ///
  /// In zh, this message translates to:
  /// **'课程已添加'**
  String get courseAdded;

  /// No description provided for @saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get saveFailed;

  /// No description provided for @timeSlotLabel.
  ///
  /// In zh, this message translates to:
  /// **'时间段 {index}'**
  String timeSlotLabel(int index);

  /// No description provided for @periodLabel.
  ///
  /// In zh, this message translates to:
  /// **'第{n}节'**
  String periodLabel(int n);

  /// No description provided for @durationLabel.
  ///
  /// In zh, this message translates to:
  /// **'{n}节'**
  String durationLabel(int n);

  /// No description provided for @selectWeeksHint.
  ///
  /// In zh, this message translates to:
  /// **'时间段 {index} 请选择上课周次'**
  String selectWeeksHint(int index);

  /// No description provided for @editSchedule.
  ///
  /// In zh, this message translates to:
  /// **'编辑课表'**
  String get editSchedule;

  /// No description provided for @maxCoursesPerDay.
  ///
  /// In zh, this message translates to:
  /// **'一天最多课程数'**
  String get maxCoursesPerDay;

  /// No description provided for @displayedWeekdays.
  ///
  /// In zh, this message translates to:
  /// **'每周显示的天数'**
  String get displayedWeekdays;

  /// No description provided for @semesterSettingsLabel.
  ///
  /// In zh, this message translates to:
  /// **'学期设置'**
  String get semesterSettingsLabel;

  /// No description provided for @startDate.
  ///
  /// In zh, this message translates to:
  /// **'开学日期'**
  String get startDate;

  /// No description provided for @totalWeeks.
  ///
  /// In zh, this message translates to:
  /// **'总周数'**
  String get totalWeeks;

  /// No description provided for @enterScheduleName.
  ///
  /// In zh, this message translates to:
  /// **'请输入课表名称'**
  String get enterScheduleName;

  /// No description provided for @enterTotalWeeks.
  ///
  /// In zh, this message translates to:
  /// **'请输入总周数'**
  String get enterTotalWeeks;

  /// No description provided for @totalWeeksRange.
  ///
  /// In zh, this message translates to:
  /// **'总周数请输入1-30之间的数字'**
  String get totalWeeksRange;

  /// No description provided for @selectStartDate.
  ///
  /// In zh, this message translates to:
  /// **'请选择开学日期'**
  String get selectStartDate;

  /// No description provided for @startDateNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置开学日期'**
  String get startDateNotSet;

  /// No description provided for @startDateNotSetHint.
  ///
  /// In zh, this message translates to:
  /// **'请在课表设置中选择开学日期'**
  String get startDateNotSetHint;

  /// No description provided for @maxCoursesLabel.
  ///
  /// In zh, this message translates to:
  /// **'一天最多课程数 ({n}节)'**
  String maxCoursesLabel(int n);

  /// No description provided for @fetchSchedule.
  ///
  /// In zh, this message translates to:
  /// **'抓取课表'**
  String get fetchSchedule;

  /// No description provided for @enterValidUrl.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 URL（如 http://...）'**
  String get enterValidUrl;

  /// No description provided for @noCoursesFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到课程数据，请确认已登录并进入课表页面'**
  String get noCoursesFound;

  /// No description provided for @importSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功导入'**
  String get importSuccess;

  /// No description provided for @coursesUnit.
  ///
  /// In zh, this message translates to:
  /// **'门课程'**
  String get coursesUnit;

  /// No description provided for @confirmImport.
  ///
  /// In zh, this message translates to:
  /// **'确认导入'**
  String get confirmImport;

  /// No description provided for @scheduleNameHint.
  ///
  /// In zh, this message translates to:
  /// **'留空则自动生成'**
  String get scheduleNameHint;

  /// No description provided for @eduSystemUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'教务系统课表页面 URL'**
  String get eduSystemUrlHint;

  /// No description provided for @desktopPasteHint.
  ///
  /// In zh, this message translates to:
  /// **'桌面端暂不支持内置浏览器。请在系统浏览器中打开教务系统页面，查看网页源代码并粘贴到下方。'**
  String get desktopPasteHint;

  /// No description provided for @eduUrlSaveLabel.
  ///
  /// In zh, this message translates to:
  /// **'教务系统 URL（用于保存）'**
  String get eduUrlSaveLabel;

  /// No description provided for @pasteHtmlHint.
  ///
  /// In zh, this message translates to:
  /// **'在此粘贴教务系统课表页面的 HTML 源代码\n\n步骤：\n1. 在浏览器中打开教务系统并进入课表页面\n2. 右键 → 查看网页源代码（或 Ctrl+U）\n3. 全选复制 → 粘贴到这里\n4. 点击右上角「抓取课表」'**
  String get pasteHtmlHint;

  /// No description provided for @importCourseCount.
  ///
  /// In zh, this message translates to:
  /// **'成功导入 {count} 门课程'**
  String importCourseCount(int count);

  /// No description provided for @parseFailedMsg.
  ///
  /// In zh, this message translates to:
  /// **'{error}'**
  String parseFailedMsg(String error);

  /// No description provided for @shareSchedule.
  ///
  /// In zh, this message translates to:
  /// **'分享课表'**
  String get shareSchedule;

  /// No description provided for @chooseExportMethod.
  ///
  /// In zh, this message translates to:
  /// **'选择导出方式：'**
  String get chooseExportMethod;

  /// No description provided for @copyCompactCode.
  ///
  /// In zh, this message translates to:
  /// **'复制紧凑码'**
  String get copyCompactCode;

  /// No description provided for @shareFile.
  ///
  /// In zh, this message translates to:
  /// **'分享文件'**
  String get shareFile;

  /// No description provided for @copiedCompactCode.
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get copiedCompactCode;

  /// No description provided for @characters.
  ///
  /// In zh, this message translates to:
  /// **'字符'**
  String get characters;

  /// No description provided for @copyHint.
  ///
  /// In zh, this message translates to:
  /// **'打开从文本导入粘贴即可'**
  String get copyHint;

  /// No description provided for @shareFailed.
  ///
  /// In zh, this message translates to:
  /// **'分享失败'**
  String get shareFailed;

  /// No description provided for @importFromText.
  ///
  /// In zh, this message translates to:
  /// **'从文本导入'**
  String get importFromText;

  /// No description provided for @pasteCompactHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴包含「紧凑码」的内容...'**
  String get pasteCompactHint;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板粘贴'**
  String get pasteFromClipboard;

  /// No description provided for @parse.
  ///
  /// In zh, this message translates to:
  /// **'解析'**
  String get parse;

  /// No description provided for @invalidFormat.
  ///
  /// In zh, this message translates to:
  /// **'无效的格式，请检查内容'**
  String get invalidFormat;

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get importFailed;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get clearCache;

  /// No description provided for @confirmClearCache.
  ///
  /// In zh, this message translates to:
  /// **'确定要清除缓存吗？'**
  String get confirmClearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'缓存已清除（占位）'**
  String get cacheCleared;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @copiedMessage.
  ///
  /// In zh, this message translates to:
  /// **'已复制 ({length} 字符)，打开从文本导入粘贴即可'**
  String copiedMessage(int length);

  /// No description provided for @selectSchedule.
  ///
  /// In zh, this message translates to:
  /// **'选择课表'**
  String get selectSchedule;

  /// No description provided for @noSchedule.
  ///
  /// In zh, this message translates to:
  /// **'暂无课表'**
  String get noSchedule;

  /// No description provided for @createSchedule.
  ///
  /// In zh, this message translates to:
  /// **'新建课表'**
  String get createSchedule;

  /// No description provided for @apply.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get apply;

  /// No description provided for @scheduleSwitchedTo.
  ///
  /// In zh, this message translates to:
  /// **'已切换到'**
  String get scheduleSwitchedTo;

  /// No description provided for @themeSettings.
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get themeSettings;

  /// No description provided for @followSystemDarkMode.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统深色模式'**
  String get followSystemDarkMode;

  /// No description provided for @followSystemSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启后自动跟随系统亮暗模式'**
  String get followSystemSubtitle;

  /// No description provided for @themeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeMode;

  /// No description provided for @lightMode.
  ///
  /// In zh, this message translates to:
  /// **'亮色'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get darkMode;

  /// No description provided for @themeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题颜色'**
  String get themeColor;

  /// No description provided for @courseCornerRadius.
  ///
  /// In zh, this message translates to:
  /// **'课程圆角半径'**
  String get courseCornerRadius;

  /// No description provided for @courseBlockHeight.
  ///
  /// In zh, this message translates to:
  /// **'课程块高度'**
  String get courseBlockHeight;

  /// No description provided for @courseSpacing.
  ///
  /// In zh, this message translates to:
  /// **'课程间距'**
  String get courseSpacing;

  /// No description provided for @columnSpacing.
  ///
  /// In zh, this message translates to:
  /// **'列间距'**
  String get columnSpacing;

  /// No description provided for @colorLightness.
  ///
  /// In zh, this message translates to:
  /// **'颜色深浅'**
  String get colorLightness;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @pxLabel.
  ///
  /// In zh, this message translates to:
  /// **'{label} ({value}px)'**
  String pxLabel(String label, int value);

  /// No description provided for @lightnessLabel.
  ///
  /// In zh, this message translates to:
  /// **'颜色深浅 ({value}x)'**
  String lightnessLabel(String value);

  /// No description provided for @configAppBarButtons.
  ///
  /// In zh, this message translates to:
  /// **'配置 AppBar 按钮'**
  String get configAppBarButtons;

  /// No description provided for @resetDefault.
  ///
  /// In zh, this message translates to:
  /// **'重置默认'**
  String get resetDefault;

  /// No description provided for @config.
  ///
  /// In zh, this message translates to:
  /// **'配置'**
  String get config;

  /// No description provided for @maxItemsHint.
  ///
  /// In zh, this message translates to:
  /// **'最多选择'**
  String get maxItemsHint;

  /// No description provided for @more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get more;

  /// No description provided for @weekSliderLabel.
  ///
  /// In zh, this message translates to:
  /// **'第 {week} 周'**
  String weekSliderLabel(int week);

  /// No description provided for @maxAppBarItemsHint.
  ///
  /// In zh, this message translates to:
  /// **'选择要在顶栏显示的按钮（最多 {max} 个）'**
  String maxAppBarItemsHint(int max);

  /// No description provided for @importing.
  ///
  /// In zh, this message translates to:
  /// **'导入中...'**
  String get importing;

  /// No description provided for @chooseImportMethod.
  ///
  /// In zh, this message translates to:
  /// **'选择导入方式：'**
  String get chooseImportMethod;

  /// No description provided for @overwriteCurrentSchedule.
  ///
  /// In zh, this message translates to:
  /// **'覆盖当前课表'**
  String get overwriteCurrentSchedule;

  /// No description provided for @createNewScheduleAndImport.
  ///
  /// In zh, this message translates to:
  /// **'新建课表并导入'**
  String get createNewScheduleAndImport;

  /// No description provided for @courseCountTitle.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 门课程'**
  String courseCountTitle(int count);

  /// No description provided for @importFailedMsg.
  ///
  /// In zh, this message translates to:
  /// **'{error}'**
  String importFailedMsg(String error);

  /// No description provided for @defaultScheduleName.
  ///
  /// In zh, this message translates to:
  /// **'课表1'**
  String get defaultScheduleName;

  /// No description provided for @importedScheduleName.
  ///
  /// In zh, this message translates to:
  /// **'导入课表 {month}月{day}日 {time}'**
  String importedScheduleName(int month, int day, String time);

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @interaction.
  ///
  /// In zh, this message translates to:
  /// **'交互'**
  String get interaction;

  /// No description provided for @vibration.
  ///
  /// In zh, this message translates to:
  /// **'振动反馈'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击时给予轻微振动反馈'**
  String get vibrationSubtitle;

  /// No description provided for @others.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get others;

  /// No description provided for @setSemester.
  ///
  /// In zh, this message translates to:
  /// **'设置学期'**
  String get setSemester;

  /// No description provided for @skip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get skip;

  /// No description provided for @selectEduSystem.
  ///
  /// In zh, this message translates to:
  /// **'选择教务系统'**
  String get selectEduSystem;

  /// No description provided for @backgroundFollowsTheme.
  ///
  /// In zh, this message translates to:
  /// **'背景颜色跟随主题色'**
  String get backgroundFollowsTheme;

  /// No description provided for @backgroundFollowsThemeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启后底板背景色跟随主题主色变化'**
  String get backgroundFollowsThemeSubtitle;

  /// No description provided for @notCurrentWeek.
  ///
  /// In zh, this message translates to:
  /// **'(非本周)'**
  String get notCurrentWeek;

  /// No description provided for @dateMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String dateMonthDay(int month, int day);

  /// No description provided for @courseTable.
  ///
  /// In zh, this message translates to:
  /// **'课程表'**
  String get courseTable;

  /// No description provided for @developer.
  ///
  /// In zh, this message translates to:
  /// **'开发者'**
  String get developer;

  /// No description provided for @independentDeveloper.
  ///
  /// In zh, this message translates to:
  /// **'在校青春男大（笑'**
  String get independentDeveloper;

  /// No description provided for @aboutApp.
  ///
  /// In zh, this message translates to:
  /// **'关于应用'**
  String get aboutApp;

  /// No description provided for @appDescription.
  ///
  /// In zh, this message translates to:
  /// **'Flass 是一款简洁高效的课程表应用，支持教务系统导入、紧凑码分享、多课表管理等功能。'**
  String get appDescription;

  /// No description provided for @mainFeatures.
  ///
  /// In zh, this message translates to:
  /// **'主要功能'**
  String get mainFeatures;

  /// No description provided for @featureEduImport.
  ///
  /// In zh, this message translates to:
  /// **'教务系统导入'**
  String get featureEduImport;

  /// No description provided for @featureCompactShare.
  ///
  /// In zh, this message translates to:
  /// **'紧凑码分享'**
  String get featureCompactShare;

  /// No description provided for @featureMultiSchedule.
  ///
  /// In zh, this message translates to:
  /// **'多课表管理'**
  String get featureMultiSchedule;

  /// No description provided for @featureThemeCustom.
  ///
  /// In zh, this message translates to:
  /// **'主题自定义'**
  String get featureThemeCustom;

  /// No description provided for @featureWeekView.
  ///
  /// In zh, this message translates to:
  /// **'周视图展示'**
  String get featureWeekView;

  /// No description provided for @swapCourse.
  ///
  /// In zh, this message translates to:
  /// **'调课'**
  String get swapCourse;

  /// No description provided for @swapCourseDescription.
  ///
  /// In zh, this message translates to:
  /// **'将一天的课程移动到另一天（会覆盖目标日期的课程）'**
  String get swapCourseDescription;

  /// No description provided for @swapFrom.
  ///
  /// In zh, this message translates to:
  /// **'从'**
  String get swapFrom;

  /// No description provided for @swapTo.
  ///
  /// In zh, this message translates to:
  /// **'到'**
  String get swapTo;

  /// No description provided for @swapMoveCount.
  ///
  /// In zh, this message translates to:
  /// **'将移动 {count} 门课程'**
  String swapMoveCount(int count);

  /// No description provided for @swapConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认调课'**
  String get swapConfirm;

  /// No description provided for @noCourseOnDate.
  ///
  /// In zh, this message translates to:
  /// **'{date}没有课程'**
  String noCourseOnDate(String date);

  /// No description provided for @swapSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已将{source}的课程移动到{target}'**
  String swapSuccess(String source, String target);

  /// No description provided for @previousWeek.
  ///
  /// In zh, this message translates to:
  /// **'上一周'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In zh, this message translates to:
  /// **'下一周'**
  String get nextWeek;

  /// No description provided for @returnCurrentWeek.
  ///
  /// In zh, this message translates to:
  /// **'返回当前周'**
  String get returnCurrentWeek;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @configToolbar.
  ///
  /// In zh, this message translates to:
  /// **'配置工具栏'**
  String get configToolbar;

  /// No description provided for @exportCopyMessage.
  ///
  /// In zh, this message translates to:
  /// **'将该条消息复制，点击从文本导入即可导入课表。\n「{compact}」'**
  String exportCopyMessage(String compact);

  /// No description provided for @scheduleData.
  ///
  /// In zh, this message translates to:
  /// **'课表数据'**
  String get scheduleData;

  /// No description provided for @pasteHtmlFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先粘贴 HTML 源代码'**
  String get pasteHtmlFirst;

  /// No description provided for @loadFailedWith.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String loadFailedWith(String error);

  /// No description provided for @dateYearMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{year}年{month}月{day}日'**
  String dateYearMonthDay(int year, int month, int day);

  /// No description provided for @weekdayCourseCount.
  ///
  /// In zh, this message translates to:
  /// **'{weekday} · {count}门课程'**
  String weekdayCourseCount(String weekday, int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
