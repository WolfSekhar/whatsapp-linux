# AGENTS.md — Native WhatsApp for Linux

## ⚠️ CRITICAL SAFETY & PRIVACY RULE (ZERO TOLERANCE)
> **NO AUTOMATED TEST MESSAGES SHALL EVER BE SENT TO ANY CONTACT OR CHAT.**
> Under NO circumstances should any agent, script, test suite, or automation dispatch outbound messages to real WhatsApp contacts or phone numbers.
> **All messaging testing will be performed strictly by the USER personally as a human.**
> Any automated testing must mock or sandbox the IPC message bus.

---

## 1. Project Overview & Philosophy
A native, lightweight, privacy-focused WhatsApp desktop client for Linux built using **Flutter Desktop** (frontend) and a dedicated **Go daemon** powered by `whatsmeow` (WhatsApp Multi-Device Protocol).

### Key Constraints & Architecture Standards
1. **Strict File Size Limit**: Every single source file (Dart and Go) MUST be **strictly under 150 lines of code**.
2. **SOLID Design Principles**:
   - **S**ingle Responsibility: One class/module does exactly one thing.
   - **O**pen/Closed: Extensible through interfaces/abstract classes without altering core logic.
   - **L**iskov Substitution: High-level services consume abstractions (`IAuthRepository`, `IChatRepository`, `IIpcService`, `IDaemonProcessManager`).
   - **I**nterface Segregation: Fine-grained, focused interfaces.
   - **D**ependency Inversion: High-level modules do not depend on low-level modules; both depend on abstractions.
3. **Modularity**: Small, decoupled components to minimize AI token footprint and maximize testability.
4. **Zero Maintenance Dynamic Versioning**: Auto-fetching client version string from `web.whatsapp.com` on startup/reconnect to prevent deprecation and bans.
5. **Desktop Environment Agnostic (KDE Plasma & GNOME Support)**:
   - Respect native DE window decorations (Server-Side Decorations / KWin / Mutter). No duplicate CSD titlebars with foreign window controls that clash on KDE Plasma.
   - Respect desktop UI font family, system font size, and display scaling (`MediaQuery.textScalerOf(context)`).
   - Enforce **Wayland-native** execution (`GDK_BACKEND=wayland`).
6. **Icons**: Exclusively use `package:fluentui_system_icons` across the entire application.
7. **Persistent Session & Storage**:
   - Store device credentials in `~/.local/share/whatsapp-linux/session.db` (XDG compliant) so QR scan is only required once.
   - Local SQLite cache in `~/.local/share/whatsapp-linux/cache.db` for chats and message history (`sqflite_common_ffi`).
8. **Active Chat & Media Viewer**:
   - Interactive chat pane with speech bubbles, delivery status indicators, and keyboard message input bar (Enter to send).
   - Dedicated modal media viewer for end-to-end encrypted images and documents.
9. **Human-Only Live Messaging**: Automated systems are strictly forbidden from transmitting real messages.
10. **Git Version Control & Push Policy**:
   - Repository: `https://github.com/WolfSekhar/whatsapp-linux.git`
   - **Automatic Commits**: After completing any meaningful code change, feature, fix, or refactor, agents MUST automatically stage and create a clean git commit.
   - **Push Policy**: **NEVER push to the remote repository unless explicitly requested by the USER.**
   - **Privacy Protection**: Ensure session databases (`*.db`, `session.db`, `cache.db`) are strictly ignored and never committed.

---

## 2. Architecture & IPC Flow
```
┌────────────────────────────────────────────────────────┐
│                   Flutter Desktop (UI)                 │
│  - Native DE Window Frame (KDE Plasma SSD / GNOME)     │
│  - NativeWindowHeader (In-App Toolbar, No Duplicates)  │
│  - Fluent UI Icons (package:fluentui_system_icons)     │
│  - System Font & DPI Scaling Adapter                   │
│  - Active Chat Conversation View & Input Bar           │
│  - Media Viewer Modal (Images / Documents)             │
│  - SQLite Cache DAOs (ChatDao, MessageDao)             │
│  - State Management & Repositories (SOLID interfaces)  │
│  - DaemonProcessManager (Lifecycle & Health)           │
│  - IpcService (Stdin/Stdout JSON-Lines RPC)            │
└───────────────────────────▲────────────────────────────┘
                            │  JSON-RPC (stdin/stdout)
┌───────────────────────────▼────────────────────────────┐
│                    Go Daemon Engine                    │
│  - main.go (Daemon Entrypoint & Signals)               │
│  - version/fetcher.go (web.whatsapp.com version parser)│
│  - store/store.go (SQLite device credentials in XDG)   │
│  - wa/client.go (whatsmeow connection, QR, send_msg)   │
│  - ipc/writer.go (JSON-RPC request/event broker)       │
└────────────────────────────────────────────────────────┘
```

---

## 3. Workstream Status & Quality Verification
- [x] Initialized Flutter Linux project with Go daemon (`whatsmeow`).
- [x] Strict < 150 LOC per file maintained across all 57 source files (max is 146 LOC).
- [x] Added safety mandate: Zero automated outbound messages.
- [x] Migrated 100% of icons to `package:fluentui_system_icons`.
- [x] Implemented `NativeWindowHeader` resolving KDE Plasma SSD double-titlebar bug.
- [x] Enforced Wayland backend (`GDK_BACKEND=wayland`).
- [x] Configured persistent XDG directory `~/.local/share/whatsapp-linux/session.db` (one-time QR pairing).
- [x] Implemented local SQLite caching in `~/.local/share/whatsapp-linux/cache.db` via `ChatDao` and `MessageDao`.
- [x] Implemented active message sending/receiving UI (`ChatConversationView`, `MessageBubble`, `MessageInputBar`).
- [x] Implemented media viewer component (`MediaViewerDialog`).
- [x] Inherited system desktop font family and scaling (`MediaQuery.textScalerOf(context)`).
- [x] Captured live Wayland screenshot via `spectacle` and verified visual layout.
- [x] Full static analysis audit (`flutter analyze`): **0 issues found**.
