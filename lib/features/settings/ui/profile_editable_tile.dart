import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// An editable text tile showing an icon, value, and inline editing field.
class ProfileEditableTile extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final ValueChanged<String> onSave;

  const ProfileEditableTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onSave,
  });

  @override
  State<ProfileEditableTile> createState() => _ProfileEditableTileState();
}

class _ProfileEditableTileState extends State<ProfileEditableTile> {
  final _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEdit() {
    _controller.text = widget.value;
    setState(() => _isEditing = true);
  }

  void _save() {
    widget.onSave(_controller.text.trim());
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 4),
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(isDense: true),
                  onSubmitted: (_) => _save(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  FluentIcons.checkmark_24_regular,
                  color: AppColors.primaryGreen,
                ),
                onPressed: _save,
              ),
            ],
          )
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(widget.icon),
            title: Text(widget.value),
            trailing: IconButton(
              icon: const Icon(FluentIcons.edit_24_regular, size: 18),
              onPressed: _startEdit,
            ),
          ),
      ],
    );
  }
}
