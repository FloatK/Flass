import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/export_utils.dart';
import '../../core/utils/import_utils.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../data/models/course.dart';
import '../../l10n/app_localizations.dart';
import '../utils/import_helper.dart';

/// 课表导出对话框。
class ExportDialog extends StatelessWidget {
  final List<Course> courses;

  const ExportDialog({super.key, required this.courses});

  /// 显示导出对话框。
  static void show(BuildContext context, List<Course> courses) {
    if (courses.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => ExportDialog(courses: courses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compact = ExportUtils.compactEncode(courses);

    return AlertDialog(
      title: Text(l10n.shareSchedule),
      content: Text(l10n.chooseExportMethod),
      actions: [
        TextButton(
          onPressed: () {
            Vibrate.light();
            Navigator.pop(context);
            final copyText = l10n.exportCopyMessage(compact);
            Clipboard.setData(ClipboardData(text: copyText));
            showAppSnackBar(
                context, l10n.copiedMessage(compact.length));
          },
          child: Text(l10n.copyCompactCode),
        ),
        TextButton(
          onPressed: () async {
            Vibrate.light();
            Navigator.pop(context);
            File? tempFile;
            try {
              final dir = await getTemporaryDirectory();
              tempFile = File(
                  '${dir.path}/fl${DateTime.now().microsecondsSinceEpoch}.txt');
              final fileText = l10n.exportCopyMessage(compact);
              await tempFile.writeAsString(fileText);
              await Share.shareXFiles(
                [XFile(tempFile.path)],
                text: l10n.scheduleData,
              );
            } catch (e) {
              if (context.mounted) {
                showAppSnackBar(context, '${l10n.shareFailed}: $e',
                    isError: true);
              }
            } finally {
              // Clean up temp file after sharing
              try {
                if (tempFile != null && await tempFile.exists()) {
                  await tempFile.delete();
                }
              } catch (_) {
                // Ignore cleanup errors
              }
            }
          },
          child: Text(l10n.shareFile),
        ),
        TextButton(
          onPressed: () {
            Vibrate.light();
            Navigator.pop(context);
          },
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

/// 从文本导入对话框。
class ImportFromTextDialog extends ConsumerStatefulWidget {
  const ImportFromTextDialog({super.key});

  /// 显示从文本导入对话框。
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ImportFromTextDialog(),
    );
  }

  @override
  ConsumerState<ImportFromTextDialog> createState() =>
      _ImportFromTextDialogState();
}

class _ImportFromTextDialogState extends ConsumerState<ImportFromTextDialog> {
  final _controller = TextEditingController();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l10n.importFromText),
      content: TextField(
        controller: _controller,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: l10n.pasteCompactHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Vibrate.light();
            final clipboardData =
                await Clipboard.getData(Clipboard.kTextPlain);
            if (clipboardData == null || clipboardData.text == null) {
              return;
            }
            _controller.text = clipboardData.text!.trim();
          },
          child: Text(l10n.pasteFromClipboard),
        ),
        TextButton(
          onPressed: () {
            Vibrate.light();
            Navigator.pop(context);
          },
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Vibrate.light();
            _parseAndImport(context);
          },
          child: Text(l10n.parse),
        ),
      ],
    );
  }

  Future<void> _parseAndImport(BuildContext context) async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    List<Course> courses;
    try {
      final result = ImportUtils.parseAndPrepareImport(text);
      if (result == null) {
        if (mounted) {
          showAppSnackBar(context, l10n.invalidFormat, isError: true);
        }
        return;
      }
      courses = result;
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, '${l10n.importFailed}: $e',
            isError: true);
      }
      return;
    }

    // Close the text input dialog first
    if (mounted) {
      Navigator.pop(context);
    }

    // Wait a frame to ensure the dialog is fully closed
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;
    ImportHelper.showChoiceDialogAndImport(
      // ignore: use_build_context_synchronously
      context: context,
      courseCount: courses.length,
      courses: courses,
      onOverwrite: overwriteImport,
      onNewSchedule: (r, c, scheduleName) async {
        await newScheduleImport(r, c, scheduleName: scheduleName);
      },
      onComplete: () {
        if (!mounted) return;
        showAppSnackBar(
            context, l10n.importCourseCount(courses.length));
      },
    );
  }
}
