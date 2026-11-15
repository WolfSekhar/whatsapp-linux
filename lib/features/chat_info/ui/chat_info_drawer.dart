import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../controllers/chat_info_controller.dart';
import 'contact_details_panel.dart';
import 'group_details_panel.dart';

/// Right-side desktop inspection drawer for group and 1-on-1 chats.
class ChatInfoDrawer extends StatelessWidget {
  final ChatInfoController controller;
  final VoidCallback onClose;

  const ChatInfoDrawer({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final chat = controller.chat;
        return Container(
          width: 360,
          decoration: BoxDecoration(
            color: panelBg,
            border: Border(left: BorderSide(color: borderCol, width: 1)),
          ),
          child: Column(
            children: [
              _buildHeader(context, chat.isGroup),
              const Divider(height: 1),
              _buildTopBanner(context),
              const Divider(height: 1),
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (chat.isGroup
                          ? GroupDetailsPanel(controller: controller)
                          : ContactDetailsPanel(controller: controller)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isGroup) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.dismiss_24_regular, size: 20),
            tooltip: 'Close',
            onPressed: onClose,
          ),
          const SizedBox(width: 12),
          Text(
            isGroup ? 'Group info' : 'Contact info',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    final chat = controller.chat;
    final name = chat.isGroup
        ? (controller.groupInfo?.topic.isNotEmpty == true
              ? controller.groupInfo!.topic
              : chat.name)
        : (controller.contactInfo?.displayName.isNotEmpty == true
              ? controller.contactInfo!.displayName
              : chat.name);

    final clean = name.replaceAll('+', '').trim();
    final initial = clean.isNotEmpty ? clean[0].toUpperCase() : '?';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final subtitle = chat.isGroup
        ? 'Group • ${controller.groupInfo?.participants.length ?? 0} members'
        : (controller.contactInfo?.phone ??
              (chat.jid.endsWith('@s.whatsapp.net')
                  ? '+${chat.jid.split('@').first}'
                  : chat.jid));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.tealGreen,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: secColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
