import 'dart:async';
import '../../core/ipc/i_ipc_service.dart';
import '../../core/ipc/ipc_message.dart';
import '../../core/storage/message_dao.dart';
import '../../core/storage/reaction_dao.dart';
import '../models/reaction_item.dart';
import 'i_interaction_repository.dart';

/// Concrete implementation of [IInteractionRepository] managing reactions, starring, and revoking.
class InteractionRepository implements IInteractionRepository {
  final IIpcService _ipc;
  final ReactionDao _reactionDao;
  final MessageDao _messageDao;

  final StreamController<ReactionItem> _reactionController =
      StreamController<ReactionItem>.broadcast();
  final StreamController<String> _revokeController =
      StreamController<String>.broadcast();
  StreamSubscription<IpcEvent>? _eventSub;

  InteractionRepository(
    this._ipc, {
    ReactionDao? reactionDao,
    MessageDao? messageDao,
  })  : _reactionDao = reactionDao ?? ReactionDao(),
        _messageDao = messageDao ?? MessageDao() {
    _eventSub = _ipc.allEvents.listen(_onEvent);
  }

  void _onEvent(IpcEvent evt) {
    if (evt.event == 'reaction' && evt.data is Map) {
      final item = ReactionItem.fromJson(Map<String, dynamic>.from(evt.data as Map));
      _reactionDao.saveReaction(item);
      _reactionController.add(item);
    } else if (evt.event == 'revoke' && evt.data is Map) {
      final msgId = (evt.data as Map)['msg_id'] as String? ?? '';
      if (msgId.isNotEmpty) {
        _messageDao.setRevoked(msgId, true);
        _revokeController.add(msgId);
      }
    }
  }

  @override
  Stream<ReactionItem> get reactionStream => _reactionController.stream;

  @override
  Stream<String> get revokeStream => _revokeController.stream;

  @override
  Future<void> sendReaction({
    required String chatJid,
    required String senderJid,
    required String msgId,
    required String emoji,
  }) async {
    final item = ReactionItem(
      msgId: msgId,
      senderJid: 'me',
      emoji: emoji,
      timestamp: DateTime.now(),
    );
    await _reactionDao.saveReaction(item);
    _reactionController.add(item);
    await _ipc.sendRequest('react', {
      'chat_jid': chatJid,
      'sender_jid': senderJid,
      'msg_id': msgId,
      'emoji': emoji,
    });
  }

  @override
  Future<void> starMessage({
    required String chatJid,
    required String senderJid,
    required String msgId,
    required bool fromMe,
    required bool isStarred,
  }) async {
    await _messageDao.setStarred(msgId, isStarred);
    await _ipc.sendRequest('star', {
      'chat_jid': chatJid,
      'sender_jid': senderJid,
      'msg_id': msgId,
      'from_me': fromMe,
      'is_starred': isStarred,
    });
  }

  @override
  Future<void> revokeMessage({
    required String chatJid,
    required String senderJid,
    required String msgId,
  }) async {
    await _messageDao.setRevoked(msgId, true);
    _revokeController.add(msgId);
    await _ipc.sendRequest('revoke', {
      'chat_jid': chatJid,
      'sender_jid': senderJid,
      'msg_id': msgId,
    });
  }

  @override
  Future<void> deleteMessageForMe(String msgId) async {
    await _messageDao.deleteMessage(msgId);
    _revokeController.add(msgId);
  }

  @override
  Future<List<ReactionItem>> getReactions(String msgId) =>
      _reactionDao.getReactions(msgId);

  @override
  void dispose() {
    _eventSub?.cancel();
    _reactionController.close();
    _revokeController.close();
  }
}
