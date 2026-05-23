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
  String? _draggingSlider;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(themeSettingsProvider);
    _followSystem = settings.followSystem;
    _brightness = settings.brightness;
    _colorIndex = settings.colorIndex;
  }

  Future<void> _applySettings() async {
    final updated = ref.read(themeSettingsProvider).copyWith(
          followSystem: _followSystem,
          brightness: _brightness,
          colorIndex: _colorIndex,
        );
    ref.read(themeSettingsProvider.notifier).state = updated;
    await saveThemeSettings(updated);
  }

  Future<void> _updateAndSave(
      ThemeSettings Function(ThemeSettings) updater) async {
    final updated = updater(ref.read(themeSettingsProvider));
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
              // ---- 跟随系统 ----
              _buildSection(
                child: SwitchListTile(
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
              ),

              // ---- 亮色/深色 ----
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题模式',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _buildBrightnessSelector(),
                  ],
                ),
              ),

              // ---- 主题色 ----
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题颜色',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _buildColorGrid(),
                  ],
                ),
              ),

              // ---- 课程圆角 ----
              _buildSection(
                child: _buildSlider(
                  label: '课程圆角半径',
                  value: settings.cornerRadius,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  suffix: 'px',
                  onChanged: (v) =>
                      _updateAndSave((s) => s.copyWith(cornerRadius: v)),
                  sliderKey: 'cornerRadius',
                ),
              ),

              // ---- 课程高度 ----
              _buildSection(
                child: _buildSlider(
                  label: '课程块高度',
                  value: settings.blockHeight,
                  min: 20,
                  max: 100,
                  divisions: 16,
                  suffix: 'px',
                  onChanged: (v) =>
                      _updateAndSave((s) => s.copyWith(blockHeight: v)),
                  sliderKey: 'blockHeight',
                ),
              ),

              // ---- 课程间距 ----
              _buildSection(
                child: _buildSlider(
                  label: '课程间距',
                  value: settings.courseSpacing,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  suffix: 'px',
                  onChanged: (v) =>
                      _updateAndSave((s) => s.copyWith(courseSpacing: v)),
                  sliderKey: 'courseSpacing',
                ),
              ),

              // ---- 水平间距 ----
              _buildSection(
                child: _buildSlider(
                  label: '列间距',
                  value: settings.horizontalSpacing,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  suffix: 'px',
                  onChanged: (v) =>
                      _updateAndSave((s) => s.copyWith(horizontalSpacing: v)),
                  sliderKey: 'horizontalSpacing',
                ),
              ),

              // ---- 颜色深浅 ----
              _buildSection(
                child: _buildSlider(
                  label: '颜色深浅',
                  value: settings.colorLightness,
                  min: 0.5,
                  max: 1.8,
                  divisions: 36,
                  suffix: 'x',
                  onChanged: (v) =>
                      _updateAndSave((s) => s.copyWith(colorLightness: v)),
                  sliderKey: 'colorLightness',
                ),
              ),

              // ---- 深色模式设置 ----
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('深色模式设置',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _buildSlider(
                      label: '颜色饱和度',
                      value: settings.darkModeSaturation,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      suffix: 'x',
                      onChanged: (v) => _updateAndSave(
                          (s) => s.copyWith(darkModeSaturation: v)),
                      sliderKey: 'darkModeSaturation',
                    ),
                    const SizedBox(height: 8),
                    _buildSlider(
                      label: '颜色亮度',
                      value: settings.darkModeLightness,
                      min: 0.2,
                      max: 0.8,
                      divisions: 12,
                      suffix: 'x',
                      onChanged: (v) => _updateAndSave(
                          (s) => s.copyWith(darkModeLightness: v)),
                      sliderKey: 'darkModeLightness',
                    ),
                  ],
                ),
              ),

              // ---- 课表底板背景色 ----
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('课表底板背景色',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _buildGridBackgroundSelector(settings),
                    const SizedBox(height: 12),
                    if (settings.gridBackgroundMode ==
                        GridBackgroundMode.customGray)
                      _buildSlider(
                        label: '灰度等级',
                        value: settings.gridGrayLevel,
                        min: 0.0,
                        max: 0.5,
                        divisions: 20,
                        suffix: '',
                        onChanged: (v) => _updateAndSave(
                            (s) => s.copyWith(gridGrayLevel: v)),
                        sliderKey: 'gridGrayLevel',
                      ),
                    if (settings.gridBackgroundMode ==
                        GridBackgroundMode.followTheme)
                      _buildSlider(
                        label: '主题色深浅',
                        value: settings.gridThemeColorLightness,
                        min: 0.05,
                        max: 0.3,
                        divisions: 25,
                        suffix: '',
                        onChanged: (v) => _updateAndSave(
                            (s) =>
                                s.copyWith(gridThemeColorLightness: v)),
                        sliderKey: 'gridThemeColorLightness',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildSection({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
    required String sliderKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${value.toStringAsFixed(suffix == 'px' ? 0 : 2)}$suffix)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        RepaintBoundary(
          child: Opacity(
            opacity:
                _draggingSlider == null || _draggingSlider == sliderKey
                    ? 1.0
                    : 0.0,
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (v) {
                setState(() => _draggingSlider = sliderKey);
                onChanged(v);
              },
              onChangeEnd: (_) => setState(() => _draggingSlider = null),
            ),
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

  Widget _buildGridBackgroundSelector(ThemeSettings settings) {
    return Column(
      children: [
        _buildRadioOption<GridBackgroundMode>(
          title: '纯黑',
          subtitle: '适合 OLED 屏幕',
          value: GridBackgroundMode.pureBlack,
          groupValue: settings.gridBackgroundMode,
          color: Colors.black,
          onChanged: (v) {
            _updateAndSave((s) => s.copyWith(gridBackgroundMode: v));
          },
        ),
        _buildRadioOption<GridBackgroundMode>(
          title: '自定义灰',
          subtitle: '可调节灰度等级',
          value: GridBackgroundMode.customGray,
          groupValue: settings.gridBackgroundMode,
          color: Color.fromRGBO(
            (settings.gridGrayLevel * 255).round(),
            (settings.gridGrayLevel * 255).round(),
            (settings.gridGrayLevel * 255).round(),
            1,
          ),
          onChanged: (v) {
            _updateAndSave((s) => s.copyWith(gridBackgroundMode: v));
          },
        ),
        _buildRadioOption<GridBackgroundMode>(
          title: '跟随主题色',
          subtitle: '使用主题色的暗色调',
          value: GridBackgroundMode.followTheme,
          groupValue: settings.gridBackgroundMode,
          color: HSLColor.fromColor(
                  ThemeSettings.presetThemeColors[settings.colorIndex])
              .withLightness(settings.gridThemeColorLightness)
              .toColor(),
          onChanged: (v) {
            _updateAndSave((s) => s.copyWith(gridBackgroundMode: v));
          },
        ),
      ],
    );
  }

  Widget _buildRadioOption<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required Color color,
    required ValueChanged<T> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          )),
                ],
              ),
            ),
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
