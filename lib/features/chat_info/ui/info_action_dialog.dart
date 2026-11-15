import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// Shows a confirmation dialog for destructive or administrative actions.
Future<bool?> showInfoActionDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String actionText,
  Color actionColor = AppColors.errorRed,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(actionText, style: TextStyle(color: actionColor)),
        ),
      ],
    ),
  );
}
