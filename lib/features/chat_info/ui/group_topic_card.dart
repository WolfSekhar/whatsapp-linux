import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../controllers/chat_info_controller.dart';
import 'edit_group_description_dialog.dart';
import 'info_section_card.dart';

/// Card displaying group topic/description, creation metadata, and edit action.
class GroupTopicCard extends StatelessWidget {
  final ChatInfoController controller;

  const GroupTopicCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prim = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final sec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final div = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final info = controller.groupInfo;
    final topic = info?.topic.trim().isNotEmpty == true
        ? info!.topic
        : 'No description added';
    final creator = info?.ownerJid?.split('@').first ?? 'Admin';
    final ts = info?.creationTimestamp;
    final created = ts != null
        ? '${ts.day}/${ts.month}/${ts.year}'
        : 'recently';

    return InfoSectionCard(
      children: [
        ListTile(
          title: Text(
            'Group description',
            style: TextStyle(color: sec, fontSize: 12),
          ),
          subtitle: Text(topic, style: TextStyle(color: prim, fontSize: 14)),
          trailing: IconButton(
            icon: const Icon(FluentIcons.edit_20_regular, size: 18),
            tooltip: 'Edit description',
            onPressed: () => EditGroupDescriptionDialog.show(
              context,
              currentTopic: info?.topic ?? '',
              onSave: controller.updateTopic,
            ),
          ),
        ),
        Divider(height: 1, color: div),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(FluentIcons.info_16_regular, size: 16, color: sec),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Created by $creator on $created',
                  style: TextStyle(color: sec, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
