import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../chat_view/ui/media_viewer_dialog.dart';
import '../controllers/chat_info_controller.dart';
import 'group_participants_card.dart';
import 'group_topic_card.dart';
import 'info_action_dialog.dart';
import 'info_section_card.dart';

/// Panel displaying group details, settings, and participant management.
class GroupDetailsPanel extends StatelessWidget {
  final ChatInfoController controller;

  const GroupDetailsPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        GroupTopicCard(controller: controller),
        const SizedBox(height: 12),
        InfoSectionCard(
          children: [
            ListTile(
              leading: const Icon(
                FluentIcons.image_20_regular,
                size: 20,
                color: AppColors.tealGreen,
              ),
              title: Text(
                'Media, links and docs',
                style: TextStyle(color: textPrim, fontSize: 14),
              ),
              trailing: Icon(
                FluentIcons.chevron_right_20_regular,
                size: 16,
                color: textSec,
              ),
              onTap: () => MediaViewerDialog.show(
                context,
                title: 'Group Media',
                subtitle: controller.chat.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GroupParticipantsCard(controller: controller),
        const SizedBox(height: 12),
        InfoSectionCard(
          children: [
            ListTile(
              leading: const Icon(
                FluentIcons.arrow_exit_20_regular,
                size: 20,
                color: AppColors.errorRed,
              ),
              title: const Text(
                'Exit group',
                style: TextStyle(color: AppColors.errorRed, fontSize: 14),
              ),
              onTap: () => _handleExitGroup(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleExitGroup(BuildContext context) async {
    final ok = await showInfoActionDialog(
      context,
      title: 'Exit group?',
      content: 'Exit "${controller.chat.name}" group?',
      actionText: 'Exit Group',
    );
    if (ok == true) {
      await controller.leaveGroup();
    }
  }
}
