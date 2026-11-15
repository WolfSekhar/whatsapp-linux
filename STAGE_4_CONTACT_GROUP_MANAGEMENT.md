# Stage 4: Contact & Group Management / Info Drawer Implementation Plan

## 1. Overview & Objective
Implement full desktop contact and group inspection and management capabilities:
- **Contact Info Drawer**: Clicking a direct chat header slides open a right-side inspection drawer showing full-resolution avatar, phone number, "About" status bio, shared media summary, encryption confirmation, and block/report actions.
- **Group Info Drawer**: For group chats, display group avatar, group subject, group description (with inline edit for authorized users), creation date, and creator info.
- **Participant List**: Searchable list of group members with visual "Group Admin" badges.
- **Member Management**: Add member dialog, remove member, promote to admin, demote from admin.
- **Group Permissions**: Admin toggles for "Edit group info" and "Send messages" (all members vs admins only).
- **Exit & Delete Group**: Confirmation workflows to leave or delete groups.

---

## 2. Architecture & File Breakdown (< 150 LOC per file)

### A. Go Daemon Backend (`daemon/pkg/wa/` & `daemon/pkg/ipc/`)
1. **`daemon/pkg/ipc/protocol.go`** (extend):
   - Actions: `ActionGetGroupInfo = "get_group_info"`, `ActionUpdateGroup = "update_group"`, `ActionUpdateParticipants = "update_participants"`, `ActionLeaveGroup = "leave_group"`.
   - Structs: `GroupInfoResult`, `GroupParticipantInfo`, `UpdateParticipantsParams`.
2. **`daemon/pkg/wa/group_info_fetcher.go`**:
   - Calls `cli.GetGroupInfo(targetJID)`.
   - Serializes title, topic/description, creation time, owner, and participant list with admin flags.
3. **`daemon/pkg/wa/group_admin_actions.go`**:
   - `UpdateParticipants(ctx, groupJID, participants, action)` via `cli.UpdateGroupParticipants()`.
   - `SetGroupTopic(ctx, groupJID, topic)` via `cli.SetGroupTopic()`.
   - `SetGroupLocked(ctx, groupJID, locked)` via `cli.SetGroupLocked()`.
   - `SetGroupAnnounce(ctx, groupJID, announce)` via `cli.SetGroupAnnounce()`.
   - `LeaveGroup(ctx, groupJID)` via `cli.LeaveGroup()`.

### B. Flutter Storage & Data Layer (`lib/core/storage/` & `lib/domain/`)
1. **`lib/domain/models/group_metadata.dart`**:
   - Model representing group properties: `jid`, `topic`, `ownerJid`, `creationTime`, `isLocked`, `isAnnounce`, `participants`.
2. **`lib/domain/models/group_participant.dart`**:
   - Model representing a participant: `jid`, `displayName`, `isAdmin`, `isSuperAdmin`.
3. **`lib/domain/repositories/i_group_repository.dart`**:
   - Abstract contract: `getGroupInfo(jid)`, `updateDescription(jid, desc)`, `modifyParticipants(jid, users, action)`, `leaveGroup(jid)`.
4. **`lib/domain/repositories/group_repository.dart`**:
   - Implementation dispatching requests to `IIpcService`.

### C. Flutter Presentation Layer (`lib/features/chat_info/`)
1. **`lib/features/chat_info/controllers/chat_info_controller.dart`**:
   - Manages drawer state, loading state, group metadata fetching, and participant search filtering.
2. **`lib/features/chat_info/ui/chat_info_drawer.dart`**:
   - Top-level desktop drawer (360px wide) embedded in `DesktopShell` or sliding from right.
   - Header with close button, title, and avatar.
3. **`lib/features/chat_info/ui/contact_details_panel.dart`**:
   - Details for 1-on-1 chats: phone number, about bio, encryption notice.
4. **`lib/features/chat_info/ui/group_details_panel.dart`**:
   - Details for groups: editable description card, group settings link, exit group button.
5. **`lib/features/chat_info/ui/participant_list_tile.dart`**:
   - Single participant item with admin pill badge and context menu (Message, View Info, Make Admin, Remove).
6. **`lib/features/chat_info/ui/add_participant_dialog.dart`**:
   - Dialog to select contacts and add them to the current group.

---

## 3. Implementation Steps & Work Items
- [ ] **Step 4.1**: Define IPC protocol actions and models for group info and participant management.
- [ ] **Step 4.2**: Implement Go group info queries and participant manipulation via whatsmeow.
- [ ] **Step 4.3**: Create domain models `GroupMetadata` and `GroupParticipant` and repository.
- [ ] **Step 4.4**: Build `ChatInfoDrawer` container and wire opening when clicking `ChatHeader`.
- [ ] **Step 4.5**: Implement `GroupDetailsPanel` and `ParticipantListTile` with admin badges.
- [ ] **Step 4.6**: Wire member add/remove and description edit dialogs.
- [ ] **Step 4.7**: Verify all file sizes < 150 LOC and run `flutter analyze`.

---

## 4. Quality & Safety Verification
- **Safety**: Outbound group management changes strictly trigger on deliberate human actions.
- **Icons**: Exclusively `FluentIcons.people_community_24_regular`, `FluentIcons.shield_person_20_regular`, `FluentIcons.person_add_24_regular`, `FluentIcons.dismiss_24_regular`.
