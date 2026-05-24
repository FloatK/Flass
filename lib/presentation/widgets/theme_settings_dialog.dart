import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class ThemeSettingsDialog extends ConsumerStatefulWidget {
  /// Called when slider dragging state changes (true = dragging in progress).
  final ValueChanged<bool>? onDragChanged;

  /// Called when the dialog should be closed.
  /// If null, defaults to Navigator.pop(context).
  final VoidCallback? onClose;

  const ThemeSettingsDialog({
    super.key,
    this.onDragChanged,
    this.onClose,
  });

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
                hideWhenDragging: true,
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
                hideWhenDragging: true,
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
                hideWhenDragging: true,
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

              // ---- 课表底板背景色 ----
              _buildSection(
                hideWhenDragging: true,
                child: SwitchListTile(
                  title: const Text('背景颜色跟随主题色'),
                  subtitle: const Text(
                    '开启后底板背景色跟随主题主色变化',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: settings.followThemeBackground,
                  onChanged: (v) {
                    _updateAndSave(
                        (s) => s.copyWith(followThemeBackground: v));
                  },
                  contentPadding: EdgeInsets.zero,
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
            onPressed: () => (widget.onClose ?? () => Navigator.pop(context))(),
            child: const Text('关闭'),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required Widget child, bool hideWhenDragging = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: hideWhenDragging
          ? Opacity(
              opacity: _draggingSlider == null ? 1.0 : 0.0,
              child: child,
            )
          : child,
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
    final isVisible =
        _draggingSlider == null || _draggingSlider == sliderKey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          child: Opacity(
            opacity: isVisible ? 1.0 : 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label (${value.toStringAsFixed(suffix == 'px' ? 0 : 2)}$suffix)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: (v) {
                    setState(() => _draggingSlider = sliderKey);
                    widget.onDragChanged?.call(true);
                    onChanged(v);
                  },
                  onChangeEnd: (_) {
                    setState(() => _draggingSlider = null);
                    widget.onDragChanged?.call(false);
                  },
                ),
              ],
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
}
