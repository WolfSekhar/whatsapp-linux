import '../models/app_preferences.dart';
import '../models/privacy_settings.dart';
import '../models/status_story_item.dart';
import '../models/user_profile.dart';

/// Contract for accessing and modifying profile, privacy, app settings, and stories.
abstract class ISettingsRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile({String? name, String? about});
  Future<PrivacySettings> getPrivacySettings();
  Future<void> updatePrivacySetting(String category, String value);
  Future<List<String>> getBlocklist();
  Future<void> updateBlocklist(String jid, bool block);
  Future<AppPreferences> getAppPreferences();
  Future<void> saveAppPreferences(AppPreferences preferences);
  Future<List<StatusStoryItem>> getStatusStories();
  Future<void> markStoryViewed(String storyId);
  Future<void> clearMediaCache();
  Stream<List<StatusStoryItem>> get statusStream;
}
