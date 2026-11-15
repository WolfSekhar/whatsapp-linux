import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/message_item.dart';
import '../../../../theme/app_colors.dart';

/// Renders a voice note or audio message with waveform bars and duration.
class AudioBubble extends StatelessWidget {
  final MessageItem message;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;

  const AudioBubble({
    super.key,
    required this.message,
    this.onOpen,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLocal = message.localPath != null &&
        File(message.localPath!).existsSync();
    final iconColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return SizedBox(
      width: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              hasLocal
                  ? FluentIcons.play_24_filled
                  : FluentIcons.arrow_download_24_filled,
              color: AppColors.primaryGreen,
              size: 26,
            ),
            onPressed: hasLocal ? onOpen : onDownload,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWaveform(isDark),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(message.duration ?? 0),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Icon(
                      FluentIcons.mic_16_filled,
                      size: 13,
                      color: iconColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(bool isDark) {
    final barHeights = [
      8.0, 14.0, 20.0, 12.0, 16.0, 24.0, 18.0, 10.0,
      15.0, 22.0, 28.0, 14.0, 19.0, 25.0, 12.0, 8.0,
      16.0, 22.0, 15.0, 10.0, 6.0
    ];
    final color = isDark ? Colors.white38 : Colors.black38;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: barHeights.map((h) {
        return Container(
          width: 2.5,
          height: h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
