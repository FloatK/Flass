import 'package:flutter/material.dart';

import '../../core/utils/vibrate.dart';

/// A circular color picker widget.
///
/// Displays a grid of color circles with a check mark on the selected color.
class ColorPicker extends StatelessWidget {
  /// List of colors to display.
  final List<Color> colors;

  /// Index of the currently selected color.
  final int selectedIndex;

  /// Callback when a color is selected (returns index).
  final ValueChanged<int> onColorSelected;

  /// Size of each color circle. Defaults to 32.
  final double size;

  /// Border color for unselected circles. Defaults to white.
  final Color? borderColor;

  /// Border color for the selected circle. If null, uses primary color.
  final Color? selectedBorderColor;

  const ColorPicker({
    super.key,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
    this.size = 32,
    this.borderColor,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? Colors.white;
    final effectiveSelectedBorder =
        selectedBorderColor ?? Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(colors.length, (index) {
        final color = colors[index];
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () {
            Vibrate.light();
            onColorSelected(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: effectiveSelectedBorder, width: 3)
                  : Border.all(color: effectiveBorderColor, width: 2),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: size * 0.5,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white,
                  )
                : null,
          ),
        );
      }),
    );
  }
}
