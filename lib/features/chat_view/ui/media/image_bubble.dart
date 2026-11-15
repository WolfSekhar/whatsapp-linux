import 'dart:convert';
import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/message_item.dart';

/// Renders an image message thumbnail or cached local file.
class ImageBubble extends StatelessWidget {
  final MessageItem message;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const ImageBubble({
    super.key,
    required this.message,
    this.onTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocal = message.localPath != null &&
        File(message.localPath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: hasLocal ? onTap : onDownload,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildImageContent(hasLocal),
                if (!hasLocal)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        FluentIcons.arrow_download_24_filled,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: onDownload,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_hasCaption) ...[
          const SizedBox(height: 6),
          Text(
            message.text,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
        ],
      ],
    );
  }

  bool get _hasCaption {
    final t = message.text.trim();
    return t.isNotEmpty && t != '📷 Photo' && !t.startsWith('📷');
  }

  Widget _buildImageContent(bool hasLocal) {
    if (hasLocal) {
      return Image.file(
        File(message.localPath!),
        width: 280,
        height: 200,
        fit: BoxFit.cover,
      );
    }
    if (message.thumbnailBase64 != null &&
        message.thumbnailBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(message.thumbnailBase64!);
        return Image.memory(
          bytes,
          width: 280,
          height: 200,
          fit: BoxFit.cover,
        );
      } catch (_) {}
    }
    return Container(
      width: 280,
      height: 180,
      color: Colors.black12,
      child: const Center(
        child: Icon(
          FluentIcons.image_24_regular,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}
