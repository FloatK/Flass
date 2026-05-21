import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class ThemeSettingsDialog extends ConsumerStatefulWidget {
  const ThemeSettingsDialog({super.key});

  @override
  ConsumerState<ThemeSettingsDialog> createState() =>
      _ThemeSettingsDialogState();
}

class _ThemeSettingsDialogState extends ConsumerState<ThemeSettingsDialog> {
  late bool _followSystem;
  late Brightness _brightness;
  late int _colorIndex;
  String? _draggingSlider; // null = none, 'cornerRadius' / 'blockHeight' / 'courseSpacing'

  @override
  void initState() {
    super.initState();
    final settings = ref.read(themeSettingsProvider);
    _followSystem = settings.followSystem;
    _brightness = settings.brightness;
    _colorIndex = settings.colorIndex;
  }

  ThemeSettings _current() => ref.read(themeSettingsProvider);

  Future<void> _applySettings() async {
    final s = _current();
    final newSettings = ThemeSettings(
      followSystem: _followSystem,
      brightness: _brightness,
      colorIndex: _colorIndex,
      cornerRadius: s.cornerRadius,
      blockHeight: s.blockHeight,
      courseSpacing: s.courseSpacing,
      horizontalSpacing: s.horizontalSpacing,
      colorLightness: s.colorLightness,
    );
    ref.read(themeSettingsProvider.notifier).state = newSettings;
    await saveThemeSettings(newSettings);
  }

  Future<void> _updateCornerRadius(double v) async {
    final s = _current();
    final updated = ThemeSettings(
      followSystem: _followSystem,
      brightness: _brightness,
      colorIndex: _colorIndex,
      cornerRadius: v,
      blockHeight: s.blockHeight,
      courseSpacing: s.courseSpacing,
      horizontalSpacing: s.horizontalSpacing,
      colorLightness: s.colorLightness,
    );
    ref.read(themeSettingsProvider.notifier).state = updated;
    await saveThemeSettings(updated);
  }

  Future<void> _updateBlockHeight(double v) async {
    final s = _current();
    final updated = ThemeSettings(
      followSystem: _followSystem,
      brightness: _brightness,
      colorIndex: _colorIndex,
      cornerRadius: s.cornerRadius,
      blockHeight: v,
      courseSpacing: s.courseSpacing,
      horizontalSpacing: s.horizontalSpacing,
      colorLightness: s.colorLightness,
    );
    ref.read(themeSettingsProvider.notifier).state = updated;
    await saveThemeSettings(updated);
  }

  Future<void> _updateCourseSpacing(double v) async {
    final s = _current();
    final updated = ThemeSettings(
      followSystem: _followSystem,
      brightness: _brightness,
      colorIndex: _colorIndex,
      cornerRadius: s.cornerRadius,
      blockHeight: s.blockHeight,
      courseSpacing: v,
      horizontalSpacing: s.horizontalSpacing,
      colorLightness: s.colorLightness,
    );
    ref.read(themeSettingsProvider.notifier).state = updated;
    await saveThemeSettings(updated);
  }

  Future<void> _updateHorizontalSpacing(double v) async {
    final s = _current();
    final updated = ThemeSettings(
      followSystem: _followSystem,
      brightness: _brightness,
      colorIndex: _colorIndex,
      cornerRadius: s.cornerRadius,
      blockHeight: s.blockHeight,
      courseSpacing: s.courseSpacing,
      horizontalSpacing: v,
      colorLightness: s.colorLightness,
    );
    ref.read(themeSettingsProvider.notifier).state = updated;
    await saveThemeSettings(updated);
  }

  Future<void> _updateColorLightness(double v) async {
    final s = _current();
    final updated = ThemeSettings(
      followSystem: _followSystem,
      brightness: _brightness,
      colorIndex: _colorIndex,
      cornerRadius: s.cornerRadius,
      blockHeight: s.blockHeight,
      courseSpacing: s.courseSpacing,
      horizontalSpacing: s.horizontalSpacing,
      colorLightness: v,
    );
    ref.read(themeSettingsProvider.notifier).state = updated;
    await saveThemeSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(themeSettingsProvider);

    return AlertDialog(
      backgroundColor: _draggingSlider != null ? Colors.transparent : null,
      surfaceTintColor: _draggingSlider != null ? Colors.transparent : null,
      title: Opacity(
        opacity: _draggingSlider == null ? 1.0 : 0.0,
        child: const Text('主题设置'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- 所有非滑块控件 ----
              Opacity(
                opacity: _draggingSlider == null ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- 跟随系统 ----
                    SwitchListTile(
                      title: const Text('跟随系统深色模式'),
                      subtitle: const Text(
                        '开启后自动跟随系统亮暗模式',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _followSystem,
                      onChanged: (v) {
                        setState(() => _followSystem = v);
                        _applySettings();
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // ---- 亮色/深色 ----
                    Text(
                      '主题模式',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _buildBrightnessSelector(),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // ---- 主题色 ----
                    Text(
                      '主题颜色',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildColorGrid(),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // ---- 课程圆角标签 ----
                    Text(
                      '课程圆角半径 (${settings.cornerRadius.round()}px)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ---- 课程圆角滑块 ----
              RepaintBoundary(
                child: Opacity(
                  opacity: _draggingSlider == null || _draggingSlider == 'cornerRadius'
                      ? 1.0
                      : 0.0,
                  child: Slider(
                    value: settings.cornerRadius,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '${settings.cornerRadius.round()}px',
                    onChanged: (v) {
                      setState(() => _draggingSlider = 'cornerRadius');
                      _updateCornerRadius(v);
                    },
                    onChangeEnd: (_) => setState(() => _draggingSlider = null),
                  ),
                ),
              ),

              // ---- 课程高度标签 + 分隔 ----
              Opacity(
                opacity: _draggingSlider == null ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    Text(
                      '课程块高度 (${settings.blockHeight.round()}px)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ---- 课程高度滑块 ----
              RepaintBoundary(
                child: Opacity(
                  opacity: _draggingSlider == null || _draggingSlider == 'blockHeight'
                      ? 1.0
                      : 0.0,
                  child: Slider(
                    value: settings.blockHeight,
                    min: 20,
                    max: 100,
                    divisions: 16,
                    label: '${settings.blockHeight.round()}px',
                    onChanged: (v) {
                      setState(() => _draggingSlider = 'blockHeight');
                      _updateBlockHeight(v);
                    },
                    onChangeEnd: (_) => setState(() => _draggingSlider = null),
                  ),
                ),
              ),

              // ---- 课程间距标签 + 分隔 ----
              Opacity(
                opacity: _draggingSlider == null ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    Text(
                      '课程间距 (${settings.courseSpacing.round()}px)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ---- 课程间距滑块 ----
              RepaintBoundary(
                child: Opacity(
                  opacity: _draggingSlider == null || _draggingSlider == 'courseSpacing'
                      ? 1.0
                      : 0.0,
                  child: Slider(
                    value: settings.courseSpacing,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '${settings.courseSpacing.round()}px',
                    onChanged: (v) {
                      setState(() => _draggingSlider = 'courseSpacing');
                      _updateCourseSpacing(v);
                    },
                    onChangeEnd: (_) => setState(() => _draggingSlider = null),
                  ),
                ),
              ),

              // ---- 水平间距标签 + 分隔 ----
              Opacity(
                opacity: _draggingSlider == null ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    Text(
                      '列间距 (${settings.horizontalSpacing.round()}px)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ---- 水平间距滑块 ----
              RepaintBoundary(
                child: Opacity(
                  opacity: _draggingSlider == null || _draggingSlider == 'horizontalSpacing'
                      ? 1.0
                      : 0.0,
                  child: Slider(
                    value: settings.horizontalSpacing,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '${settings.horizontalSpacing.round()}px',
                    onChanged: (v) {
                      setState(() => _draggingSlider = 'horizontalSpacing');
                      _updateHorizontalSpacing(v);
                    },
                    onChangeEnd: (_) => setState(() => _draggingSlider = null),
                  ),
                ),
              ),

              // ---- 颜色深浅滑块 ----
              Text(
                '颜色深浅 (${settings.colorLightness.toStringAsFixed(1)}x)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              RepaintBoundary(
                child: Opacity(
                  opacity: _draggingSlider == null || _draggingSlider == 'colorLightness'
                      ? 1.0
                      : 0.0,
                  child: Slider(
                    value: settings.colorLightness,
                    min: 0.5,
                    max: 1.8,
                    divisions: 36,
                    label: '${settings.colorLightness.toStringAsFixed(1)}x',
                    onChanged: (v) {
                      setState(() => _draggingSlider = 'colorLightness');
                      _updateColorLightness(v);
                    },
                    onChangeEnd: (_) => setState(() => _draggingSlider = null),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Opacity(
          opacity: _draggingSlider == null ? 1.0 : 0.0,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ),
      ],
    );
  }

  Widget _buildBrightnessSelector() {
    final enabled = !_followSystem;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: SegmentedButton<Brightness>(
        segments: const [
          ButtonSegment(
            value: Brightness.light,
            label: Text('亮色'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: Brightness.dark,
            label: Text('深色'),
            icon: Icon(Icons.dark_mode),
          ),
        ],
        selected: {_brightness},
        onSelectionChanged: enabled
            ? (v) {
                setState(() => _brightness = v.first);
                _applySettings();
              }
            : null,
      ),
    );
  }

  Widget _buildColorGrid() {
    final colors = ThemeSettings.presetThemeColors;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(colors.length, (i) {
        final isSelected = _colorIndex == i;
        return GestureDetector(
          onTap: () {
            setState(() => _colorIndex = i);
            _applySettings();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors[i].withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: colors[i].computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }),
    );
  }
}
