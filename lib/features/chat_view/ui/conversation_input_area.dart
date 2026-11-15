import 'package:material_ui/material_ui.dart';
import '../controllers/conversation_controller.dart';
import 'interactions/reply_input_banner.dart';
import 'media_viewer_dialog.dart';
import 'message_input_bar.dart';

/// Bottom section containing the reply preview banner and message input bar.
class ConversationInputArea extends StatelessWidget {
  final ConversationController controller;
  final String chatName;

  const ConversationInputArea({
    super.key,
    required this.controller,
    required this.chatName,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final quote = controller.activeQuote;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (quote != null)
              ReplyInputBanner(
                quoted: quote,
                onDismiss: controller.clearReply,
              ),
            MessageInputBar(
              onSend: controller.sendMessage,
              onAttach: () => MediaViewerDialog.show(
                context,
                title: 'Media Viewer',
                subtitle: chatName,
              ),
            ),
          ],
        );
      },
    );
  }
}
