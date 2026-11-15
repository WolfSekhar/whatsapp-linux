import '../models/chat_item.dart';
import '../models/message_item.dart';

/// Contract for managing WhatsApp chats and messages.
abstract interface class IChatRepository {
  /// Stream emitting real-time updates to the list of conversations.
  Stream<List<ChatItem>> get chatsStream;

  /// Stream emitting incoming or outgoing messages.
  Stream<MessageItem> get messageStream;

  /// Cached snapshot of current chats.
  List<ChatItem> get currentChats;

  /// Retrieves the list of chats from the daemon.
  Future<List<ChatItem>> getChats();

  /// Refreshes chats from the daemon.
  Future<void> fetchChats();

  /// Sends a text message to [chatJid].
  Future<void> sendMessage(String chatJid, String text);

  /// Marks the conversation for [jid] as read.
  Future<void> markAsRead(String jid);

  /// Retrieves cached messages for a given chat.
  Future<List<MessageItem>> getMessages(String chatJid);

  /// Releases resources and stream subscriptions.
  void dispose();
}
