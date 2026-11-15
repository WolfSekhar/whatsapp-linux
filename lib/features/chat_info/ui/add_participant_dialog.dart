import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// Modal dialog allowing an admin to add a participant by phone number or JID.
class AddParticipantDialog extends StatefulWidget {
  final ValueChanged<String> onAdd;

  const AddParticipantDialog({super.key, required this.onAdd});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onAdd,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AddParticipantDialog(onAdd: onAdd),
    );
  }

  @override
  State<AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<AddParticipantDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  void _handleAdd() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Please enter a phone number or JID');
      return;
    }
    final jid = raw.contains('@') ? raw : '$raw@s.whatsapp.net';
    Navigator.of(context).pop();
    widget.onAdd(jid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            FluentIcons.person_add_24_regular,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 8),
          Text('Add Participant', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter phone number with country code (e.g. 15551234567) or WhatsApp JID:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 15551234567',
                errorText: _error,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(FluentIcons.phone_24_regular, size: 20),
              ),
              onSubmitted: (_) => _handleAdd(),
            ),
          ],
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
          onPressed: _handleAdd,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
