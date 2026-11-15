import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../theme/app_colors.dart';

/// Modal dialog displaying media attachments and documents with zoom and actions.
class MediaViewerDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? mediaType;
  final String? localPath;
  final VoidCallback? onDownload;

  const MediaViewerDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.mediaType,
    this.localPath,
    this.onDownload,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? mediaType,
    String? localPath,
    VoidCallback? onDownload,
  }) =>
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => MediaViewerDialog(
          title: title,
          subtitle: subtitle,
          mediaType: mediaType,
          localPath: localPath,
          onDownload: onDownload,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C1317) : const Color(0xFFF7F8FA);
    final cardBg = isDark ? AppColors.darkPanel : AppColors.lightPanel;

    return Dialog(
      backgroundColor: bgColor,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          children: [
            _buildTopBar(context, cardBg, isDark),
            const Divider(height: 1),
            Expanded(child: _buildMediaContent(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color cardBg, bool isDark) {
    final isDoc = mediaType == 'document';
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardBg,
      child: Row(
        children: [
          Icon(
            isDoc ? FluentIcons.document_24_filled : FluentIcons.image_24_filled,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 11, color: textColor)),
              ],
            ),
          ),
          if (onDownload != null)
            IconButton(
              icon: const Icon(FluentIcons.arrow_download_24_regular, size: 20),
              tooltip: 'Download',
              onPressed: onDownload,
            ),
          IconButton(
            icon: const Icon(FluentIcons.dismiss_24_regular, size: 20),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(bool isDark) {
    if (localPath != null && File(localPath!).existsSync() && mediaType == 'image') {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(child: Image.file(File(localPath!), fit: BoxFit.contain)),
      );
    }
    final isDoc = mediaType == 'document';
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isDoc ? FluentIcons.document_pdf_32_regular : FluentIcons.image_32_regular,
              size: 48,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(localPath ?? 'End-to-end encrypted media',
              style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }
}
