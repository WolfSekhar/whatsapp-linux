import '../models/chat_item.dart';
import '../models/message_item.dart';
import '../models/quoted_item.dart';

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

  /// Sends a text message to [chatJid], optionally replying to a [quoted] message.
  Future<void> sendMessage(String chatJid, String text, {QuotedItem? quoted});

  /// Marks the conversation for [jid] as read.
  Future<void> markAsRead(String jid);

  /// Retrieves cached messages for a given chat.
  Future<List<MessageItem>> getMessages(String chatJid);

  /// Pins or unpins a chat.
  Future<void> pinChat(String jid, bool pin);

  /// Archives or unarchives a chat.
  Future<void> archiveChat(String jid, bool archive);

  /// Mutes or unmutes a chat for a specific duration in seconds (0 = forever).
  Future<void> muteChat(String jid, {int durationSeconds = 0, bool mute = true});

  /// Clears local and remote message history for a chat.
  Future<void> clearChat(String jid);

  /// Deletes a chat session completely.
  Future<void> deleteChat(String jid);

  /// Releases resources and stream subscriptions.
  void dispose();
}
