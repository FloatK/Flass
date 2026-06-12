import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          // App icon - 完整显示
          Center(
            child: Image.asset(
              'assets/app_icon.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          // App name
          Center(
            child: Text(
              'Flass',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.courseTable,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Developer info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.developer,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const _GitHubAvatar(
                        url: 'https://github.com/FloatK.png',
                        fallbackAsset: 'assets/avatar_fallback.png',
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FloatK',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              l10n.independentDeveloper,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.code),
                        tooltip: 'GitHub',
                        onPressed: () => _launchGitHub(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aboutApp,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mainFeatures,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(Icons.import_export, l10n.featureEduImport),
                  _buildFeatureItem(Icons.share, l10n.featureCompactShare),
                  _buildFeatureItem(Icons.calendar_month, l10n.featureMultiSchedule),
                  _buildFeatureItem(Icons.palette, l10n.featureThemeCustom),
                  _buildFeatureItem(Icons.view_week, l10n.featureWeekView),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final uri = Uri.parse('https://github.com/FloatK');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Silently handle launch errors
    }
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

/// GitHub 头像组件，支持网络加载 + 本地 fallback
class _GitHubAvatar extends StatelessWidget {
  final String url;
  final String fallbackAsset;
  final double radius;

  const _GitHubAvatar({
    required this.url,
    required this.fallbackAsset,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(fallbackAsset),
      foregroundImage: NetworkImage(url),
      onForegroundImageError: (_, _) {},
    );
  }
}
