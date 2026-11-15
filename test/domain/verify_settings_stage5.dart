// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_whatsapp/core/ipc/i_ipc_service.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_message.dart';
import 'package:flutter_whatsapp/core/storage/preferences_dao.dart';
import 'package:flutter_whatsapp/domain/domain.dart';

class MockIpcForSettings implements IIpcService {
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
  print('Running Stage 5 Settings & Preferences verification...');

  // 1. UserProfile serialization & copyWith
  final p = UserProfile(jid: 'me@s.whatsapp.net', name: 'User', about: 'Hi', phone: '1234');
  assert(p.name == 'User' && p.phone == '1234');
  final pCopy = p.copyWith(name: 'User 2');
  assert(pCopy.name == 'User 2' && pCopy.jid == p.jid);
  final pFrom = UserProfile.fromJson(p.toJson());
  assert(pFrom == p && pFrom.hashCode == p.hashCode);

  // 2. PrivacySettings serialization & copyWith
  const priv = PrivacySettings(readReceipts: 'none', lastSeen: 'contacts', blocklist: ['123@s.whatsapp.net']);
  assert(!priv.readReceiptsEnabled);
  final privFrom = PrivacySettings.fromJson(priv.toJson());
  assert(privFrom.readReceipts == 'none' && privFrom.blocklist.length == 1);
  final privCopy = priv.copyWith(lastSeen: 'all');
  assert(privCopy.lastSeen == 'all' && privCopy.readReceipts == 'none');

  // 3. AppPreferences serialization & copyWith
  const prefs = AppPreferences(themeMode: 'dark', enterIsSend: false, fontScale: 1.25);
  final prefsFrom = AppPreferences.fromJson(prefs.toJson());
  assert(prefsFrom.themeMode == 'dark' && !prefsFrom.enterIsSend && prefsFrom.fontScale == 1.25);
  final prefsCopy = prefs.copyWith(themeMode: 'light');
  assert(prefsCopy.themeMode == 'light' && !prefsCopy.enterIsSend);

  // 4. StatusStoryItem serialization & copyWith
  final story = StatusStoryItem(
    id: 'story_1',
    senderJid: 'user@s.whatsapp.net',
    senderName: 'Friend',
    timestamp: DateTime.now(),
    caption: 'Hello',
    isViewed: false,
  );
  final storyFrom = StatusStoryItem.fromJson(story.toJson());
  assert(storyFrom.id == 'story_1' && storyFrom.caption == 'Hello' && !storyFrom.isViewed);
  final storyCopy = story.copyWith(isViewed: true);
  assert(storyCopy.isViewed && storyCopy.id == story.id);

  // 5. PreferencesDao in-memory persistence
  final dao = PreferencesDao();
  await dao.savePreferences(prefs);
  final loadedPrefs = await dao.getPreferences();
  assert(loadedPrefs.themeMode == 'dark' && !loadedPrefs.enterIsSend && loadedPrefs.fontScale == 1.25);

  // 6. SettingsRepository with Mock IPC
  final mockIpc = MockIpcForSettings();
  mockIpc.mockResponse = {
    'profile': {'jid': 'user@s.whatsapp.net', 'name': 'Dev', 'about': 'Coding'},
    'privacy': {'read_receipts': 'all', 'last_seen': 'contacts', 'blocklist': ['bad@s.whatsapp.net']},
    'blocklist': ['bad@s.whatsapp.net'],
  };

  final repo = SettingsRepository(mockIpc, preferencesDao: dao);

  // Profile tests
  final profile = await repo.getProfile();
  assert(profile.name == 'Dev' && profile.about == 'Coding');
  assert(mockIpc.sentActions.contains('get_profile'));

  await repo.updateProfile(name: 'Senior Dev', about: 'Deploying');
  assert(mockIpc.sentActions.contains('update_profile'));
  assert(mockIpc.sentParams.last?['name'] == 'Senior Dev');

  // Privacy & Blocklist tests
  final privacy = await repo.getPrivacySettings();
  assert(privacy.lastSeen == 'contacts');
  assert(mockIpc.sentActions.contains('get_privacy'));

  await repo.updatePrivacySetting('read_receipts', 'none');
  assert(mockIpc.sentActions.contains('set_privacy'));
  assert(mockIpc.sentParams.last?['value'] == 'none');

  final blocklist = await repo.getBlocklist();
  assert(blocklist.contains('bad@s.whatsapp.net'));

  await repo.updateBlocklist('spammer@s.whatsapp.net', true);
  assert(mockIpc.sentActions.contains('update_blocklist'));
  assert(mockIpc.sentParams.last?['block'] == true);

  // Preferences through repo
  final currentPrefs = await repo.getAppPreferences();
  assert(currentPrefs.themeMode == 'dark');
  await repo.saveAppPreferences(currentPrefs.copyWith(themeMode: 'system'));
  final updatedPrefs = await repo.getAppPreferences();
  assert(updatedPrefs.themeMode == 'system');

  // Status Stories & Stream
  final stories = await repo.getStatusStories();
  assert(stories.isNotEmpty);
  final firstStoryId = stories.first.id;

  var streamEmitted = false;
  final sub = repo.statusStream.listen((updatedStories) {
    if (updatedStories.firstWhere((s) => s.id == firstStoryId).isViewed) {
      streamEmitted = true;
    }
  });

  await repo.markStoryViewed(firstStoryId);
  await Future.delayed(const Duration(milliseconds: 50));
  assert(streamEmitted, 'statusStream should emit viewed state');
  await sub.cancel();

  // Media Cache clear test
  await repo.clearMediaCache();

  print('✓ All Stage 5 Settings & Preferences tests passed successfully!');
}
