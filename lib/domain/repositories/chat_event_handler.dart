import 'dart:async';
import '../../core/ipc/ipc_message.dart';
import '../../core/storage/chat_dao.dart';
import '../../core/storage/message_dao.dart';
import '../models/chat_item.dart';
import '../models/chat_sorter.dart';
import '../models/message_item.dart';
import 'chat_appstate_handler.dart';

/// Handles inbound IPC chat events and updates memory and SQLite stores.
class ChatEventHandler {
  final ChatDao chatDao;
  final MessageDao messageDao;
  final ChatAppstateHandler appstateHandler;

  ChatEventHandler({
    required this.chatDao,
    required this.messageDao,
    ChatAppstateHandler? appstateHandler,
  }) : appstateHandler = appstateHandler ?? ChatAppstateHandler(chatDao: chatDao);

  void handleIpcEvent({
    required IpcEvent event,
    required List<ChatItem> chats,
    required StreamController<List<ChatItem>> chatsController,
    required StreamController<MessageItem> messageController,
  }) {
    final data = event.data is Map ? Map<String, dynamic>.from(event.data as Map) : null;
    switch (event.event) {
      case 'chat_sync':
        applyChats(chats, event.data is Map ? (event.data as Map)['chats'] : event.data, chatsController);
        break;
      case 'message':
        if (data != null) applyMessage(chats, data, chatsController, messageController);
        break;
      case 'chat_read':
        if (data != null) applyChatRead(chats, data, chatsController);
        break;
      case 'receipt':
        if (data != null) applyReceipt(chats, data, chatsController);
        break;
      case 'chat_pin':
        if (data != null) appstateHandler.applyPin(chats, data, chatsController);
        break;
      case 'chat_archive':
        if (data != null) appstateHandler.applyArchive(chats, data, chatsController);
        break;
      case 'chat_mute':
        if (data != null) appstateHandler.applyMute(chats, data, chatsController);
        break;
    }
  }

  void applyChats(List<ChatItem> chats, dynamic rawList, StreamController<List<ChatItem>> controller) {
    if (rawList is! List) return;
    chats.clear();
    for (final item in rawList) {
      if (item is Map) chats.add(ChatItem.fromJson(Map<String, dynamic>.from(item)));
    }
    sortChats(chats);
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
    sortChats(chats);
    chatsController.add(List.unmodifiable(chats));
  }

  void applyChatRead(List<ChatItem> chats, Map<String, dynamic> data, StreamController<List<ChatItem>> controller) {
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
    final List<String>? msgIds = rawIds is List ? rawIds.map((e) => e.toString()).toList() : null;
    if (isRead) messageDao.markMessagesAsRead(chatJid, msgIds);
  }

  void applyReceipt(List<ChatItem> chats, Map<String, dynamic> data, StreamController<List<ChatItem>> controller) {
    final chatJid = data['chat_jid'] as String? ?? '';
    final type = data['type'] as String? ?? '';
    final fromMe = data['from_me'] as bool? ?? false;
    final rawIds = data['message_ids'];
    final List<String>? msgIds = rawIds is List ? rawIds.map((e) => e.toString()).toList() : null;

    final isRead = type == 'read' || type == 'read-self' || type == 'played';
    if (fromMe && isRead) {
      applyChatRead(chats, {'chat_jid': chatJid, 'read': true, 'message_ids': msgIds}, controller);
      return;
    }
    if (isRead && chatJid.isNotEmpty) messageDao.markMessagesAsRead(chatJid, msgIds);
  }
}
