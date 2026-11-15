// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter_whatsapp/core/ipc/i_ipc_service.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_message.dart';
import 'package:flutter_whatsapp/core/storage/chat_dao.dart';
import 'package:flutter_whatsapp/core/storage/message_dao.dart';
import 'package:flutter_whatsapp/domain/domain.dart';

class MockChatDao extends ChatDao {
  final List<ChatItem> storedChats = [];
  @override
  Future<List<ChatItem>> getChats() async => storedChats;
  @override
  Future<void> saveChats(List<ChatItem> chats) async {
    storedChats.clear();
    storedChats.addAll(chats);
  }
  @override
  Future<void> saveChat(ChatItem chat) async {
    final idx = storedChats.indexWhere((c) => c.jid == chat.jid);
    if (idx != -1) {
      storedChats[idx] = chat;
    } else {
      storedChats.insert(0, chat);
    }
  }
  @override
  Future<void> clearUnread(String jid) async {
    final idx = storedChats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      storedChats[idx] = storedChats[idx].copyWith(unreadCount: 0);
    }
  }
}

class MockMessageDao extends MessageDao {
  final List<MessageItem> storedMessages = [];
  @override
  Future<void> saveMessage(MessageItem message) async => storedMessages.add(message);
  @override
  Future<List<MessageItem>> getMessages(String chatJid, {int limit = 100}) async =>
      storedMessages.where((m) => m.chatJid == chatJid).toList();
  @override
  Future<void> markMessagesAsRead(String chatJid, [List<String>? messageIds]) async {
    for (var i = 0; i < storedMessages.length; i++) {
      if (storedMessages[i].chatJid == chatJid) {
        if (messageIds == null || messageIds.contains(storedMessages[i].id)) {
          storedMessages[i] = storedMessages[i].copyWith(status: 'read');
        }
      }
    }
  }
}

class MockIpcService implements IIpcService {
  final StreamController<IpcEvent> _events =
      StreamController<IpcEvent>.broadcast();
  final List<String> sentActions = [];
  final List<Map<String, dynamic>?> sentParams = [];

  Map<String, dynamic> requestResult = {};

  void emit(IpcEvent event) => _events.add(event);

  @override
  Stream<IpcEvent> get allEvents => _events.stream;

  @override
  Stream<IpcEvent> onEvent(String eventName) =>
      _events.stream.where((e) => e.event == eventName);

  @override
  Future<Map<String, dynamic>> sendRequest(
    String action, [
    Map<String, dynamic>? params,
  ]) async {
    sentActions.add(action);
    sentParams.add(params);
    return requestResult;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {
    await _events.close();
  }
}

Future<void> testAuthState() async {
  const initial = AuthState.initial();
  assert(initial is AuthInitial);

  const qr = AuthState.qrReady('test-code', 30);
  assert(qr is AuthQrReady);
  assert((qr as AuthQrReady).qrCode == 'test-code');
  assert((qr as AuthQrReady).timeoutSeconds == 30);

  const connecting = AuthState.connecting();
  assert(connecting is AuthConnecting);

  const connected = AuthState.connected('1234567@s.whatsapp.net', '1234567');
  assert(connected is AuthConnected);
  assert((connected as AuthConnected).jid == '1234567@s.whatsapp.net');
  assert((connected as AuthConnected).phone == '1234567');

  const loggedOut = AuthState.loggedOut();
  assert(loggedOut is AuthLoggedOut);

  const err = AuthState.error('failure');
  assert(err is AuthError);
  assert((err as AuthError).message == 'failure');

  print('✓ AuthState tests passed');
}

Future<void> testChatItem() async {
  final json = {
    'jid': 'user@s.whatsapp.net',
    'name': 'User',
    'lastMessage': 'Hello',
    'lastMessageTimestamp': 1700000000000,
    'unreadCount': 2,
    'avatarUrl': 'http://image.png',
  };

  final item = ChatItem.fromJson(json);
  assert(item.jid == 'user@s.whatsapp.net');
  assert(item.name == 'User');
  assert(item.lastMessage == 'Hello');
  assert(item.unreadCount == 2);
  assert(item.avatarUrl == 'http://image.png');
  assert(!item.isGroup);

  final enc = item.toJson();
  assert(enc['jid'] == 'user@s.whatsapp.net');
  assert(enc['unreadCount'] == 2);

  final updated = item.copyWith(name: 'Updated');
  assert(updated.name == 'Updated');
  assert(updated.jid == item.jid);

  print('✓ ChatItem tests passed');
}

Future<void> testMessageItem() async {
  final json = {
    'id': 'msg_001',
    'chat_jid': 'chat@s.whatsapp.net',
    'sender_jid': 'sender@s.whatsapp.net',
    'body': 'Test message',
    'timestamp': 1700000000,
    'from_me': true,
    'status': 'delivered',
  };

  final item = MessageItem.fromJson(json);
  assert(item.id == 'msg_001');
  assert(item.chatJid == 'chat@s.whatsapp.net');
  assert(item.senderJid == 'sender@s.whatsapp.net');
  assert(item.text == 'Test message');
  assert(item.isFromMe);
  assert(item.status == 'delivered');

  final enc = item.toJson();
  assert(enc['id'] == 'msg_001');
  assert(enc['text'] == 'Test message');

  print('✓ MessageItem tests passed');
}

Future<void> testAuthRepository() async {
  final mock = MockIpcService();
  final repo = AuthRepository(mock);

  assert(repo.currentAuthState is AuthInitial);

  mock.emit(const IpcEvent(
    event: 'qr',
    data: {'code': 'qr_123', 'timeout_seconds': 25},
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  assert(repo.currentAuthState is AuthQrReady);
  assert((repo.currentAuthState as AuthQrReady).qrCode == 'qr_123');

  mock.emit(const IpcEvent(
    event: 'connected',
    data: {'jid': '15551234567@s.whatsapp.net'},
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  assert(repo.currentAuthState is AuthConnected);
  assert((repo.currentAuthState as AuthConnected).phone == '15551234567');

  mock.emit(const IpcEvent(
    event: 'logged_out',
    data: {'reason': 'user logout'},
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  assert(repo.currentAuthState is AuthLoggedOut);

  await repo.requestLogin();
  assert(mock.sentActions.contains('login'));

  await repo.logout();
  assert(mock.sentActions.contains('logout'));
  assert(repo.currentAuthState is AuthLoggedOut);

  repo.dispose();
  await mock.dispose();
  print('✓ AuthRepository tests passed');
}

Future<void> testChatRepository() async {
  final mock = MockIpcService();
  final chatDao = MockChatDao();
  final messageDao = MockMessageDao();
  final repo = ChatRepository(mock, chatDao: chatDao, messageDao: messageDao);

  mock.emit(const IpcEvent(
    event: 'chat_sync',
    data: {
      'chats': [
        {
          'jid': 'c1@s.whatsapp.net',
          'name': 'Chat 1',
          'last_timestamp': 1000,
          'unread_count': 0,
        },
        {
          'jid': 'c2@s.whatsapp.net',
          'name': 'Chat 2',
          'last_timestamp': 2000,
          'unread_count': 0,
        },
      ]
    },
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  assert(repo.currentChats.length == 2);
  assert(repo.currentChats.first.jid == 'c2@s.whatsapp.net');

  // Test 1: Incoming unread message increments unreadCount to 1
  mock.emit(const IpcEvent(
    event: 'message',
    data: {
      'id': 'm1',
      'chat_jid': 'c1@s.whatsapp.net',
      'sender_jid': 'c1@s.whatsapp.net',
      'body': 'New unread message',
      'timestamp': 3000,
      'from_me': false,
      'status': 'unread',
    },
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  final chatC1AfterM1 = repo.currentChats.firstWhere((c) => c.jid == 'c1@s.whatsapp.net');
  assert(chatC1AfterM1.unreadCount == 1, 'Expected unreadCount=1, got ${chatC1AfterM1.unreadCount}');

  // Test 2: Incoming message already read on other device (status: 'read') does NOT increment unreadCount
  mock.emit(const IpcEvent(
    event: 'message',
    data: {
      'id': 'm2',
      'chat_jid': 'c1@s.whatsapp.net',
      'sender_jid': 'c1@s.whatsapp.net',
      'body': 'Message read on another device',
      'timestamp': 3500,
      'from_me': false,
      'status': 'read',
    },
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  final chatC1AfterM2 = repo.currentChats.firstWhere((c) => c.jid == 'c1@s.whatsapp.net');
  assert(chatC1AfterM2.unreadCount == 1, 'Already read message should not increment unreadCount');

  // Test 3: Other device reads the chat (chat_read event) -> unreadCount clears to 0
  mock.emit(const IpcEvent(
    event: 'chat_read',
    data: {
      'chat_jid': 'c1@s.whatsapp.net',
      'read': true,
      'message_ids': ['m1', 'm2'],
    },
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  final chatC1AfterRead = repo.currentChats.firstWhere((c) => c.jid == 'c1@s.whatsapp.net');
  assert(chatC1AfterRead.unreadCount == 0, 'chat_read should clear unreadCount to 0');

  // Test 4: Incoming unread message increments unreadCount to 1 again
  mock.emit(const IpcEvent(
    event: 'message',
    data: {
      'id': 'm3',
      'chat_jid': 'c1@s.whatsapp.net',
      'sender_jid': 'c1@s.whatsapp.net',
      'body': 'Another unread message',
      'timestamp': 4000,
      'from_me': false,
      'status': 'unread',
    },
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  final chatC1AfterM3 = repo.currentChats.firstWhere((c) => c.jid == 'c1@s.whatsapp.net');
  assert(chatC1AfterM3.unreadCount == 1);

  // Test 5: Self read receipt from other device (receipt with from_me=true, type='read') -> unreadCount clears to 0
  mock.emit(const IpcEvent(
    event: 'receipt',
    data: {
      'chat_jid': 'c1@s.whatsapp.net',
      'message_ids': ['m3'],
      'type': 'read',
      'from_me': true,
    },
  ));
  await Future.delayed(const Duration(milliseconds: 20));

  final chatC1AfterReceipt = repo.currentChats.firstWhere((c) => c.jid == 'c1@s.whatsapp.net');
  assert(chatC1AfterReceipt.unreadCount == 0, 'Self read receipt should clear unreadCount to 0');

  await repo.sendMessage('c1@s.whatsapp.net', 'Hello');
  assert(mock.sentActions.contains('send_message'));

  repo.dispose();
  await mock.dispose();
  print('✓ ChatRepository unread & read tests passed');
}

Future<void> main() async {
  await testAuthState();
  await testChatItem();
  await testMessageItem();
  await testAuthRepository();
  await testChatRepository();
  print('\nAll domain verification tests passed successfully!');
}
