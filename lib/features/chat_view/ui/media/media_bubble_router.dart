import 'dart:convert';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/message_item.dart';
import 'audio_bubble.dart';
import 'document_bubble.dart';
import 'image_bubble.dart';
import 'video_bubble.dart';

/// Routes rich media messages to the appropriate typed bubble component.
class MediaBubbleRouter extends StatelessWidget {
  final MessageItem message;
  final VoidCallback? onMediaTap;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;

  const MediaBubbleRouter({
    super.key,
    required this.message,
    this.onMediaTap,
    this.onOpen,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.mediaType) {
      case 'image':
        return ImageBubble(
          message: message,
          onTap: onMediaTap,
          onDownload: onDownload,
        );
      case 'video':
        return VideoBubble(
          message: message,
          onOpen: onOpen,
          onDownload: onDownload,
        );
      case 'audio':
        return AudioBubble(
          message: message,
          onOpen: onOpen,
          onDownload: onDownload,
        );
      case 'document':
        return DocumentBubble(
          message: message,
          onOpen: onOpen,
          onDownload: onDownload,
        );
      case 'sticker':
        return _buildSticker();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSticker() {
    if (message.localPath != null && File(message.localPath!).existsSync()) {
      return Image.file(
        File(message.localPath!),
        width: 140,
        height: 140,
        fit: BoxFit.contain,
      );
    }
    if (message.thumbnailBase64 != null && message.thumbnailBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(message.thumbnailBase64!);
        return Image.memory(
          bytes,
          width: 140,
          height: 140,
          fit: BoxFit.contain,
        );
      } catch (_) {}
    }
    return const SizedBox(width: 140, height: 140);
  }
}
