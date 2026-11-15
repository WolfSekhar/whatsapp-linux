import 'package:material_ui/material_ui.dart';
import '../../../domain/chat.dart';
import '../../../theme/app_colors.dart';
import '../controllers/conversation_controller.dart';
import 'chat_conversation_action_handler.dart';
import 'media_viewer_dialog.dart';
import 'message_bubble.dart';

/// Scrollable message history list displaying bubbles with interactions and empty state.
class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  final ConversationController controller;
  final Chat chat;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.controller,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final msgs = controller.messages;
    if (msgs.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Type below to start.',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: msgs.length,
      itemBuilder: (context, i) {
        final msg = msgs[i];
        return MessageBubble(
          message: msg,
          reactions: controller.getReactions(msg.id),
          onReactionTap: (emoji) => controller.react(msg, emoji),
          onMenuAction: (action) => ChatConversationActionHandler.handleAction(
            context: context,
            message: msg,
            action: action,
            controller: controller,
          ),
          onMediaTap: () => MediaViewerDialog.show(
            context,
            title: msg.fileName ?? chat.name,
            subtitle: chat.name,
            mediaType: msg.mediaType,
            localPath: msg.localPath,
            onDownload: () => controller.downloadMedia(msg),
          ),
          onOpen: () => controller.openMedia(msg),
          onDownload: () => controller.downloadMedia(msg),
        );
      },
    );
  }
}
