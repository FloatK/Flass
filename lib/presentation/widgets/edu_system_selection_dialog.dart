import 'package:flutter/material.dart';

import '../../data/datasources/edu_parser.dart';

/// 教务系统选择对话框。
///
/// 当自动识别失败时，显示此对话框让用户手动选择教务系统类型。
class EduSystemSelectionDialog extends StatelessWidget {
  final List<EduParser> parsers;
  final void Function(EduParser parser) onSelected;

  const EduSystemSelectionDialog({
    super.key,
    required this.parsers,
    required this.onSelected,
  });

  /// 显示教务系统选择对话框。
  ///
  /// 返回用户选择的解析器，如果取消则返回 null。
  static Future<EduParser?> show(
    BuildContext context,
    List<EduParser> parsers,
  ) {
    return showDialog<EduParser>(
      context: context,
      builder: (context) => EduSystemSelectionDialog(
        parsers: parsers,
        onSelected: (parser) => Navigator.of(context).pop(parser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择教务系统'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: parsers.length,
          itemBuilder: (context, index) {
            final parser = parsers[index];
            return ListTile(
              leading: const Icon(Icons.school),
              title: Text(parser.systemName),
              onTap: () => onSelected(parser),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
