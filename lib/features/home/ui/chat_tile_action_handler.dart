import '../../../domain/chat.dart';
import '../controllers/chat_controller.dart';
import 'chat_tile_context_menu.dart';

/// Handles context menu actions on chat list tiles.
class ChatTileActionHandler {
  const ChatTileActionHandler._();

  static void handle({
    required ChatTileMenuAction action,
    required Chat chat,
    required ChatController controller,
  }) {
    switch (action) {
      case ChatTileMenuAction.pin:
        controller.pinChat(chat.jid, true);
        break;
      case ChatTileMenuAction.unpin:
        controller.pinChat(chat.jid, false);
        break;
      case ChatTileMenuAction.markRead:
        controller.markAsRead(chat.jid);
        break;
      case ChatTileMenuAction.markUnread:
        controller.markAsUnread(chat.jid);
        break;
      case ChatTileMenuAction.archive:
        controller.archiveChat(chat.jid, true);
        break;
      case ChatTileMenuAction.unarchive:
        controller.archiveChat(chat.jid, false);
        break;
      case ChatTileMenuAction.mute:
        controller.muteChat(chat.jid, mute: !chat.isMuted);
        break;
      case ChatTileMenuAction.clear:
        controller.clearChat(chat.jid);
        break;
      case ChatTileMenuAction.delete:
        controller.deleteChat(chat.jid);
        break;
    }
  }
}
