import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/ipc/i_ipc_service.dart';
import '../../core/storage/preferences_dao.dart';
import '../models/app_preferences.dart';
import '../models/privacy_settings.dart';
import '../models/status_story_item.dart';
import '../models/user_profile.dart';
import 'i_settings_repository.dart';
import 'status_story_handler.dart';

/// Concrete implementation of [ISettingsRepository] backed by IPC and SQLite.
class SettingsRepository implements ISettingsRepository {
  final IIpcService _ipc;
  final PreferencesDao _preferencesDao;
  final StatusStoryHandler _storyHandler;
  UserProfile? _cachedProfile;
  PrivacySettings? _cachedPrivacy;

  SettingsRepository(
    this._ipc, {
    PreferencesDao? preferencesDao,
    StatusStoryHandler? storyHandler,
  })  : _preferencesDao = preferencesDao ?? PreferencesDao(),
        _storyHandler = storyHandler ?? StatusStoryHandler();

  @override
  Future<UserProfile> getProfile() async {
    try {
      final res = await _ipc.sendRequest('get_profile');
      final data = res['profile'] is Map ? res['profile'] as Map : res;
      _cachedProfile = UserProfile.fromJson(Map<String, dynamic>.from(data));
      return _cachedProfile!;
    } catch (_) {
      return _cachedProfile ??
          const UserProfile(
            jid: 'me@s.whatsapp.net',
            name: 'Me',
            about: 'Hey there! I am using WhatsApp.',
          );
    }
  }

  @override
  Future<void> updateProfile({String? name, String? about}) async {
    final params = <String, dynamic>{};
    if (name != null) params['name'] = name;
    if (about != null) params['about'] = about;
    await _ipc.sendRequest('update_profile', params);
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(name: name, about: about);
    }
  }

  @override
  Future<PrivacySettings> getPrivacySettings() async {
    try {
      final res = await _ipc.sendRequest('get_privacy');
      final data = res['privacy'] is Map ? res['privacy'] as Map : res;
      _cachedPrivacy = PrivacySettings.fromJson(Map<String, dynamic>.from(data));
      return _cachedPrivacy!;
    } catch (_) {
      return _cachedPrivacy ?? const PrivacySettings();
    }
  }

  @override
  Future<void> updatePrivacySetting(String category, String value) async {
    await _ipc.sendRequest('set_privacy', {'category': category, 'value': value});
    if (_cachedPrivacy != null) {
      if (category == 'read_receipts') {
        _cachedPrivacy = _cachedPrivacy!.copyWith(readReceipts: value);
      } else if (category == 'last_seen') {
        _cachedPrivacy = _cachedPrivacy!.copyWith(lastSeen: value);
      } else if (category == 'profile_photo') {
        _cachedPrivacy = _cachedPrivacy!.copyWith(profilePhoto: value);
      } else if (category == 'about') {
        _cachedPrivacy = _cachedPrivacy!.copyWith(about: value);
      }
    }
  }

  @override
  Future<List<String>> getBlocklist() async {
    try {
      final res = await _ipc.sendRequest('get_blocklist');
      final list = res['blocklist'] as List<dynamic>?;
      return list?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return _cachedPrivacy?.blocklist ?? [];
    }
  }

  @override
  Future<void> updateBlocklist(String jid, bool block) async {
    await _ipc.sendRequest('update_blocklist', {'jid': jid, 'block': block});
    if (_cachedPrivacy != null) {
      final updated = List<String>.from(_cachedPrivacy!.blocklist);
      if (block && !updated.contains(jid)) {
        updated.add(jid);
      } else if (!block) {
        updated.remove(jid);
      }
      _cachedPrivacy = _cachedPrivacy!.copyWith(blocklist: updated);
    }
  }

  @override
  Future<AppPreferences> getAppPreferences() => _preferencesDao.getPreferences();

  @override
  Future<void> saveAppPreferences(AppPreferences preferences) =>
      _preferencesDao.savePreferences(preferences);

  @override
  Future<List<StatusStoryItem>> getStatusStories() async =>
      _storyHandler.getStories();

  @override
  Future<void> markStoryViewed(String storyId) async =>
      _storyHandler.markViewed(storyId);

  @override
  Stream<List<StatusStoryItem>> get statusStream => _storyHandler.statusStream;

  @override
  Future<void> clearMediaCache() async {
    try {
      final home = Platform.environment['HOME'] ?? '.';
      final xdg = Platform.environment['XDG_DATA_HOME'] ?? p.join(home, '.local', 'share');
      final mediaDir = Directory(p.join(xdg, 'whatsapp-linux', 'media'));
      if (await mediaDir.exists()) {
        await for (final file in mediaDir.list()) {
          try {
            await file.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
