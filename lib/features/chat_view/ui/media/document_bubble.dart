import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/message_item.dart';
import '../../../../theme/app_colors.dart';

/// Renders a document attachment bubble with file name, size, icon, and action button.
class DocumentBubble extends StatelessWidget {
  final MessageItem message;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;

  const DocumentBubble({
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
    final name = message.fileName ?? message.text;
    final sizeStr = _formatSize(message.fileSize ?? 0);

    return InkWell(
      onTap: hasLocal ? onOpen : onDownload,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.black.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withAlpha(35),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(_documentIcon, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sizeStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                hasLocal ? FluentIcons.open_24_regular : FluentIcons.arrow_download_24_regular,
                size: 20,
              ),
              onPressed: hasLocal ? onOpen : onDownload,
            ),
          ],
        ),
      ),
    );
  }

  IconData get _documentIcon {
    final fn = (message.fileName ?? message.text).toLowerCase();
    final mime = (message.mimeType ?? '').toLowerCase();
    if (fn.endsWith('.pdf') || mime.contains('pdf')) {
      return FluentIcons.document_pdf_24_regular;
    }
    if (fn.endsWith('.zip') || fn.endsWith('.tar') || fn.endsWith('.gz')) {
      return FluentIcons.folder_zip_24_regular;
    }
    if (fn.endsWith('.txt') || fn.endsWith('.md')) {
      return FluentIcons.document_text_24_regular;
    }
    return FluentIcons.document_24_regular;
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
