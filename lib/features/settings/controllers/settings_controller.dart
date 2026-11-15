import 'package:flutter/foundation.dart';

import '../../../domain/models/app_preferences.dart';
import '../../../domain/models/privacy_settings.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/repositories/i_settings_repository.dart';

/// State controller managing settings, user profile, and privacy controls.
class SettingsController extends ChangeNotifier {
  final ISettingsRepository repository;

  AppPreferences _preferences = const AppPreferences();
  UserProfile? _profile;
  PrivacySettings? _privacy;
  bool _isLoading = false;

  SettingsController({required this.repository}) {
    loadSettings();
  }

  AppPreferences get preferences => _preferences;
  UserProfile? get profile => _profile;
  PrivacySettings? get privacy => _privacy;
  bool get isLoading => _isLoading;

  /// Loads preferences, profile, and privacy settings from repository.
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _preferences = await repository.getAppPreferences();
      _profile = await repository.getProfile();
      _privacy = await repository.getPrivacySettings();
    } catch (_) {
      // Retain default values on retrieval failure
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates active theme mode ("system", "dark", "light").
  Future<void> updateThemeMode(String mode) async {
    _preferences = _preferences.copyWith(themeMode: mode);
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Toggles whether Enter key sends message or inserts newline.
  Future<void> updateEnterIsSend(bool value) async {
    _preferences = _preferences.copyWith(enterIsSend: value);
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Updates chat wallpaper color or doodle preset.
  Future<void> updateWallpaper(String? wallpaperColorHexOrDoodle) async {
    _preferences = _preferences.copyWith(
      customWallpaper: wallpaperColorHexOrDoodle,
    );
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Updates desktop text/font scaling factor.
  Future<void> updateFontScale(double scale) async {
    _preferences = _preferences.copyWith(fontScale: scale);
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Updates desktop notification preference.
  Future<void> updateDesktopNotifications(bool value) async {
    _preferences = _preferences.copyWith(desktopNotifications: value);
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Updates message preview preference.
  Future<void> updateMessagePreview(bool value) async {
    _preferences = _preferences.copyWith(messagePreview: value);
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Updates sound alerts preference.
  Future<void> updateSoundAlerts(bool value) async {
    _preferences = _preferences.copyWith(soundAlerts: value);
    notifyListeners();
    await repository.saveAppPreferences(_preferences);
  }

  /// Updates user profile display name or about status.
  Future<void> updateProfile({String? name, String? about}) async {
    await repository.updateProfile(name: name, about: about);
    _profile = await repository.getProfile();
    notifyListeners();
  }

  /// Updates privacy visibility category (e.g. "last_seen", "read_receipts").
  Future<void> updatePrivacy(String category, String value) async {
    await repository.updatePrivacySetting(category, value);
    _privacy = await repository.getPrivacySettings();
    notifyListeners();
  }

  /// Adds or removes a contact JID from the blocklist.
  Future<void> toggleBlockContact(String jid, bool block) async {
    await repository.updateBlocklist(jid, block);
    _privacy = await repository.getPrivacySettings();
    notifyListeners();
  }

  /// Clears local cached media files.
  Future<void> clearMediaCache() async {
    await repository.clearMediaCache();
    notifyListeners();
  }
}
