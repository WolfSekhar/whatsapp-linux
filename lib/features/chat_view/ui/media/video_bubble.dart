import 'dart:convert';
import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/message_item.dart';

/// Renders a video message thumbnail with play overlay, duration badge, and launch action.
class VideoBubble extends StatelessWidget {
  final MessageItem message;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;

  const VideoBubble({
    super.key,
    required this.message,
    this.onOpen,
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
          onTap: hasLocal ? onOpen : onDownload,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildThumbnail(),
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasLocal
                        ? FluentIcons.play_24_filled
                        : FluentIcons.arrow_download_24_filled,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (message.duration != null && message.duration! > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(190),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(message.duration!),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_hasCaption) ...[
          const SizedBox(height: 6),
          Text(message.text, style: const TextStyle(fontSize: 14, height: 1.3)),
        ],
      ],
    );
  }

  bool get _hasCaption {
    final t = message.text.trim();
    return t.isNotEmpty && t != '🎥 Video' && !t.startsWith('🎥');
  }

  Widget _buildThumbnail() {
    if (message.thumbnailBase64 != null &&
        message.thumbnailBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(message.thumbnailBase64!);
        return Image.memory(
          bytes,
          width: 280,
          height: 180,
          fit: BoxFit.cover,
        );
      } catch (_) {}
    }
    return Container(
      width: 280,
      height: 180,
      color: Colors.black26,
      child: const Center(
        child: Icon(FluentIcons.video_24_regular, size: 48, color: Colors.grey),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
