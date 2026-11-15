import 'chat_item.dart';

/// Sorts chat list by pinned status first, then by latest message timestamp descending.
void sortChats(List<ChatItem> chats) {
  chats.sort((a, b) {
    if (a.isPinned != b.isPinned) {
      return a.isPinned ? -1 : 1;
    }
    return b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp);
  });
}
