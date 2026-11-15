import 'dart:async';
import '../../core/ipc/i_ipc_service.dart';
import '../../core/ipc/ipc_message.dart';
import '../../core/storage/chat_dao.dart';
import '../../core/storage/message_dao.dart';
import '../models/chat_item.dart';
import '../models/message_item.dart';
import '../models/quoted_item.dart';
import 'chat_event_handler.dart';
import 'chat_mutation_handler.dart';
import 'i_chat_repository.dart';

/// Concrete implementation of [IChatRepository] communicating via IPC and SQLite cache.
class ChatRepository implements IChatRepository {
  final IIpcService _ipcService;
  final ChatDao _chatDao;
  final MessageDao _messageDao;
  final ChatEventHandler _eventHandler;
  final ChatMutationHandler _mutationHandler;
  final List<ChatItem> _chats = [];
  final StreamController<List<ChatItem>> _chatsController =
      StreamController<List<ChatItem>>.broadcast();
  final StreamController<MessageItem> _messageController =
      StreamController<MessageItem>.broadcast();
  StreamSubscription<IpcEvent>? _eventSubscription;

  ChatRepository(
    this._ipcService, {
    ChatDao? chatDao,
    MessageDao? messageDao,
    ChatEventHandler? eventHandler,
    ChatMutationHandler? mutationHandler,
  })  : _chatDao = chatDao ?? ChatDao(),
        _messageDao = messageDao ?? MessageDao(),
        _eventHandler = eventHandler ??
            ChatEventHandler(
              chatDao: chatDao ?? ChatDao(),
              messageDao: messageDao ?? MessageDao(),
            ),
        _mutationHandler = mutationHandler ??
            ChatMutationHandler(
              ipcService: _ipcService,
              chatDao: chatDao ?? ChatDao(),
              messageDao: messageDao ?? MessageDao(),
            ) {
    _eventSubscription = _ipcService.allEvents.listen(_handleIpcEvent);
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final cached = await _chatDao.getChats();
    if (cached.isNotEmpty && _chats.isEmpty) {
      _chats.addAll(cached);
      _chatsController.add(List.unmodifiable(_chats));
    }
  }

  void _handleIpcEvent(IpcEvent event) {
    _eventHandler.handleIpcEvent(
      event: event,
      chats: _chats,
      chatsController: _chatsController,
      messageController: _messageController,
    );
  }

  @override
  Stream<List<ChatItem>> get chatsStream => _chatsController.stream;

  @override
  Stream<MessageItem> get messageStream => _messageController.stream;

  @override
  List<ChatItem> get currentChats => List.unmodifiable(_chats);

  @override
  Future<List<ChatItem>> getChats() async {
    try {
      final res = await _ipcService.sendRequest('get_chats');
      _eventHandler.applyChats(_chats, res['chats'] ?? res['data'], _chatsController);
    } catch (_) {}
    return List.unmodifiable(_chats);
  }

  @override
  Future<void> fetchChats() => getChats();

  @override
  Future<List<MessageItem>> getMessages(String chatJid) async {
    final cached = await _messageDao.getMessages(chatJid);
    try {
      await _ipcService.sendRequest('get_messages', {'chat_jid': chatJid});
    } catch (_) {}
    return cached;
  }

  @override
  Future<void> sendMessage(String chatJid, String text, {QuotedItem? quoted}) async {
    final params = <String, dynamic>{'chat_jid': chatJid, 'text': text};
    if (quoted != null) {
      params['quoted_id'] = quoted.id;
      params['quoted_sender'] = quoted.senderJid;
      params['quoted_text'] = quoted.text;
    }
    await _ipcService.sendRequest('send_message', params);
  }

  @override
  Future<void> markAsRead(String jid) async {
    final idx = _chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      _chats[idx] = _chats[idx].copyWith(unreadCount: 0);
      _chatsController.add(List.unmodifiable(_chats));
      await _chatDao.clearUnread(jid);
    }
    await _messageDao.markMessagesAsRead(jid);
    try {
      await _ipcService.sendRequest('mark_as_read', {'jid': jid});
    } catch (_) {}
  }

  @override
  Future<void> pinChat(String jid, bool pin) =>
      _mutationHandler.pinChat(_chats, _chatsController, jid, pin);

  @override
  Future<void> archiveChat(String jid, bool archive) =>
      _mutationHandler.archiveChat(_chats, _chatsController, jid, archive);

  @override
  Future<void> muteChat(String jid, {int durationSeconds = 0, bool mute = true}) =>
      _mutationHandler.muteChat(_chats, _chatsController, jid, durationSeconds, mute);

  @override
  Future<void> clearChat(String jid) =>
      _mutationHandler.clearChat(_chats, _chatsController, jid);

  @override
  Future<void> deleteChat(String jid) =>
      _mutationHandler.deleteChat(_chats, _chatsController, jid);

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _chatsController.close();
    _messageController.close();
  }
}
