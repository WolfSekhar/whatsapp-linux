import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../chat_view/ui/media_viewer_dialog.dart';
import '../controllers/chat_info_controller.dart';
import 'contact_phone_tile.dart';
import 'info_action_dialog.dart';
import 'info_section_card.dart';

/// Panel displaying 1-on-1 contact information, status bio, and actions.
class ContactDetailsPanel extends StatelessWidget {
  final ChatInfoController controller;

  const ContactDetailsPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final divider = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final contact = controller.contactInfo;
    final jid = controller.chat.jid;
    final phone =
        contact?.phone ??
        (jid.endsWith('@s.whatsapp.net') ? '+${jid.split('@').first}' : jid);
    final about = contact?.about?.isNotEmpty == true
        ? contact!.about!
        : 'Available';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        InfoSectionCard(
          children: [
            InfoTile(
              icon: FluentIcons.info_20_regular,
              title: 'About',
              subtitle: about,
              primaryColor: textPrim,
              secondaryColor: textSec,
            ),
            Divider(height: 1, color: divider),
            ContactPhoneTile(
              phone: phone,
              primaryColor: textPrim,
              secondaryColor: textSec,
            ),
          ],
        ),
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
                title: 'Media Gallery',
                subtitle: controller.chat.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InfoSectionCard(
          children: [
            InfoTile(
              icon: FluentIcons.lock_closed_20_regular,
              iconColor: AppColors.viridian,
              title: 'Encryption',
              subtitle: 'Messages are end-to-end encrypted',
              primaryColor: textPrim,
              secondaryColor: textSec,
            ),
          ],
        ),
        const SizedBox(height: 12),
        InfoSectionCard(
          children: [
            ListTile(
              leading: const Icon(
                FluentIcons.prohibited_20_regular,
                size: 20,
                color: AppColors.errorRed,
              ),
              title: Text(
                'Block ${controller.chat.name}',
                style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
              ),
              onTap: () => showInfoActionDialog(
                context,
                title: 'Block Contact',
                content: 'Are you sure you want to block this contact?',
                actionText: 'Block',
              ),
            ),
            Divider(height: 1, color: divider),
            ListTile(
              leading: const Icon(
                FluentIcons.thumb_dislike_20_regular,
                size: 20,
                color: AppColors.errorRed,
              ),
              title: Text(
                'Report ${controller.chat.name}',
                style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
              ),
              onTap: () => showInfoActionDialog(
                context,
                title: 'Report Contact',
                content:
                    'Report this contact to WhatsApp? Block and clear chat.',
                actionText: 'Report',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
