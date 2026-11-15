// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_whatsapp/core/ipc/i_ipc_service.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_message.dart';
import 'package:flutter_whatsapp/core/storage/message_dao.dart';
import 'package:flutter_whatsapp/core/storage/reaction_dao.dart';
import 'package:flutter_whatsapp/domain/domain.dart';
import 'package:flutter_whatsapp/domain/models/quoted_item.dart';
import 'package:flutter_whatsapp/domain/models/reaction_item.dart';
import 'package:flutter_whatsapp/domain/repositories/interaction_repository.dart';
import 'package:flutter_whatsapp/features/chat_view/controllers/conversation_interaction_handler.dart';

class MockReactionDao extends ReactionDao {
  final List<ReactionItem> reactions = [];

  @override
  Future<void> saveReaction(ReactionItem item) async {
    reactions.removeWhere((r) => r.msgId == item.msgId && r.senderJid == item.senderJid);
    if (item.emoji.isNotEmpty) {
      reactions.add(item);
    }
  }

  @override
  Future<List<ReactionItem>> getReactions(String msgId) async =>
      reactions.where((r) => r.msgId == msgId).toList();
}

class MockMessageDaoForInteractions extends MessageDao {
  final Map<String, bool> starred = {};
  final Map<String, bool> revoked = {};
  final Set<String> deleted = {};

  @override
  Future<void> setStarred(String msgId, bool isStarred) async {
    starred[msgId] = isStarred;
  }

  @override
  Future<void> setRevoked(String msgId, bool isRevoked) async {
    revoked[msgId] = isRevoked;
  }

  @override
  Future<void> deleteMessage(String msgId) async {
    deleted.add(msgId);
  }
}

class MockIpcForInteractions implements IIpcService {
  final StreamController<IpcEvent> _ctrl = StreamController<IpcEvent>.broadcast();
  final List<String> sentActions = [];
  final List<Map<String, dynamic>?> sentParams = [];

  @override
  Stream<IpcEvent> get allEvents => _ctrl.stream;

  @override
  Stream<IpcEvent> onEvent(String eventName) =>
      _ctrl.stream.where((e) => e.event == eventName);

  @override
  Future<Map<String, dynamic>> sendRequest(String action, [Map<String, dynamic>? params]) async {
    sentActions.add(action);
    sentParams.add(params);
    return {'success': true};
  }

  void emit(IpcEvent event) => _ctrl.add(event);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async => _ctrl.close();
}

Future<void> testQuotedAndReactionSerialization() async {
  final quote = QuotedItem(id: 'q1', senderJid: 'sender@s.whatsapp.net', text: 'Original message');
  final quoteJson = quote.toJson();
  final quoteParsed = QuotedItem.fromJson(quoteJson);
  assert(quoteParsed.id == 'q1');
  assert(quoteParsed.senderJid == 'sender@s.whatsapp.net');
  assert(quoteParsed.text == 'Original message');

  final reaction = ReactionItem(
    msgId: 'm100',
    senderJid: 'me',
    emoji: '🔥',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000),
  );
  final rJson = reaction.toJson();
  final rParsed = ReactionItem.fromJson(rJson);
  assert(rParsed.msgId == 'm100');
  assert(rParsed.emoji == '🔥');
  assert(rParsed.senderJid == 'me');
  print('✓ QuotedItem and ReactionItem serialization passed');
}

Future<void> testInteractionRepository() async {
  final mockIpc = MockIpcForInteractions();
  final mockReactionDao = MockReactionDao();
  final mockMsgDao = MockMessageDaoForInteractions();

  final repo = InteractionRepository(
    mockIpc,
    reactionDao: mockReactionDao,
    messageDao: mockMsgDao,
  );

  // Test 1: Send reaction
  await repo.sendReaction(
    chatJid: 'chat@s.whatsapp.net',
    senderJid: 'peer@s.whatsapp.net',
    msgId: 'msg_1',
    emoji: '👍',
  );
  assert(mockIpc.sentActions.contains('react'));
  assert(mockReactionDao.reactions.any((r) => r.msgId == 'msg_1' && r.emoji == '👍'));

  // Test 2: Inbound reaction event
  final reactionCompleter = Completer<ReactionItem>();
  final sub = repo.reactionStream.listen((r) => reactionCompleter.complete(r));
  mockIpc.emit(const IpcEvent(
    event: 'reaction',
    data: {
      'msg_id': 'msg_1',
      'sender_jid': 'peer@s.whatsapp.net',
      'emoji': '❤️',
      'timestamp': 1700000001,
    },
  ));
  final receivedReaction = await reactionCompleter.future;
  assert(receivedReaction.emoji == '❤️');
  await sub.cancel();

  // Test 3: Star message
  await repo.starMessage(
    chatJid: 'chat@s.whatsapp.net',
    senderJid: 'peer@s.whatsapp.net',
    msgId: 'msg_1',
    fromMe: false,
    isStarred: true,
  );
  assert(mockIpc.sentActions.contains('star'));
  assert(mockMsgDao.starred['msg_1'] == true);

  // Test 4: Revoke message
  await repo.revokeMessage(
    chatJid: 'chat@s.whatsapp.net',
    senderJid: 'peer@s.whatsapp.net',
    msgId: 'msg_1',
  );
  assert(mockIpc.sentActions.contains('revoke'));
  assert(mockMsgDao.revoked['msg_1'] == true);

  // Test 5: Delete for me
  await repo.deleteMessageForMe('msg_1');
  assert(mockMsgDao.deleted.contains('msg_1'));

  repo.dispose();
  await mockIpc.dispose();
  print('✓ InteractionRepository actions and stream events passed');
}

Future<void> testConversationInteractionHandler() async {
  final mockIpc = MockIpcForInteractions();
  final repo = InteractionRepository(mockIpc);
  var stateChangedCount = 0;

  final handler = ConversationInteractionHandler(
    interactionRepository: repo,
    chatJid: 'c1@s.whatsapp.net',
    onStateChanged: () => stateChangedCount++,
  );

  final msg = MessageItem(
    id: 'm1',
    chatJid: 'c1@s.whatsapp.net',
    senderJid: 'c1@s.whatsapp.net',
    text: 'Hello world',
    timestamp: DateTime.now(),
    isFromMe: false,
  );

  handler.setReply(msg);
  assert(handler.activeQuote != null);
  assert(handler.activeQuote!.id == 'm1');
  assert(handler.activeQuote!.text == 'Hello world');

  handler.clearReply();
  assert(handler.activeQuote == null);

  await handler.react(msg, '😂');
  assert(mockIpc.sentActions.contains('react'));

  handler.dispose();
  repo.dispose();
  await mockIpc.dispose();
  print('✓ ConversationInteractionHandler quote and reaction state passed');
}

Future<void> main() async {
  await testQuotedAndReactionSerialization();
  await testInteractionRepository();
  await testConversationInteractionHandler();
  print('\nAll Stage 2 interaction tests passed successfully!');
}
