import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../domain/models/status_story_item.dart';

/// Card widget displaying the active status story (text card or image/media).
class StatusStoryCard extends StatelessWidget {
  final StatusStoryItem? story;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const StatusStoryCard({
    super.key,
    required this.story,
    required this.onPrevious,
    required this.onNext,
    required this.onPause,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final item = story;
    if (item == null) {
      return const Center(
        child: Text(
          'No status update selected',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final isImage = item.mediaType == 'image' && item.mediaUrl != null;

    return Listener(
      onPointerDown: (_) => onPause(),
      onPointerUp: (_) => onResume(),
      onPointerCancel: (_) => onResume(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: isImage ? Colors.black : _resolveBgColor(item.backgroundColor),
            alignment: Alignment.center,
            child: isImage ? _buildImage(item.mediaUrl!) : _buildTextContent(item.caption),
          ),
          if (isImage && item.caption != null && item.caption!.isNotEmpty)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.caption!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onPrevious,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(String? text) {
    return Padding(
      padding: const EdgeInsets.all(36.0),
      child: Text(
        text ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.contain);
    }
    return const Icon(
      FluentIcons.image_24_regular,
      color: Colors.white54,
      size: 64,
    );
  }

  Color _resolveBgColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF005C4B);
    var clean = hex.replaceAll('#', '');
    if (clean.length == 6) clean = 'FF$clean';
    final val = int.tryParse(clean, radix: 16);
    return val != null ? Color(val) : const Color(0xFF005C4B);
  }
}
