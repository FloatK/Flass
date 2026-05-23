import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/ui_utils.dart';
import '../widgets/theme_settings_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _vibrationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  Future<void> _toggleVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', value);
    setState(() {
      _vibrationEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Theme settings
          _buildSection(
            context,
            title: '主题设置',
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text(AppStrings.themeSettings),
                subtitle: const Text('颜色、深色模式、布局'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const ThemeSettingsDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Feedback settings
          _buildSection(
            context,
            title: '交互反馈',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: const Text('震动反馈'),
                subtitle: const Text('点击按钮时震动'),
                value: _vibrationEnabled,
                onChanged: _toggleVibration,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Other settings
          _buildSection(
            context,
            title: '其他',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text(AppStrings.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  AppStrings.clearCache,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _showClearCacheDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearCache),
        content: const Text(AppStrings.confirmClearCache),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              showAppSnackBar(context, AppStrings.cacheCleared);
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
