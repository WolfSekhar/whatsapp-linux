# Stage 5: User Profile, Status / Stories Viewer, & App Settings Implementation Plan

## 1. Overview & Objective
Complete the desktop client with personal identity management, status/stories viewing, comprehensive application settings, and native Linux desktop notifications:
- **User Profile Management**: Clicking the avatar at the bottom of the navigation rail opens the Profile Drawer: profile picture preview (with upload/change capability), editable display name, editable "About" bio, and read-only phone number.
- **Status / Stories Viewer**: Navigation rail status icon with unread indicator badge; full-screen story viewer with segmented auto-advancing progress bars, contact groupings, text and image status rendering, and reply bar.
- **Privacy Settings**: Configure Last Seen, Profile Photo visibility, About visibility, Read Receipts toggle, and Blocked Contacts manager.
- **Chat & Appearance Customization**: Custom chat wallpaper selector (solid colors, classic WhatsApp doodles, custom image), Enter key behavior toggle (Enter to send vs Ctrl+Enter), and font size scaling.
- **Desktop Notifications**: Native Linux notifications (DBus / `notify-send` / `desktop_notifications`) for incoming messages with sender name, message preview, and mute respect.
- **Session & Storage Diagnostics**: Storage cache cleaner ("Clear Media Cache"), dynamic WhatsApp Web version display, and secure logout.

---

## 2. Architecture & File Breakdown (< 150 LOC per file)

### A. Go Daemon Backend (`daemon/pkg/wa/` & `daemon/pkg/ipc/`)
1. **`daemon/pkg/ipc/protocol.go`** (extend):
   - Actions: `ActionGetProfile = "get_profile"`, `ActionUpdateProfile = "update_profile"`, `ActionGetPrivacy = "get_privacy"`, `ActionSetPrivacy = "set_privacy"`, `ActionGetStatuses = "get_statuses"`.
   - Events: `EventStatusUpdate = "status_update"`.
2. **`daemon/pkg/wa/profile_manager.go`**:
   - `SetPushName(ctx, name)` via `appstate.BuildSettingPushName()`.
   - `SetAbout(ctx, text)` via `cli.SetStatusMessage()`.
   - `SetProfilePicture(ctx, imageBytes)` via `cli.SetProfilePicture()`.
3. **`daemon/pkg/wa/privacy_manager.go`**:
   - `GetPrivacySettings(ctx)` via `cli.TryFetchPrivacySettings()`.
   - `SetPrivacy(ctx, category, setting)` via `cli.SetPrivacySetting()`.
   - `GetBlocklist(ctx)` & `UpdateBlocklist(ctx, jid, action)`.
4. **`daemon/pkg/wa/status_feed_handler.go`**:
   - Captures incoming messages targeted at `status@broadcast`.
   - Emits `ipc.EventStatusUpdate` with contact story items, expiring after 24 hours.

### B. Flutter Storage & Data Layer (`lib/core/storage/` & `lib/domain/`)
1. **`lib/domain/models/user_profile.dart`**:
   - Model: `jid`, `name`, `about`, `avatarUrl`, `phone`.
2. **`lib/domain/models/status_story_item.dart`**:
   - Model representing a 24-hour status update: `id`, `senderJid`, `timestamp`, `caption`, `mediaUrl`, `mediaType`.
3. **`lib/domain/models/privacy_settings.dart`**:
   - Model representing privacy controls: `readReceipts`, `lastSeen`, `profilePhoto`, `about`.
4. **`lib/domain/repositories/i_settings_repository.dart`**:
   - Abstract contract: `getProfile()`, `updateProfile()`, `getPrivacy()`, `updatePrivacy()`, `getStatuses()`.
5. **`lib/domain/repositories/settings_repository.dart`**:
   - Concrete implementation communicating with Go daemon.

### C. Flutter Presentation Layer (`lib/features/settings/` & `status/`)
1. **`lib/features/settings/controllers/settings_controller.dart`**:
   - State management for theme mode, wallpaper, privacy settings, and profile info.
2. **`lib/features/settings/ui/settings_dialog.dart`**:
   - Tabbed settings dialog:
     - General (startup, language)
     - Privacy (last seen, read receipts, blocked list)
     - Chats (wallpaper picker, enter key behavior)
     - Notifications (desktop notification toggle, sound alerts)
     - About / Session (whatsmeow version, clear cache, logout)
3. **`lib/features/settings/ui/profile_drawer.dart`**:
   - User profile slide-over panel: circular avatar with camera edit overlay, name edit field, about text field.
4. **`lib/features/settings/ui/wallpaper_picker.dart`**:
   - Grid of solid background colors and WhatsApp doodle themes.
5. **`lib/features/status/ui/status_stories_viewer.dart`**:
   - Instagram/WhatsApp-style segmented story viewer with tap-to-pause and forward/backward navigation.
6. **`lib/core/notifications/linux_notification_service.dart`**:
   - Subsystem executing `notify-send` / Linux desktop notifications when incoming messages arrive while window is unfocused.

---

## 3. Implementation Steps & Work Items
- [ ] **Step 5.1**: Extend IPC protocol with profile, privacy, and status story schemas.
- [ ] **Step 5.2**: Implement Go profile manager, privacy manager, and status broadcast listeners.
- [ ] **Step 5.3**: Build `SettingsDialog` with categorized tabs and live preference persistence.
- [ ] **Step 5.4**: Implement `ProfileDrawer` for avatar, push name, and status bio modifications.
- [ ] **Step 5.5**: Build `StatusStoriesViewer` with segmented progress indicators and media playback.
- [ ] **Step 5.6**: Implement `LinuxNotificationService` for background desktop message notifications.
- [ ] **Step 5.7**: Verify all file sizes < 150 LOC and run `flutter analyze`.

---

## 4. Quality & Safety Verification
- **Safety**: Profile and privacy mutations occur strictly when user saves in the UI.
- **Icons**: Exclusively `FluentIcons.settings_24_regular`, `FluentIcons.person_24_regular`, `FluentIcons.status_24_regular`, `FluentIcons.lock_shield_24_regular`, `FluentIcons.paint_bucket_24_regular`.
