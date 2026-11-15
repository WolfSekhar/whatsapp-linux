# Stage 2: Message Interactions Implementation Plan

## 1. Overview & Objective
Enable native desktop message interactions that mirror WhatsApp Web:
- **Emoji Reactions**: Hover emoji reaction quick bar (`👍 ❤️ 😂 😮 😢 🙏`), reaction pill badges underneath message bubbles with count, and reaction synchronization.
- **Quoted Replies**: Quoted context info extraction in protobuf, interactive reply banner preview above `MessageInputBar`, quoted preview card inside the bubble, and click-to-scroll to the original quoted message.
- **Desktop Context Menu**: Native right-click context menu on message bubbles offering: Reply, React, Star / Unstar, Copy Text, Forward, Delete for Me, Delete for Everyone.
- **Starring Messages**: Star indicator, persistent local SQLite flag, and daemon appstate synchronization.
- **Revoke / Deletion**: ProtocolMessage revoke handling (`"This message was deleted"`), local delete for me, and delete for everyone.
- **Forwarding**: Modal chat selector dialog to forward messages to any contact or group.

---

## 2. Architecture & File Breakdown (< 150 LOC per file)

### A. Go Daemon Backend (`daemon/pkg/wa/` & `daemon/pkg/ipc/`)
1. **`daemon/pkg/ipc/protocol.go`** (extend):
   - Actions: `ActionReact = "react"`, `ActionStar = "star"`, `ActionRevoke = "revoke"`.
   - Events: `EventReaction = "reaction"`, `EventRevoke = "revoke"`.
   - Structs: `ReactionData`, `RevokeData`, `QuotedMessageData`.
2. **`daemon/pkg/wa/reaction_handler.go`**:
   - Parses `waE2E.ReactionMessage{Key: ..., Text: ...}`.
   - Emits `ipc.EventReaction` with target message ID, sender JID, emoji, and timestamp.
   - Outbound `SendReaction(ctx, chatJID, targetMsgID, emoji)` via `cli.BuildReaction(...)`.
3. **`daemon/pkg/wa/quoted_handler.go`**:
   - Extracts `ContextInfo{StanzaID: ..., Participant: ..., QuotedMessage: ...}` from incoming extended text and media messages.
   - Populates `QuotedMessageData` in `ipc.MessageData`.
4. **`daemon/pkg/wa/revoke_handler.go`**:
   - Listens to `ProtocolMessage_REVOKE` events in whatsmeow.
   - Emits `ipc.EventRevoke` to mark the message as deleted in Flutter.
   - Outbound `RevokeMessage(ctx, chatJID, msgID)` via `cli.BuildRevoke(...)`.
5. **`daemon/pkg/wa/star_actions.go`**:
   - Implements `StarMessage(ctx, chatJID, msgID, isStarred)` using `appstate.BuildStar(...)`.

### B. Flutter Storage & Data Layer (`lib/core/storage/` & `lib/domain/`)
1. **`lib/core/storage/local_database.dart`**:
   - Migration for `messages` table:
     - `quoted_id TEXT`, `quoted_sender TEXT`, `quoted_text TEXT`, `is_starred INTEGER DEFAULT 0`, `is_revoked INTEGER DEFAULT 0`.
   - Create table `message_reactions`:
     - `msg_id TEXT`, `sender_jid TEXT`, `emoji TEXT`, `timestamp INTEGER`, PRIMARY KEY (`msg_id`, `sender_jid`).
2. **`lib/core/storage/reaction_dao.dart`**:
   - Manages reactions per message: `saveReaction`, `getReactions(String msgId)`, `deleteReaction`.
3. **`lib/domain/models/reaction_item.dart`**:
   - Model representing an emoji reaction: `msgId`, `senderJid`, `emoji`, `timestamp`.
4. **`lib/domain/models/quoted_item.dart`**:
   - Model representing a quoted parent message snippet.
5. **`lib/domain/repositories/i_interaction_repository.dart`**:
   - Pure contract for reactions, starring, replying, and revoking.
6. **`lib/domain/repositories/interaction_repository.dart`**:
   - Concrete implementation interacting with `IpcService` and `ReactionDao`.

### C. Flutter Presentation Layer (`lib/features/chat_view/ui/interactions/`)
1. **`lib/features/chat_view/ui/interactions/reaction_bar.dart`**:
   - Floating horizontal bar with standard emojis (`👍`, `❤️`, `😂`, `😮`, `😢`, `🙏`, `+` picker).
2. **`lib/features/chat_view/ui/interactions/reaction_pills.dart`**:
   - Small badge anchored at the bottom corner of a bubble showing emojis and aggregate counts.
3. **`lib/features/chat_view/ui/interactions/quoted_preview_card.dart`**:
   - Colored left vertical border with sender name and truncated text snippet rendered inside `MessageBubble`.
4. **`lib/features/chat_view/ui/interactions/reply_input_banner.dart`**:
   - Dismissible reply bar rendered directly above `MessageInputBar` showing `"Replying to..."` and close button.
5. **`lib/features/chat_view/ui/interactions/message_context_menu.dart`**:
   - Desktop right-click menu using `showMenu` with Fluent UI icons.
6. **`lib/features/chat_view/ui/interactions/forward_dialog.dart`**:
   - Dialog with search field to pick target chat and forward selected message.

---

## 3. Implementation Steps & Work Items
- [ ] **Step 2.1**: Extend IPC protocol with reaction, quoted context, and revoke models.
- [ ] **Step 2.2**: Implement Go reaction extractor, quoted message parser, and revoke handlers.
- [ ] **Step 2.3**: Update SQLite schema with reactions table and quoted fields; create `ReactionDao`.
- [ ] **Step 2.4**: Implement `ReplyInputBanner` above `MessageInputBar` and quote card inside `MessageBubble`.
- [ ] **Step 2.5**: Implement floating `ReactionBar` and `ReactionPills` widget.
- [ ] **Step 2.6**: Attach desktop `MessageContextMenu` to `MessageBubble` on secondary click (`onSecondaryTapUp`).
- [ ] **Step 2.7**: Verify all file sizes < 150 LOC and run `flutter analyze`.

---

## 4. Quality & Safety Verification
- **Safety**: Outbound reactions or revokes executed strictly on user demand; automated tests mock IPC streams.
- **Icons**: Exclusively `FluentIcons.emoji_smile_slight_24_regular`, `FluentIcons.arrow_reply_24_regular`, `FluentIcons.star_24_regular`, `FluentIcons.delete_24_regular`.
