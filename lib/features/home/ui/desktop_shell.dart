import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../chat_view/chat_view.dart';
import '../../shell/shell.dart';
import '../controllers/chat_controller.dart';
import 'chat_list_view.dart';
import 'empty_chat_view.dart';
import '../../../theme/app_colors.dart';

/// Top-level desktop shell providing three-pane native Linux layout.
class DesktopShell extends StatelessWidget {
  final ChatController controller;

  const DesktopShell({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NativeWindowHeader(
        statusText: 'Connected',
        isConnected: true,
      ),
      body: Row(
        children: [
          _buildRail(context),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 360,
            child: ChatListView(controller: controller),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final chat = controller.selectedChat;
                if (chat == null) {
                  return const EmptyChatView();
                }
                return ChatConversationView(
                  chat: chat,
                  repository: controller.chatRepository,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final railBg = isDark ? AppColors.darkRail : AppColors.lightRail;

    return Container(
      width: 58,
      color: railBg,
      child: Column(
        children: [
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(
              FluentIcons.chat_24_filled,
              color: AppColors.primaryGreen,
              size: 22,
            ),
            tooltip: 'Chats',
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(FluentIcons.settings_24_regular, size: 22),
            tooltip: 'Settings',
            onPressed: () {},
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 16,
            child: Icon(FluentIcons.person_24_regular, size: 18),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
