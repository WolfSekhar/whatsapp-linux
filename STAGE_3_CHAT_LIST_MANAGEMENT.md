# Stage 3: Chat List Management & Filtering Implementation Plan

## 1. Overview & Objective
Upgrade the conversation list sidebar to support full desktop chat management and filtering identical to WhatsApp Web:
- **Top Filter Pills**: Quick category chips above the chat list: `All`, `Unread`, `Groups`.
- **Pinned Chats**: Pin/unpin chats (max 3), persistent pin state in SQLite, pin icon badge, and sorting pinned chats to the top of the list.
- **Archived Chats**: Archive/unarchive chats, separate dedicated "Archived Chats" list view, and hiding archived chats from the active conversation list.
- **Mute Chat Notifications**: Mute chat selector (8 hours, 1 week, Always), mute speaker icon indicator on `ChatTile`, and notification suppression.
- **Clear Chat & Delete Chat**: Purging cached messages for a chat or completely deleting the chat session.
- **Chat Tile Context Menu**: Desktop right-click menu on chat list items for rapid management without opening the chat.

---

## 2. Architecture & File Breakdown (< 150 LOC per file)

### A. Go Daemon Backend (`daemon/pkg/wa/` & `daemon/pkg/ipc/`)
1. **`daemon/pkg/ipc/protocol.go`** (extend):
   - Actions: `ActionPinChat = "pin_chat"`, `ActionArchiveChat = "archive_chat"`, `ActionMuteChat = "mute_chat"`, `ActionClearChat = "clear_chat"`, `ActionDeleteChat = "delete_chat"`.
   - Update `ChatSummary`: `IsPinned bool`, `IsArchived bool`, `MuteUntil int64`.
2. **`daemon/pkg/wa/chat_appstate_actions.go`**:
   - `PinChat(ctx, targetJID, pin)` via `appstate.BuildPin(jid, pin)`.
   - `ArchiveChat(ctx, targetJID, archive)` via `appstate.BuildArchive(jid, archive, ...)`.
   - `MuteChat(ctx, targetJID, muteDuration)` via `appstate.BuildMute(jid, mute)`.
   - `ClearChat(ctx, targetJID)` via `appstate.BuildClearChat(jid, ...)`.
3. **`daemon/pkg/wa/chat_list_events.go`**:
   - Handle incoming app state events: `events.Pin`, `events.Archive`, `events.Mute`.
   - Emit updated chat status events to Flutter over IPC.

### B. Flutter Storage & Data Layer (`lib/core/storage/` & `lib/domain/`)
1. **`lib/core/storage/chat_dao.dart`** (update):
   - Add columns to `chats` table: `is_pinned INTEGER DEFAULT 0`, `is_archived INTEGER DEFAULT 0`, `mute_until INTEGER DEFAULT 0`.
   - Sorting order: `ORDER BY is_pinned DESC, last_message_timestamp DESC`.
   - Add methods: `setPinned(jid, bool)`, `setArchived(jid, bool)`, `setMute(jid, int)`, `deleteChat(jid)`.
2. **`lib/domain/models/chat_item.dart`** (update):
   - Add fields: `isPinned`, `isArchived`, `muteUntil`.
3. **`lib/domain/models/chat_filter_type.dart`**:
   - Enum `ChatFilterType { all, unread, groups, archived }`.
4. **`lib/domain/repositories/chat_repository.dart`** (update):
   - Add methods: `pinChat`, `archiveChat`, `muteChat`, `clearChat`, `deleteChat`.

### C. Flutter Presentation Layer (`lib/features/home/ui/filters/` & `chat_list/`)
1. **`lib/features/home/ui/filters/chat_filter_pills.dart`**:
   - Horizontal pill bar with clickable chips (`All`, `Unread`, `Groups`).
   - Active state styled with WhatsApp brand green / subtle background highlights.
2. **`lib/features/home/controllers/chat_controller.dart`** (update):
   - Add `ChatFilterType _activeFilter = ChatFilterType.all`.
   - Filter logic combining search query + active filter type + excluding archived chats.
3. **`lib/features/home/ui/chat_tile.dart`** (update):
   - Render pin icon (`FluentIcons.pin_16_regular`) when `chat.isPinned`.
   - Render mute icon (`FluentIcons.speaker_mute_16_regular`) when `chat.isMuted`.
4. **`lib/features/home/ui/chat_tile_context_menu.dart`**:
   - Right-click menu on list tiles:
     - Pin/Unpin chat
     - Mark as unread / read
     - Archive chat
     - Mute notifications
     - Clear messages
     - Delete chat
5. **`lib/features/home/ui/archived_chats_screen.dart`**:
   - Sub-screen displaying only archived chats with a back arrow to return to the main chat list.

---

## 3. Implementation Steps & Work Items
- [ ] **Step 3.1**: Extend IPC protocol with pin, archive, mute, clear, and delete actions.
- [ ] **Step 3.2**: Implement Go appstate actions for Pin, Archive, and Mute using whatsmeow `appstate`.
- [ ] **Step 3.3**: Update SQLite `chats` schema with `is_pinned`, `is_archived`, and `mute_until`.
- [ ] **Step 3.4**: Build `ChatFilterPills` widget and integrate into `ChatListView`.
- [ ] **Step 3.5**: Update `ChatTile` with pin and mute indicators and attach `ChatTileContextMenu`.
- [ ] **Step 3.6**: Implement `ArchivedChatsScreen` accessible via top tile or menu.
- [ ] **Step 3.7**: Verify all file sizes < 150 LOC and run `flutter analyze`.

---

## 4. Quality & Safety Verification
- **Safety**: Outbound app state syncs strictly trigger on human UI interactions.
- **Icons**: Exclusively `FluentIcons.pin_16_regular`, `FluentIcons.archive_24_regular`, `FluentIcons.speaker_mute_16_regular`, `FluentIcons.filter_24_regular`.
