// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_whatsapp/core/ipc/i_ipc_service.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_message.dart';
import 'package:flutter_whatsapp/domain/domain.dart';

class MockIpcForGroup implements IIpcService {
  final List<String> sentActions = [];
  final List<Map<String, dynamic>?> sentParams = [];
  Map<String, dynamic> mockResponse = {};

  @override
  Stream<IpcEvent> get allEvents => const Stream.empty();

  @override
  Stream<IpcEvent> onEvent(String eventName) => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<Map<String, dynamic>> sendRequest(
    String action, [
    Map<String, dynamic>? params,
  ]) async {
    sentActions.add(action);
    sentParams.add(params);
    return mockResponse;
  }
}

void main() async {
  print('Running Stage 4 Group Models & Repository verification...');

  // 1. GroupParticipant tests
  final p1 = GroupParticipant(
    jid: 'user1@s.whatsapp.net',
    displayName: 'Alice',
    isAdmin: true,
    isSuperAdmin: false,
  );
  assert(p1.jid == 'user1@s.whatsapp.net');
  assert(p1.isAdmin);
  final p1Json = p1.toJson();
  final p1From = GroupParticipant.fromJson(p1Json);
  assert(p1From == p1);
  assert(p1From.hashCode == p1.hashCode);
  final p1Copy = p1.copyWith(isAdmin: false);
  assert(!p1Copy.isAdmin && p1Copy.jid == p1.jid);

  // 2. GroupInfo tests
  final now = DateTime.now();
  final group = GroupInfo(
    jid: '123456@g.us',
    ownerJid: 'owner@s.whatsapp.net',
    topic: 'My Cool Group',
    topicSetBy: 'owner@s.whatsapp.net',
    topicSetAt: now,
    creationTimestamp: now,
    isLocked: true,
    isAnnounce: false,
    participants: [p1],
  );
  final groupJson = group.toJson();
  final groupFrom = GroupInfo.fromJson(groupJson);
  assert(groupFrom.jid == '123456@g.us');
  assert(groupFrom.topic == 'My Cool Group');
  assert(groupFrom.isLocked);
  assert(groupFrom.participants.length == 1);
  assert(groupFrom.participants.first.jid == p1.jid);
  final groupCopy = group.copyWith(topic: 'New Topic');
  assert(groupCopy.topic == 'New Topic' && groupCopy.jid == group.jid);

  // 3. ContactInfo tests
  final contact = ContactInfo(
    jid: 'user2@s.whatsapp.net',
    displayName: 'Bob',
    phone: '1234567890',
    about: 'Available',
    isBlocked: false,
  );
  final contactJson = contact.toJson();
  final contactFrom = ContactInfo.fromJson(contactJson);
  assert(contactFrom == contact);
  assert(contactFrom.hashCode == contact.hashCode);
  final contactCopy = contact.copyWith(isBlocked: true);
  assert(contactCopy.isBlocked && contactCopy.displayName == 'Bob');

  // 4. GroupRepository tests
  final mockIpc = MockIpcForGroup();
  mockIpc.mockResponse = {
    'group': {
      'jid': 'group1@g.us',
      'topic': 'Dev Team',
      'participants': [
        {'jid': 'dev1@s.whatsapp.net', 'is_admin': true},
      ],
    },
  };
  final repo = GroupRepository(mockIpc);

  final fetchedGroup = await repo.getGroupInfo('group1@g.us');
  assert(fetchedGroup.jid == 'group1@g.us');
  assert(fetchedGroup.topic == 'Dev Team');
  assert(mockIpc.sentActions.contains('get_group_info'));
  assert(mockIpc.sentParams.first?['group_jid'] == 'group1@g.us');

  await repo.updateGroupTopic('group1@g.us', 'Dev Team 2.0');
  assert(mockIpc.sentActions.contains('update_group_topic'));
  assert(mockIpc.sentParams.last?['topic'] == 'Dev Team 2.0');

  await repo.updateParticipants('group1@g.us', ['user3@s.whatsapp.net'], 'add');
  assert(mockIpc.sentActions.contains('update_participants'));
  assert(mockIpc.sentParams.last?['action'] == 'add');

  await repo.leaveGroup('group1@g.us');
  assert(mockIpc.sentActions.contains('leave_group'));
  assert(mockIpc.sentParams.last?['group_jid'] == 'group1@g.us');

  final fetchedContact = await repo.getContactInfo('9876543210@s.whatsapp.net');
  assert(fetchedContact.jid == '9876543210@s.whatsapp.net');
  assert(fetchedContact.displayName == '9876543210');
  assert(fetchedContact.phone == '9876543210');

  print('✓ All Stage 4 Group Models & Repository tests passed successfully!');
}
