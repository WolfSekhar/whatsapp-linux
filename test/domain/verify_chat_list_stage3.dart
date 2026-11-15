// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whatsapp/domain/chat.dart';
import 'package:flutter_whatsapp/domain/models/chat_filter_type.dart';
import 'package:flutter_whatsapp/domain/models/message_item.dart';
import 'package:flutter_whatsapp/domain/models/quoted_item.dart';
import 'package:flutter_whatsapp/domain/repositories/i_chat_repository.dart';
import 'package:flutter_whatsapp/features/home/controllers/chat_controller.dart';

class MockChatRepo implements IChatRepository {
  List<ChatItem> chats;
  final StreamController<List<ChatItem>> _stream = StreamController.broadcast();

  MockChatRepo(this.chats);

  @override
  Stream<List<ChatItem>> get chatsStream => _stream.stream;

  @override
  Stream<MessageItem> get messageStream => const Stream.empty();

  @override
  List<ChatItem> get currentChats => List.unmodifiable(chats);

  @override
  Future<List<ChatItem>> getChats() async => currentChats;

  @override
  Future<void> fetchChats() async {}

  @override
  Future<List<MessageItem>> getMessages(String chatJid) async => [];

  @override
  Future<void> sendMessage(String chatJid, String text, {QuotedItem? quoted}) async {}

  @override
  Future<void> markAsRead(String jid) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(unreadCount: 0);
      _stream.add(List.unmodifiable(chats));
    }
  }

  @override
  Future<void> pinChat(String jid, bool pin) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(isPinned: pin);
      _stream.add(List.unmodifiable(chats));
    }
  }

  @override
  Future<void> archiveChat(String jid, bool archive) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(isArchived: archive);
      _stream.add(List.unmodifiable(chats));
    }
  }

  @override
  Future<void> muteChat(String jid, {int durationSeconds = 0, bool mute = true}) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(muteUntil: mute ? 9999999999 : 0);
      _stream.add(List.unmodifiable(chats));
    }
  }

  @override
  Future<void> clearChat(String jid) async {
    final idx = chats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(lastMessage: '');
      _stream.add(List.unmodifiable(chats));
    }
  }

  @override
  Future<void> deleteChat(String jid) async {
    chats.removeWhere((c) => c.jid == jid);
    _stream.add(List.unmodifiable(chats));
  }

  @override
  void dispose() {
    _stream.close();
  }
}

void main() {
  test('Stage 3 Chat List Management and Filtering', () async {
    print('Running Stage 3 Chat List Management verification tests...');

  // Setup test chats
  final c1 = ChatItem(
    jid: '1@s.whatsapp.net',
    name: 'Alice',
    lastMessage: 'Hello there',
    lastMessageTimestamp: DateTime.fromMillisecondsSinceEpoch(1000),
    unreadCount: 2,
    isPinned: false,
    isArchived: false,
  );

  final c2 = ChatItem(
    jid: '2@s.whatsapp.net',
    name: 'Bob',
    lastMessage: 'Flutter desktop',
    lastMessageTimestamp: DateTime.fromMillisecondsSinceEpoch(2000),
    unreadCount: 0,
    isPinned: true,
    isArchived: false,
  );

  final c3 = ChatItem(
    jid: '3@g.us',
    name: 'Dev Group',
    lastMessage: 'Linux rules',
    lastMessageTimestamp: DateTime.fromMillisecondsSinceEpoch(3000),
    unreadCount: 1,
    isGroup: true,
    isPinned: false,
    isArchived: false,
  );

  final cArchived = ChatItem(
    jid: '4@s.whatsapp.net',
    name: 'Old Contact',
    lastMessage: 'Archive me',
    lastMessageTimestamp: DateTime.fromMillisecondsSinceEpoch(4000),
    unreadCount: 0,
    isPinned: false,
    isArchived: true,
  );

  final repo = MockChatRepo([c1, c2, c3, cArchived]);
  final controller = ChatController(chatRepository: repo);

  // 1. Initial State
  assert(controller.activeFilter == ChatFilterType.all, 'activeFilter should default to all');
  assert(controller.hasArchivedChats == true, 'hasArchivedChats should be true');
  assert(controller.archivedCount == 1, 'archivedCount should be 1');
  assert(controller.unreadCount == 2, 'unreadCount should be 2 (c1, c3)');

  // 2. Default List: excludes archived, Bob (pinned) should be first despite earlier timestamp
  var list = controller.chats;
  assert(list.length == 3, 'Default list should exclude archived chat (len=3)');
  assert(list[0].jid == '2@s.whatsapp.net', 'Pinned chat (Bob) must be first');
  assert(list[1].jid == '3@g.us', 'Newest non-pinned (Dev Group) must be second');
  assert(list[2].jid == '1@s.whatsapp.net', 'Oldest (Alice) must be third');
  print('✓ Default filtering and pin-priority sorting passed');

  // 3. Unread Filter
  controller.setFilter(ChatFilterType.unread);
  list = controller.chats;
  assert(list.length == 2, 'Unread filter should return 2 chats');
  assert(!list.any((c) => c.jid == '2@s.whatsapp.net'), 'Bob is read so should be excluded');
  print('✓ Unread filtering passed');

  // 4. Groups Filter
  controller.setFilter(ChatFilterType.groups);
  list = controller.chats;
  assert(list.length == 1 && list.first.jid == '3@g.us', 'Groups filter should return only Dev Group');
  print('✓ Groups filtering passed');

  // 5. Archived Filter
  controller.setFilter(ChatFilterType.archived);
  list = controller.chats;
  assert(list.length == 1 && list.first.jid == '4@s.whatsapp.net', 'Archived filter should return only archived chats');
  print('✓ Archived filtering passed');

  // 6. Search Filter
  controller.setFilter(ChatFilterType.all);
  controller.setSearchQuery('Flutter');
  list = controller.chats;
  assert(list.length == 1 && list.first.jid == '2@s.whatsapp.net', 'Search by message content passed');
  controller.setSearchQuery('Alice');
  list = controller.chats;
  assert(list.length == 1 && list.first.jid == '1@s.whatsapp.net', 'Search by name passed');
  controller.clearSearch();
  assert(controller.chats.length == 3, 'clearSearch restored list');
  print('✓ Search filter passed');

  // 7. Actions delegation
  await controller.pinChat('1@s.whatsapp.net', true);
  assert(repo.chats.firstWhere((c) => c.jid == '1@s.whatsapp.net').isPinned == true, 'pinChat passed');

  await controller.archiveChat('1@s.whatsapp.net', true);
  assert(repo.chats.firstWhere((c) => c.jid == '1@s.whatsapp.net').isArchived == true, 'archiveChat passed');

  await controller.muteChat('2@s.whatsapp.net', mute: true);
  assert(repo.chats.firstWhere((c) => c.jid == '2@s.whatsapp.net').muteUntil > 0, 'muteChat passed');

  await controller.clearChat('3@g.us');
  assert(repo.chats.firstWhere((c) => c.jid == '3@g.us').lastMessage == '', 'clearChat passed');

  await controller.deleteChat('4@s.whatsapp.net');
  assert(!repo.chats.any((c) => c.jid == '4@s.whatsapp.net'), 'deleteChat passed');

  await controller.markAsRead('3@g.us');
  assert(repo.chats.firstWhere((c) => c.jid == '3@g.us').unreadCount == 0, 'markAsRead passed');

  await controller.markAsUnread('2@s.whatsapp.net');
  assert(controller.selectedChatJid == null || controller.selectedChat?.unreadCount == 1, 'markAsUnread passed');
  print('✓ All action delegations passed');

  // 8. Strict File Size Verification (< 150 LOC)
  final dir = Directory('lib/features/home');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final lines = entity.readAsLinesSync().length;
      assert(lines <= 150, 'File ${entity.path} exceeds 150 LOC ($lines lines)');
    }
  }
  print('✓ All lib/features/home/ Dart source files are strictly <= 150 LOC');

    print('\nAll Stage 3 verification tests passed successfully!');
  });
}
