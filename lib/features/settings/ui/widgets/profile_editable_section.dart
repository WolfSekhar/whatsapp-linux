import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../theme/app_colors.dart';

/// Editable profile attribute field displaying either a display tile or text field.
class ProfileEditableSection extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEditing;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  const ProfileEditableSection({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isEditing,
    required this.controller,
    required this.onEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 4),
        if (isEditing)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(isDense: true),
                  onSubmitted: (_) => onSave(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  FluentIcons.checkmark_24_regular,
                  color: AppColors.primaryGreen,
                ),
                onPressed: onSave,
              ),
            ],
          )
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(value),
            trailing: IconButton(
              icon: const Icon(FluentIcons.edit_24_regular, size: 18),
              onPressed: onEdit,
            ),
          ),
      ],
    );
  }
}
