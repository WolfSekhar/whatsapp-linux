import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../theme/app_colors.dart';
import '../../controllers/settings_controller.dart';
import '../dialogs/blocked_contacts_dialog.dart';

/// Privacy tab providing controls for visibility, read receipts, and blocklist.
class PrivacyTab extends StatefulWidget {
  final SettingsController controller;

  const PrivacyTab({super.key, required this.controller});

  @override
  State<PrivacyTab> createState() => _PrivacyTabState();
}

class _PrivacyTabState extends State<PrivacyTab> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final privacy = widget.controller.privacy;
        final lastSeen = privacy?.lastSeen ?? 'all';
        final photo = privacy?.profilePhoto ?? 'all';
        final about = privacy?.about ?? 'all';
        final blocklist = privacy?.blocklist ?? const [];

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('Who can see my personal info'),
            const SizedBox(height: 8),
            _buildDropdownTile(
              icon: FluentIcons.clock_24_regular,
              title: 'Last Seen & Online',
              value: lastSeen,
              onChanged: (val) {
                if (val != null) {
                  widget.controller.updatePrivacy('last_seen', val);
                }
              },
            ),
            _buildDropdownTile(
              icon: FluentIcons.person_square_24_regular,
              title: 'Profile Photo',
              value: photo,
              onChanged: (val) {
                if (val != null) {
                  widget.controller.updatePrivacy('profile_photo', val);
                }
              },
            ),
            _buildDropdownTile(
              icon: FluentIcons.info_24_regular,
              title: 'About',
              value: about,
              onChanged: (val) {
                if (val != null) {
                  widget.controller.updatePrivacy('about', val);
                }
              },
            ),
            const Divider(height: 32),
            _buildSectionHeader('Messaging'),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(FluentIcons.checkmark_circle_24_regular),
              title: const Text('Read Receipts'),
              subtitle: const Text(
                'If turned off, you won\'t send or receive read receipts.',
              ),
              value: privacy?.readReceiptsEnabled ?? true,
              onChanged: (val) {
                widget.controller.updatePrivacy(
                  'read_receipts',
                  val ? 'all' : 'none',
                );
              },
            ),
            const Divider(height: 32),
            _buildSectionHeader('Security & Contacts'),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(FluentIcons.person_prohibited_24_regular),
              title: const Text('Blocked Contacts'),
              subtitle: Text('${blocklist.length} contacts blocked'),
              trailing: const Icon(FluentIcons.chevron_right_24_regular),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) =>
                      BlockedContactsDialog(controller: widget.controller),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final valid = ['all', 'contacts', 'none'].contains(value) ? value : 'all';
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: valid,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('Everyone')),
          DropdownMenuItem(value: 'contacts', child: Text('My Contacts')),
          DropdownMenuItem(value: 'none', child: Text('Nobody')),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
