import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(themeSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Interaction settings
          _buildSection(
            context,
            title: l10n.interaction,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: Text(l10n.vibration),
                subtitle: Text(l10n.vibrationSubtitle),
                value: settings.vibrationEnabled,
                onChanged: (v) {
                  ref.read(themeSettingsProvider.notifier).state =
                      settings.copyWith(vibrationEnabled: v);
                  saveThemeSettings(settings.copyWith(vibrationEnabled: v));
                  Vibrate.light();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Other settings
          _buildSection(
            context,
            title: l10n.others,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Vibrate.light();
                  context.push('/about');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  l10n.clearCache,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Vibrate.light();
                  _showClearCacheDialog(context);
                },
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
        title: Text(l10n.clearCache),
        content: Text(l10n.confirmClearCache),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _clearCache();
              if (!mounted) return;
              if (!context.mounted) return;
              showAppSnackBar(context, l10n.cacheCleared);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    try {
      // Clear SharedPreferences (except theme settings)
      final prefs = await SharedPreferences.getInstance();
      final themeKeys = prefs.getKeys().where((key) => 
        key == 'theme_settings_json' || key == 'vibration_enabled'
      ).toSet();
      final themeData = <String, Object>{};
      for (final key in themeKeys) {
        final value = prefs.get(key);
        if (value != null) themeData[key] = value;
      }
      await prefs.clear();
      // Restore theme settings
      for (final entry in themeData.entries) {
        if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value as bool);
        } else if (entry.value is String) {
          await prefs.setString(entry.key, entry.value as String);
        }
      }

      // Clear temporary files
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await for (final entity in tempDir.list()) {
            if (entity is File && entity.path.contains('fl')) {
              await entity.delete();
            }
          }
        }
      } catch (_) {
        // Ignore temp file errors
      }
    } catch (e) {
      // Silently handle cache clear errors
    }
  }
}
