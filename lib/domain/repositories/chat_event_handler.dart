import 'dart:async';
import '../../core/ipc/ipc_message.dart';
import '../../core/storage/chat_dao.dart';
import '../../core/storage/message_dao.dart';
import '../models/chat_item.dart';
import '../models/message_item.dart';

/// Handles inbound IPC chat events and updates memory and SQLite stores.
class ChatEventHandler {
  final ChatDao chatDao;
  final MessageDao messageDao;

  const ChatEventHandler({required this.chatDao, required this.messageDao});

  void handleIpcEvent({
    required IpcEvent event,
    required List<ChatItem> chats,
    required StreamController<List<ChatItem>> chatsController,
    required StreamController<MessageItem> messageController,
  }) {
    switch (event.event) {
      case 'chat_sync':
        final raw = event.data is Map ? (event.data as Map)['chats'] : event.data;
        applyChats(chats, raw, chatsController);
        break;
      case 'message':
        if (event.data is Map) {
          applyMessage(chats, Map<String, dynamic>.from(event.data as Map),
              chatsController, messageController);
        }
        break;
      case 'chat_read':
        if (event.data is Map) {
          applyChatRead(chats, Map<String, dynamic>.from(event.data as Map),
              chatsController);
        }
        break;
      case 'receipt':
        if (event.data is Map) {
          applyReceipt(chats, Map<String, dynamic>.from(event.data as Map),
              chatsController);
        }
        break;
    }
  }

  void applyChats(List<ChatItem> chats, dynamic rawList,
      StreamController<List<ChatItem>> controller) {
    if (rawList is! List) return;
    chats.clear();
    for (final item in rawList) {
      if (item is Map) {
        chats.add(ChatItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    chats.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
    chatDao.saveChats(chats);
    controller.add(List.unmodifiable(chats));
  }

  void applyMessage(
    List<ChatItem> chats,
    Map<String, dynamic> data,
    StreamController<List<ChatItem>> chatsController,
    StreamController<MessageItem> messageController,
  ) {
    final message = MessageItem.fromJson(data);
    messageDao.saveMessage(message);
    messageController.add(message);

    final isUnread = !message.isFromMe && message.status != 'read';
    final idx = chats.indexWhere((c) => c.jid == message.chatJid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(
        lastMessage: message.text,
        lastMessageTimestamp: message.timestamp,
        unreadCount: isUnread ? chats[idx].unreadCount + 1 : chats[idx].unreadCount,
      );
      chatDao.saveChat(chats[idx]);
    } else {
      final newChat = ChatItem(
        jid: message.chatJid,
        name: message.chatJid,
        lastMessage: message.text,
        lastMessageTimestamp: message.timestamp,
        unreadCount: isUnread ? 1 : 0,
      );
      chats.insert(0, newChat);
      chatDao.saveChat(newChat);
    }
    chats.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
    chatsController.add(List.unmodifiable(chats));
  }

  void applyChatRead(List<ChatItem> chats, Map<String, dynamic> data,
      StreamController<List<ChatItem>> controller) {
    final chatJid = data['chat_jid'] as String? ?? '';
    final isRead = data['read'] as bool? ?? true;
    if (chatJid.isEmpty) return;

    final idx = chats.indexWhere((c) => c.jid == chatJid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(unreadCount: isRead ? 0 : 1);
      if (isRead) {
        chatDao.clearUnread(chatJid);
      } else {
        chatDao.saveChat(chats[idx]);
      }
      controller.add(List.unmodifiable(chats));
    }

    final rawIds = data['message_ids'];
    final List<String>? msgIds =
        rawIds is List ? rawIds.map((e) => e.toString()).toList() : null;
    if (isRead) {
      messageDao.markMessagesAsRead(chatJid, msgIds);
    }
  }

  void applyReceipt(List<ChatItem> chats, Map<String, dynamic> data,
      StreamController<List<ChatItem>> controller) {
    final chatJid = data['chat_jid'] as String? ?? '';
    final type = data['type'] as String? ?? '';
    final fromMe = data['from_me'] as bool? ?? false;
    final rawIds = data['message_ids'];
    final List<String>? msgIds =
        rawIds is List ? rawIds.map((e) => e.toString()).toList() : null;

    final isRead = type == 'read' || type == 'read-self' || type == 'played';
    if (fromMe && isRead) {
      applyChatRead(chats, {'chat_jid': chatJid, 'read': true, 'message_ids': msgIds}, controller);
      return;
    }
    if (isRead && chatJid.isNotEmpty) {
      messageDao.markMessagesAsRead(chatJid, msgIds);
    }
  }
}
