import 'dart:async';
import '../../core/ipc/i_ipc_service.dart';
import '../../core/storage/chat_dao.dart';
import '../../core/storage/message_dao.dart';
import '../models/chat_item.dart';
import '../models/chat_sorter.dart';

/// Coordinates outbound chat mutations (pin, archive, mute, clear, delete) across memory, SQLite, and IPC.
class ChatActionManager {
  final IIpcService ipcService;
  final ChatDao chatDao;
  final MessageDao messageDao;

  const ChatActionManager({
    required this.ipcService,
    required this.chatDao,
    required this.messageDao,
  });

  Future<void> pinChat(List<ChatItem> chats, StreamController<List<ChatItem>> controller, String jid, bool pin) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(isPinned: pin);
      sortChats(chats);
      controller.add(List.unmodifiable(chats));
      await chatDao.setPinned(jid, pin);
    }
    try {
      await ipcService.sendRequest('pin_chat', {'jid': jid, 'pin': pin});
    } catch (_) {}
  }

  Future<void> archiveChat(List<ChatItem> chats, StreamController<List<ChatItem>> controller, String jid, bool archive) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(isArchived: archive, isPinned: archive ? false : chats[idx].isPinned);
      sortChats(chats);
      controller.add(List.unmodifiable(chats));
      await chatDao.setArchived(jid, archive);
    }
    try {
      await ipcService.sendRequest('archive_chat', {'jid': jid, 'archive': archive});
    } catch (_) {}
  }

  Future<void> muteChat(
    List<ChatItem> chats,
    StreamController<List<ChatItem>> controller,
    String jid, {
    int durationSeconds = 0,
    bool mute = true,
  }) async {
    final muteUntil = mute ? (durationSeconds > 0 ? (DateTime.now().millisecondsSinceEpoch ~/ 1000) + durationSeconds : -1) : 0;
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(muteUntil: muteUntil);
      controller.add(List.unmodifiable(chats));
      await chatDao.setMute(jid, muteUntil);
    }
    try {
      await ipcService.sendRequest('mute_chat', {'jid': jid, 'mute': mute, 'duration': durationSeconds});
    } catch (_) {}
  }

  Future<void> clearChat(List<ChatItem> chats, StreamController<List<ChatItem>> controller, String jid) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(lastMessage: '', unreadCount: 0);
      controller.add(List.unmodifiable(chats));
      await chatDao.saveChat(chats[idx]);
    }
    await messageDao.deleteChatMessages(jid);
    try {
      await ipcService.sendRequest('clear_chat', {'jid': jid});
    } catch (_) {}
  }

  Future<void> deleteChat(List<ChatItem> chats, StreamController<List<ChatItem>> controller, String jid) async {
    chats.removeWhere((c) => c.jid == jid);
    controller.add(List.unmodifiable(chats));
    await chatDao.deleteChat(jid);
    await messageDao.deleteChatMessages(jid);
    try {
      await ipcService.sendRequest('delete_chat', {'jid': jid});
    } catch (_) {}
  }
}
