import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/vibrate.dart';
import '../../data/models/course.dart';
import '../providers/theme_provider.dart';

/// 课程块组件
///
/// 显示单个课程的名称和地点，支持自定义外观。
/// 可以通过 [builder] 参数自定义渲染内容。
class CourseBlockWidget extends ConsumerWidget {
  /// 课程数据
  final Course course;

  /// 是否为深色模式
  final bool isDark;

  /// 点击回调
  final VoidCallback? onTap;

  /// 自定义内容构建器
  ///
  /// 如果提供，将覆盖默认的课程名称和地点显示。
  final Widget Function(BuildContext context, Course course)? builder;

  /// 自定义颜色
  ///
  /// 如果提供，将覆盖默认的颜色计算逻辑。
  final Color? color;

  /// 自定义圆角半径
  ///
  /// 如果提供，将覆盖主题设置中的圆角半径。
  final double? cornerRadius;

  const CourseBlockWidget({
    super.key,
    required this.course,
    required this.isDark,
    this.onTap,
    this.builder,
    this.color,
    this.cornerRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tSettings = ref.watch(themeSettingsProvider);

    // 计算课程颜色
    final courseColor = color ?? _calculateColor(tSettings);

    // 获取圆角半径
    final radius = cornerRadius ?? tSettings.cornerRadius;

    return GestureDetector(
      onTap: () {
        Vibrate.light();
        onTap?.call();
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: courseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.all(4),
        child: builder != null
            ? builder!(context, course)
            : _buildDefaultContent(),
      ),
    );
  }

  /// 计算课程颜色
  Color _calculateColor(ThemeSettings tSettings) {
    final baseColor = course.color != 0
        ? Color(course.color)
        : Color(AppColors.presetCourseColors[0]);

    if (isDark) {
      // 深色模式：自动压暗颜色
      return tSettings.getDarkModeCourseColor(baseColor.toARGB32());
    } else {
      // 浅色模式：使用正常的颜色调整
      final hsl = HSLColor.fromColor(baseColor);
      final adjustedLightness =
          (hsl.lightness * tSettings.colorLightness).clamp(0.0, 1.0);
      return hsl.withLightness(adjustedLightness).toColor();
    }
  }

  /// 构建默认内容
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (course.location != null && course.location!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              course.location!,
              style: const TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
      ],
    );
  }
}
