import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/action_item.dart';
import '../../core/config/app_bar_config.dart';
import '../../core/utils/vibrate.dart';
import '../../l10n/app_localizations.dart';

/// Custom popup displayed when tapping the AppBar's overflow menu button.
/// Contains: week slider + GridView of action buttons (4 columns).
class SchedulePopup extends ConsumerStatefulWidget {
  final int displayedWeek;
  final int totalWeeks;
  final ValueChanged<int> onWeekChanged;
  final List<ActionItem> appBarItems;
  final VoidCallback onConfigChanged;
  final void Function(ActionItem item)? onActionItem;
  /// 所有可用的 ActionItem（已覆盖回调），用于填充弹出菜单
  final List<ActionItem>? allAvailableItems;

  const SchedulePopup({
    super.key,
    required this.displayedWeek,
    required this.totalWeeks,
    required this.onWeekChanged,
    required this.appBarItems,
    required this.onConfigChanged,
    this.onActionItem,
    this.allAvailableItems,
  });

  @override
  ConsumerState<SchedulePopup> createState() => _SchedulePopupState();
}

class _SchedulePopupState extends ConsumerState<SchedulePopup> {
  late double _sliderValue;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.displayedWeek.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final overflowItems = AppBarConfig.getOverflowItems(
      widget.appBarItems,
      allItems: widget.allAvailableItems,
    );
    final allItems = widget.allAvailableItems ?? ActionItemRegistry.instance.getAll();
    // Always include selectTimetable and navigation items if not already there
    final selectTimetable = allItems.firstWhere(
      (item) => item.id == 'selectTimetable',
      orElse: () => ActionItemRegistry.instance.findById('selectTimetable')!,
    );
    final allGridItems = [
      ...overflowItems,
      // Ensure selectTimetable is always in the grid
      if (!overflowItems.any((item) => item.id == 'selectTimetable'))
        selectTimetable,
    ];

    return Stack(
      children: [
        // Dismissible background layer
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.black54),
        ),
        // Popup content layer
        Center(
          child: GestureDetector(
            onTap: () {},
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              surfaceTintColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.86,
                constraints: const BoxConstraints(maxHeight: 480),
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // drag handle
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Week slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              l10n.weekSliderLabel(_sliderValue.round()),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Slider(
                              value: _sliderValue,
                              min: 1,
                              max: widget.totalWeeks.toDouble(),
                              divisions: widget.totalWeeks - 1,
                              label: l10n.weekSliderLabel(_sliderValue.round()),
                              onChanged: (v) {
                                setState(() => _sliderValue = v);
                              },
                              onChangeEnd: (v) {
                                widget.onWeekChanged(v.round());
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      // Action grid: 4 columns using Wrap
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _buildActionGrid(allGridItems),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(List<ActionItem> items) {
    // All buttons including settings and config
    final allButtons = [
      ...items.map((item) => _ActionGridButtonData(
            label: item.displayNameBuilder(context),
            icon: item.icon,
            onTap: () {
              Vibrate.light();
              Navigator.pop(context);
              item.onPressed(context);
            },
          )),
      _ActionGridButtonData(
        label: l10n.settings,
        icon: Icons.settings,
        onTap: () {
          Vibrate.light();
          Navigator.pop(context);
          context.push('/settings');
        },
      ),
      _ActionGridButtonData(
        label: l10n.configToolbar,
        icon: Icons.tune,
        onTap: () {
          Vibrate.light();
          Navigator.pop(context);
          _showConfigDialog(context, widget.appBarItems, widget.onConfigChanged);
        },
      ),
    ];

    // 4 columns via Wrap
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = (totalWidth - 12) / 4; // 3 gaps of 4px
        return Wrap(
          spacing: 4,
          runSpacing: 8,
          children: allButtons.map((btn) {
            return SizedBox(
              width: itemWidth,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: btn.onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(btn.icon, size: 32,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 4),
                    Text(
                      btn.label,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showConfigDialog(
    BuildContext context,
    List<ActionItem> currentItems,
    VoidCallback onConfigChanged,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _AppBarConfigDialog(
        initialItems: currentItems,
        onSaved: (newItems) async {
          await AppBarConfig.saveActionItems(newItems);
          onConfigChanged();
        },
      ),
    );
  }
}

class _ActionGridButtonData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionGridButtonData({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

// ---------------------------------------------------------------------------
// AppBar 配置弹窗
// ---------------------------------------------------------------------------

class _AppBarConfigDialog extends StatefulWidget {
  final List<ActionItem> initialItems;
  final ValueChanged<List<ActionItem>> onSaved;

  const _AppBarConfigDialog({
    required this.initialItems,
    required this.onSaved,
  });

  @override
  State<_AppBarConfigDialog> createState() => _AppBarConfigDialogState();
}

class _AppBarConfigDialogState extends State<_AppBarConfigDialog> {
  late List<ActionItem> _selected;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialItems);
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ActionItemRegistry.instance.getAll();
    return AlertDialog(
      title: Text(l10n.configToolbar),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.maxAppBarItemsHint(ActionItem.maxAppBarItems),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ...allItems.map((item) {
                final checked = _selected.any((s) => s.id == item.id);
                return CheckboxListTile(
                  value: checked,
                  title: Row(
                    children: [
                      Icon(item.icon, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item.displayNameBuilder(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  onChanged: (v) {
                    Vibrate.light();
                    setState(() {
                      if (v == true) {
                        if (_selected.length >= ActionItem.maxAppBarItems) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${l10n.maxItemsHint} ${ActionItem.maxAppBarItems} 个',
                              ),
                            ),
                          );
                          return;
                        }
                        _selected.add(item);
                      } else {
                        _selected.removeWhere((s) => s.id == item.id);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  dense: true,
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                Vibrate.light();
                final registry = ActionItemRegistry.instance;
                final defaults = [
                  registry.findById('importTimetable'),
                  registry.findById('exportTimetable'),
                ].whereType<ActionItem>().toList();
                setState(() => _selected = List.from(defaults));
                AppBarConfig.resetToDefault();
              },
              child: Text(l10n.resetDefault),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Vibrate.light();
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Vibrate.light();
                widget.onSaved(_selected);
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ],
    );
  }
}
