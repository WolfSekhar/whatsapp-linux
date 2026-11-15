import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../theme/app_colors.dart';
import '../../controllers/settings_controller.dart';

/// Modal dialog displaying blocked contacts with unblock and add-block actions.
class BlockedContactsDialog extends StatefulWidget {
  final SettingsController controller;

  const BlockedContactsDialog({super.key, required this.controller});

  @override
  State<BlockedContactsDialog> createState() => _BlockedContactsDialogState();
}

class _BlockedContactsDialogState extends State<BlockedContactsDialog> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _showAddBlockPrompt() {
    _addController.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block Contact'),
        content: TextField(
          controller: _addController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Phone number or JID',
            hintText: 'e.g. +1234567890 or user@s.whatsapp.net',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = _addController.text.trim();
              if (text.isNotEmpty) {
                final jid = text.contains('@') ? text : '$text@s.whatsapp.net';
                widget.controller.toggleBlockContact(jid, true);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 440,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  FluentIcons.person_prohibited_24_regular,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Blocked Contacts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.dismiss_24_regular),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showAddBlockPrompt,
              icon: const Icon(FluentIcons.person_add_24_regular, size: 18),
              label: const Text('Block Contact'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  final list = widget.controller.privacy?.blocklist ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No blocked contacts',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final jid = list[index];
                      final display = jid.replaceAll('@s.whatsapp.net', '');
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(FluentIcons.person_24_regular, size: 20),
                        ),
                        title: Text(display),
                        subtitle: Text(jid, style: const TextStyle(fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(FluentIcons.person_delete_24_regular,
                              color: Colors.redAccent),
                          tooltip: 'Unblock',
                          onPressed: () =>
                              widget.controller.toggleBlockContact(jid, false),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
