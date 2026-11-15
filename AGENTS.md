# AGENTS.md — Native WhatsApp for Linux

## ⚠️ CRITICAL SAFETY & PRIVACY RULE (ZERO TOLERANCE)
> **NO AUTOMATED TEST MESSAGES SHALL EVER BE SENT TO ANY CONTACT OR CHAT.**
> Under NO circumstances should any agent, script, test suite, or automation dispatch outbound messages to real WhatsApp contacts or phone numbers.
> **All messaging testing will be performed strictly by the USER personally as a human.**
> Any automated testing must mock or sandbox the IPC message bus.

---

## 1. Project Overview & Philosophy
A native, lightweight, privacy-focused WhatsApp desktop client for Linux built using **Flutter Desktop** (frontend) and a dedicated **Go daemon** powered by `whatsmeow` (WhatsApp Multi-Device Protocol).

### Key Architectural Constraints & Standards
1. **Strict File Size Limit**: Every single source file (Dart and Go) MUST be **strictly under 150 lines of code**.
2. **SOLID Design Principles**:
   - **S**ingle Responsibility: One class/module does exactly one thing.
   - **O**pen/Closed: Extensible through interfaces/abstract classes without altering core logic.
   - **L**iskov Substitution: High-level services consume abstractions (`IAuthRepository`, `IChatRepository`, `ISettingsRepository`, `IIpcService`, `IDaemonProcessManager`).
   - **I**nterface Segregation: Fine-grained, focused interfaces.
   - **D**ependency Inversion: High-level modules do not depend on low-level modules; both depend on abstractions.
3. **Modularity**: Small, decoupled components to minimize AI token footprint and maximize testability.
4. **Zero Maintenance Dynamic Versioning**: Auto-fetching client version string from `web.whatsapp.com` on startup/reconnect to prevent deprecation and bans.
5. **Desktop Environment Agnostic (KDE Plasma & GNOME Support)**:
   - Respect native DE window decorations (Server-Side Decorations / KWin / Mutter). No duplicate CSD titlebars with foreign window controls that clash on KDE Plasma.
   - Respect desktop UI font family, system font size, and display scaling (`MediaQuery.textScalerOf(context)`).
   - Enforce **Wayland-native** execution (`GDK_BACKEND=wayland`).
6. **Icons**: Exclusively use `package:fluentui_system_icons` across the entire application. Zero standard Material icons.
7. **Persistent Session & Storage**:
   - Store device credentials in `~/.local/share/whatsapp-linux/session.db` (XDG compliant) so QR scan is only required once.
   - Local SQLite cache in `~/.local/share/whatsapp-linux/cache.db` for chats, messages, and preferences (`sqflite_common_ffi`).
8. **Git Version Control & Push Policy**:
   - Repository: `https://github.com/WolfSekhar/whatsapp-linux.git`
   - **Automatic Commits**: After completing any meaningful code change, feature, fix, or refactor, agents MUST automatically stage and create a clean git commit.
   - **Push Policy**: **NEVER push to the remote repository unless explicitly requested by the USER.**
   - **Privacy Protection**: Ensure session databases (`*.db`, `session.db`, `cache.db`) are strictly ignored and never committed.

---

## 2. Integrated Feature Set (Stages 1 – 5 Complete)

### 💬 Stage 1: Rich Media & Document Handling
- **Encrypted Media Decoders & Downloads**: Automatic local caching for images, video thumbnails, documents, and voice audio clips.
- **Media Viewer Modal (`MediaViewerDialog`)**: Fullscreen/dialog image viewer with pan, zoom, media info banner, and export to disk (`xdg-open` / file picker).
- **Attachment Picker & Send Pipeline**: File chooser modal for images and documents with upload progress indication.
- **Interactive Message Bubbles**: Inline media thumbnails, file size/name headers, download buttons, and tap-to-expand preview.

### ⚡ Stage 2: Message Interactions, Reactions, Quotes & Deletion
- **Context Menu & Message Actions**: Context popup supporting Reply, React, Copy Text, Forward, Star, Delete for Me, and Delete for Everyone.
- **Emoji Reactions System**: Quick emoji bar + expandable emoji picker modal with real-time reaction badges displayed directly on message bubbles.
- **Quoted Replies & Previews**: Banner preview in `ConversationInputArea` with dismiss button, and nested quote bubble rendering inside `MessageBubble`.
- **Message Status Indicator**: Real-time tick tracking (Pending clock, Sent single tick, Delivered double tick, Read double blue ticks).

### 🗂️ Stage 3: Chat List Management, Filtering, Pin, Archive & Mute
- **Filter Tabs**: Instant filtering by All, Unread, Favorites, and Groups.
- **Live Search Bar**: Search queries across chat names, phone numbers, and last message previews.
- **Chat Context Menu & Actions**:
  - Pin / Unpin chats (keeps pinned chats sorted at top).
  - Archive / Unarchive chats with dedicated archived section.
  - Mute / Unmute notifications (8 Hours, 1 Week, Always).
  - Mark as Read / Unread toggle.
  - Delete chat with confirmation.
- **Optimistic UI Updates**: Instant client-side state reactivity synchronized with local SQLite cache (`ChatDao`).

### 👥 Stage 4: Contact & Group Management & Info Drawer
- **Group & Contact Info Drawer (`GroupInfoDrawer`)**: Side drawer displaying group subject, description, creation date, admin roster, and member count.
- **Participant Roster & Roles**: Participant list with Admin badges, member search, and contextual actions (Make Admin, Dismiss Admin, Remove Member).
- **Group Settings & Permissions**: Dialogs to configure permissions (Who can edit group info, Who can send messages) and Add Participants modal.
- **Shared Media & Docs Gallery**: Tabbed browser inside the drawer showing all past media and documents shared in the conversation.
- **Daemon Group RPC Engine**: Full RPC endpoints in Go (`get_group_info`, `set_group_name`, `set_group_topic`, `set_group_photo`, `get_group_invite_link`, `update_group_participants`, `set_group_locked`, `leave_group`).

### ⚙️ Stage 5: User Profile, Status / Stories Viewer & App Settings
- **User Profile Management (`ProfileDrawer` & `ProfileEditableTile`)**:
  - Edit display / push name (`appstate.BuildSettingPushName`) and About bio (`SetStatusMessage`).
  - Profile photo viewer with edit button.
  - Read-only phone number / JID badge.
- **Status / Stories Viewer (`StatusStoriesViewer`)**:
  - Full desktop modal with story progress bar (`StoryProgressBar`), 5-second auto-advance timer, and pause on hover/hold.
  - Text stories rendered with background colors and typography; image stories with caption banners.
  - Contact sidebar (`StatusContactSidebar`) showing unread green story ring indicators.
  - Keyboard navigation (Left, Right, Space to pause/resume, Escape to close).
- **Application Settings Dialog (`SettingsDialog`)**:
  - **General**: "Enter is Send" toggle, "Start on boot" toggle, language selector.
  - **Chats & Appearance**: Theme mode (System / Light / Dark segmented control), wallpaper color palette selector, text size slider (0.8x to 1.3x).
  - **Privacy**: Last Seen & Online visibility, Profile Photo visibility, About visibility, Read Receipts switch, and Blocked Contacts manager (`BlockedContactsDialog` with add JID/phone to block and unblock actions).
  - **Notifications**: Desktop notifications switch, message preview toggle, sound alert toggle, and "Send Test Notification" action button.
  - **About & Diagnostics**: App & whatsmeow protocol versions, storage cache breakdown, "Clear Media Cache" button, and Logout button.
- **Linux Desktop Notifications (`LinuxNotificationService`)**: Wayland/X11 desktop notification dispatch using `notify-send` and native `canberra-gtk-play` audio alerts respecting user preferences.
- **Desktop Shell Navigation Rail (`DesktopShell`)**: Unified vertical rail housing Chat List, Status Stories viewer (with unread badge), Settings modal dialog, and bottom Profile Drawer avatar button.

---

## 3. Architecture & IPC Flow
```
┌────────────────────────────────────────────────────────┐
│                   Flutter Desktop (UI)                 │
│  - Native DE Window Frame (KDE Plasma SSD / GNOME)     │
│  - NativeWindowHeader (In-App Toolbar, No Duplicates)  │
│  - Fluent UI Icons (package:fluentui_system_icons)     │
│  - System Font & DPI Scaling Adapter                   │
│  - DesktopShell (Left Rail: Chats, Status, Settings)   │
│  - ChatConversationView (Bubbles, Quotes, Reactions)   │
│  - GroupInfoDrawer & ProfileDrawer                     │
│  - StatusStoriesViewer & MediaViewerDialog             │
│  - SettingsDialog (General, Appearance, Privacy, etc.) │
│  - SQLite Cache DAOs (ChatDao, MessageDao, PrefsDao)   │
│  - State Management & Repositories (SOLID interfaces)  │
│  - LinuxNotificationService (notify-send, canberra)    │
│  - DaemonProcessManager (Lifecycle & Health)           │
│  - IpcService (Stdin/Stdout JSON-Lines RPC)            │
└───────────────────────────▲────────────────────────────┘
                            │  JSON-RPC (stdin/stdout)
┌───────────────────────────▼────────────────────────────┐
│                    Go Daemon Engine                    │
│  - main.go (Daemon Entrypoint & Signals)               │
│  - version/fetcher.go (web.whatsapp.com version parser)│
│  - store/store.go (SQLite device credentials in XDG)   │
│  - wa/client.go (whatsmeow connection, QR, events)     │
│  - wa/group_client.go (Group metadata & participants)  │
│  - wa/profile_client.go (Profile, Privacy, Blocklist)  │
│  - cmd/request_handler.go (Central RPC dispatch)       │
│  - cmd/group_request_handler.go (Group actions)        │
│  - cmd/settings_request_handler.go (Settings actions)  │
│  - ipc/writer.go (JSON-RPC request/event broker)       │
└────────────────────────────────────────────────────────┘
```

---

## 4. Verification & Quality Standards
- [x] Initialized Flutter Linux project with Go daemon (`whatsmeow`).
- [x] Strict < 150 LOC per file maintained across all 80+ source files (max is 149 LOC).
- [x] Added safety mandate: Zero automated outbound messages.
- [x] 100% of icons use `package:fluentui_system_icons`.
- [x] Implemented `NativeWindowHeader` resolving KDE Plasma SSD double-titlebar bug.
- [x] Enforced Wayland backend (`GDK_BACKEND=wayland`).
- [x] Persistent XDG directory `~/.local/share/whatsapp-linux/session.db` (one-time QR pairing).
- [x] Local SQLite caching in `~/.local/share/whatsapp-linux/cache.db` via `ChatDao`, `MessageDao`, and `PreferencesDao`.
- [x] Stage 1 (Rich Media & Viewer) complete and verified.
- [x] Stage 2 (Message Interactions, Reactions & Quotes) complete and verified.
- [x] Stage 3 (Chat List Management, Filtering, Pin, Archive, Mute) complete and verified.
- [x] Stage 4 (Contact & Group Management, Info Drawer, Participant Actions) complete and verified.
- [x] Stage 5 (User Profile, Status Stories Viewer, Application Settings) complete and verified.
- [x] All Go tests passing (`go test ./...` in `daemon/`).
- [x] All Dart domain verification tests passing (`test/domain/`).
- [x] Static analysis audit (`flutter analyze`): **0 issues found**.
- [x] Interactive live hot reload running in Linux Wayland session.
