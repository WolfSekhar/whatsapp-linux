import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// Modal dialog allowing users or admins to edit the group description/topic.
class EditGroupDescriptionDialog extends StatefulWidget {
  final String currentTopic;
  final ValueChanged<String> onSave;

  const EditGroupDescriptionDialog({
    super.key,
    required this.currentTopic,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentTopic,
    required ValueChanged<String> onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => EditGroupDescriptionDialog(
        currentTopic: currentTopic,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditGroupDescriptionDialog> createState() =>
      _EditGroupDescriptionDialogState();
}

class _EditGroupDescriptionDialogState
    extends State<EditGroupDescriptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTopic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final text = _controller.text.trim();
    Navigator.of(context).pop();
    widget.onSave(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(FluentIcons.edit_24_regular, color: AppColors.primaryGreen),
          SizedBox(width: 8),
          Text('Edit Group Description', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _controller,
          maxLines: 5,
          minLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Add a group description...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
