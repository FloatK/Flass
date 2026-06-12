import 'package:flutter/material.dart';

import '../../core/utils/vibrate.dart';
import '../../l10n/app_localizations.dart';

/// Utility class for common dialog patterns.
///
/// Provides standardized confirmation and input dialogs to reduce
/// code duplication across the app.
class AppDialogs {
  AppDialogs._();

  /// Show a confirmation dialog with Cancel and Confirm buttons.
  ///
  /// Returns `true` if the user confirmed, `false` if cancelled.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    bool isDestructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Vibrate.light();
              Navigator.pop(ctx, false);
            },
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Vibrate.light();
              Navigator.pop(ctx, true);
            },
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel ?? l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show a text input dialog with Cancel and Confirm buttons.
  ///
  /// Returns the entered text if confirmed, or `null` if cancelled.
  static Future<String?> textInput(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String? confirmLabel,
    bool autofocus = true,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: initialValue);
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
            autofocus: autofocus,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Vibrate.light();
                Navigator.pop(ctx);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Vibrate.light();
                Navigator.pop(ctx, controller.text.trim());
              },
              child: Text(confirmLabel ?? l10n.confirm),
            ),
          ],
        ),
      );
      return result;
    } finally {
      controller.dispose();
    }
  }

  /// Show a delete confirmation dialog.
  ///
  /// Returns `true` if the user confirmed deletion, `false` if cancelled.
  static Future<bool> confirmDelete(
    BuildContext context, {
    required String itemName,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    return confirm(
      context,
      title: l10n.confirmDeleteTitle,
      message: '${l10n.confirmDeleteMessage}「$itemName」吗？',
      isDestructive: true,
    );
  }
}
