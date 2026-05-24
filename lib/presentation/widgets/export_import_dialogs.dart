import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/export_utils.dart';
import '../../core/utils/import_utils.dart';
import '../../core/utils/ui_utils.dart';
import '../../data/models/course.dart';
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
    final compact = ExportUtils.compactEncode(courses);

    return AlertDialog(
      title: const Text(AppStrings.shareSchedule),
      content: const Text(AppStrings.chooseExportMethod),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            final copyText = '将该条消息复制，点击从文本导入即可导入课表。\n「$compact」';
            Clipboard.setData(ClipboardData(text: copyText));
            showAppSnackBar(
                context, AppStrings.copiedMessage(compact.length));
          },
          child: const Text(AppStrings.copyCompactCode),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final dir = await getTemporaryDirectory();
              final file = File(
                  '${dir.path}/fl${DateTime.now().microsecondsSinceEpoch}.txt');
              final fileText =
                  '将该条消息复制，点击从文本导入即可导入课表。\n「$compact」';
              await file.writeAsString(fileText);
              await Share.shareXFiles(
                [XFile(file.path)],
                text: '课表数据',
              );
            } catch (e) {
              if (context.mounted) {
                showAppSnackBar(context, '${AppStrings.shareFailed}: $e',
                    isError: true);
              }
            }
          },
          child: const Text(AppStrings.shareFile),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.importFromText),
      content: TextField(
        controller: _controller,
        maxLines: 8,
        decoration: const InputDecoration(
          hintText: AppStrings.pasteCompactHint,
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final clipboardData =
                await Clipboard.getData(Clipboard.kTextPlain);
            if (clipboardData == null || clipboardData.text == null) {
              return;
            }
            _controller.text = clipboardData.text!.trim();
          },
          child: const Text(AppStrings.pasteFromClipboard),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => _parseAndImport(context),
          child: const Text(AppStrings.parse),
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
          showAppSnackBar(context, AppStrings.invalidFormat, isError: true);
        }
        return;
      }
      courses = result;
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, '${AppStrings.importFailed}: $e',
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

    // Show the import choice dialog
    // ImportHelper now uses ConsumerStatefulWidget with its own ref,
    // so no "ref disposed" error will occur
    if (mounted) {
      ImportHelper.showChoiceDialogAndImport(
        context: context,
        courseCount: courses.length,
        courses: courses,
        onOverwrite: overwriteImport,
        onNewSchedule: (r, c, scheduleName) async {
          await newScheduleImport(r, c, scheduleName: scheduleName);
        },
        onComplete: () {
          if (context.mounted) {
            showAppSnackBar(
                context, AppStrings.importCourseCount(courses.length));
          }
        },
      );
    }
  }
}
