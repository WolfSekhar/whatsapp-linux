# Stage 1: Rich Message Types & Media Handling Implementation Plan

## 1. Overview & Objective
Transform the native Linux WhatsApp desktop client from plain text strings (e.g. `"📷 Photo"`, `"📄 Document"`) into a full-featured media engine capable of downloading, caching, decrypting, and rendering:
- Image messages (inline thumbnails, full lightbox modal viewer, zoom/pan).
- Video messages (thumbnails with play duration badge, external player launcher).
- Voice notes & Audio (push-to-talk voice notes, duration, waveform visualizer, audio playback).
- Document attachments (MIME type detection, file name/size, file icon, native desktop download dialog).
- Stickers (transparent webp rendering).
- Encrypted media downloading and on-demand local caching under `~/.local/share/whatsapp-linux/media/`.

---

## 2. Architecture & File Breakdown (< 150 LOC per file)

### A. Go Daemon Backend (`daemon/pkg/wa/` & `daemon/pkg/ipc/`)
1. **`daemon/pkg/ipc/protocol.go`** (extend existing):
   - Add IPC actions: `ActionDownloadMedia = "download_media"`, `ActionSendMedia = "send_media"`.
   - Add structs: `DownloadMediaParams`, `DownloadMediaResult`, `SendMediaParams`, `SendMediaResult`.
   - Add media fields to `MessageData`: `MediaType`, `MediaURL`, `ThumbnailBase64`, `FileSize`, `MimeType`, `FileName`, `Duration`.
2. **`daemon/pkg/wa/media_extractor.go`**:
   - Extract media keys, direct paths, SHA256 hashes, file lengths, and thumbnails from `waE2E.Message`.
   - Extract `ImageMessage`, `VideoMessage`, `AudioMessage`, `DocumentMessage`, `StickerMessage`.
3. **`daemon/pkg/wa/media_downloader.go`**:
   - Handles `cli.Download(...)` and `cli.DownloadAny(...)`.
   - Decrypts cipher bytes and writes file to `~/.local/share/whatsapp-linux/media/<chat>/<msg_id>.<ext>`.
   - Returns absolute file path and MIME type over IPC.
4. **`daemon/pkg/wa/media_uploader.go`**:
   - Handles `cli.Upload(...)` for images and documents.
   - Wraps ciphertext in `waE2E.ImageMessage` or `waE2E.DocumentMessage`.

### B. Flutter Storage & Data Layer (`lib/core/storage/` & `lib/domain/`)
1. **`lib/core/storage/local_database.dart`**:
   - Add migration v2 for `messages` table:
     - `file_name TEXT`, `file_size INTEGER`, `mime_type TEXT`, `local_path TEXT`, `thumbnail TEXT`, `duration INTEGER`.
2. **`lib/core/storage/message_dao.dart`**:
   - Update `saveMessage` and `getMessages` to serialize/deserialize all media fields.
   - Add `updateMessageLocalPath(String id, String localPath)`.
3. **`lib/domain/models/message_item.dart`**:
   - Add media properties: `mediaType`, `fileName`, `fileSize`, `mimeType`, `localPath`, `thumbnailBase64`, `duration`.
4. **`lib/domain/repositories/i_media_repository.dart`**:
   - Pure abstract interface for `downloadMedia(String msgId, String chatJid)`, `openMediaFile(String path)`.
5. **`lib/domain/repositories/media_repository.dart`**:
   - Implementation calling `IpcService.sendRequest('download_media')` and updating SQLite cache.

### C. Flutter Presentation Layer (`lib/features/chat_view/ui/media/`)
1. **`lib/features/chat_view/ui/media/image_bubble.dart`**:
   - Renders image thumbnail or cached local file with rounded corners, timestamp, and read ticks.
   - On tap: opens full-screen `MediaViewerDialog`.
2. **`lib/features/chat_view/ui/media/video_bubble.dart`**:
   - Thumbnail with play overlay icon, video duration badge, and launch action.
3. **`lib/features/chat_view/ui/media/audio_bubble.dart`**:
   - Voice note waveform representation, play/pause button, elapsed time tracker.
4. **`lib/features/chat_view/ui/media/document_bubble.dart`**:
   - File icon (PDF, archive, code, generic), file name, size string (e.g. `2.4 MB`), and download/open button.
5. **`lib/features/chat_view/ui/media/media_bubble_router.dart`**:
   - Router delegating message item to correct bubble widget based on `message.mediaType`.
6. **`lib/features/chat_view/ui/media_viewer_dialog.dart`** (update):
   - Interactive zoom/pan, save-to-disk button using system file chooser, image preview.

---

## 3. Implementation Steps & Work Items
- [ ] **Step 1.1**: Update `MessageData` and IPC protocol with media fields.
- [ ] **Step 1.2**: Implement `media_extractor.go` to parse protobuf media metadata without downloading heavy bytes upfront.
- [ ] **Step 1.3**: Implement `media_downloader.go` in Go daemon to stream and decrypt media on demand.
- [ ] **Step 1.4**: Migrate SQLite schema and update `MessageItem` & `MessageDao`.
- [ ] **Step 1.5**: Build modular media bubbles (`ImageBubble`, `AudioBubble`, `DocumentBubble`, `VideoBubble`).
- [ ] **Step 1.6**: Wire on-demand download and local file viewing into `ChatConversationView`.
- [ ] **Step 1.7**: Verify all file sizes < 150 LOC and run `flutter analyze`.

---

## 4. Quality & Safety Verification
- **Safety**: Zero outbound test messages sent. All tests mock the IPC bus or use local media fixtures.
- **Icons**: Exclusively `package:fluentui_system_icons` (`FluentIcons.image_24_regular`, `FluentIcons.document_24_regular`, etc.).
- **Desktop**: File open actions utilize standard XDG handlers (`xdg-open` via `Process.run`).
