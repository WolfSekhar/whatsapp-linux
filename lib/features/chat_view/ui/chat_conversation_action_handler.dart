import 'package:material_ui/material_ui.dart';
import '../../../domain/models/message_item.dart';
import '../controllers/conversation_controller.dart';
import 'interactions/message_context_menu.dart';
import 'interactions/reaction_bar.dart';

/// Dispatches context menu actions (reply, react, star, delete) for conversation messages.
class ChatConversationActionHandler {
  static void handleAction({
    required BuildContext context,
    required MessageItem message,
    required MessageMenuAction action,
    required ConversationController controller,
  }) {
    switch (action) {
      case MessageMenuAction.reply:
        controller.setReply(message);
        break;
      case MessageMenuAction.react:
        _showReactionDialog(context, message, controller);
        break;
      case MessageMenuAction.star:
        controller.toggleStar(message);
        break;
      case MessageMenuAction.deleteForEveryone:
        controller.revokeMessage(message);
        break;
      case MessageMenuAction.deleteForMe:
        controller.deleteForMe(message);
        break;
      case MessageMenuAction.copy:
        break;
    }
  }

  static void _showReactionDialog(
    BuildContext context,
    MessageItem message,
    ConversationController controller,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Center(
        child: ReactionBar(
          onReact: (emoji) => controller.react(message, emoji),
          onDismiss: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }
}
