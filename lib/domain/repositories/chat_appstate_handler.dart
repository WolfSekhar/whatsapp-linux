import 'dart:async';
import '../../core/storage/chat_dao.dart';
import '../models/chat_item.dart';
import '../models/chat_sorter.dart';

/// Handles inbound IPC appstate events (pin, archive, mute) and synchronizes storage.
class ChatAppstateHandler {
  final ChatDao chatDao;

  const ChatAppstateHandler({required this.chatDao});

  void applyPin(
    List<ChatItem> chats,
    Map<String, dynamic> data,
    StreamController<List<ChatItem>> controller,
  ) {
    final chatJid = data['chat_jid'] as String? ?? '';
    final pinned = data['pinned'] as bool? ?? false;
    final idx = chats.indexWhere((c) => c.jid == chatJid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(isPinned: pinned);
      sortChats(chats);
      chatDao.setPinned(chatJid, pinned);
      controller.add(List.unmodifiable(chats));
    }
  }

  void applyArchive(
    List<ChatItem> chats,
    Map<String, dynamic> data,
    StreamController<List<ChatItem>> controller,
  ) {
    final chatJid = data['chat_jid'] as String? ?? '';
    final archived = data['archived'] as bool? ?? false;
    final idx = chats.indexWhere((c) => c.jid == chatJid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(isArchived: archived);
      sortChats(chats);
      chatDao.setArchived(chatJid, archived);
      controller.add(List.unmodifiable(chats));
    }
  }

  void applyMute(
    List<ChatItem> chats,
    Map<String, dynamic> data,
    StreamController<List<ChatItem>> controller,
  ) {
    final chatJid = data['chat_jid'] as String? ?? '';
    final muteUntil = (data['mute_until'] as num?)?.toInt() ?? 0;
    final idx = chats.indexWhere((c) => c.jid == chatJid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(muteUntil: muteUntil);
      chatDao.setMute(chatJid, muteUntil);
      controller.add(List.unmodifiable(chats));
    }
  }
}
