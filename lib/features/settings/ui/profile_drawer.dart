import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'widgets/profile_editable_section.dart';

/// Profile drawer panel displaying avatar, editable name, about, and phone.
class ProfileDrawer extends StatefulWidget {
  final SettingsController controller;
  final VoidCallback? onClose;

  const ProfileDrawer({super.key, required this.controller, this.onClose});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _editingName = false;
  bool _editingAbout = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _saveName() {
    widget.controller.updateProfile(name: _nameController.text.trim());
    setState(() => _editingName = false);
  }

  void _saveAbout() {
    widget.controller.updateProfile(about: _aboutController.text.trim());
    setState(() => _editingAbout = false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 380,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final profile = widget.controller.profile;
            final name = profile?.name ?? 'Me';
            final about = profile?.about ?? 'Hey there! I am using WhatsApp.';
            final phone = profile?.phone.isNotEmpty == true ? profile!.phone : 'Not available';

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildAvatar(),
                const SizedBox(height: 28),
                ProfileEditableSection(
                  label: 'Your name',
                  value: name,
                  icon: FluentIcons.person_24_regular,
                  isEditing: _editingName,
                  controller: _nameController,
                  onEdit: () {
                    _nameController.text = name;
                    setState(() => _editingName = true);
                  },
                  onSave: _saveName,
                ),
                const Divider(height: 32),
                ProfileEditableSection(
                  label: 'About',
                  value: about,
                  icon: FluentIcons.info_24_regular,
                  isEditing: _editingAbout,
                  controller: _aboutController,
                  onEdit: () {
                    _aboutController.text = about;
                    setState(() => _editingAbout = true);
                  },
                  onSave: _saveAbout,
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(FluentIcons.phone_24_regular),
                  title: const Text('Phone number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(phone, style: const TextStyle(fontSize: 15)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(FluentIcons.arrow_left_24_regular),
          onPressed: widget.onClose ?? () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 54,
            child: Icon(FluentIcons.person_24_regular, size: 54),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryGreen,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(FluentIcons.camera_24_regular, size: 16, color: Colors.white),
                onPressed: () {},
                tooltip: 'Change profile picture',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
