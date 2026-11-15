import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/quoted_item.dart';
import '../../../../theme/app_colors.dart';

/// Embedded card displayed inside a message bubble showing the quoted parent message.
class QuotedPreviewCard extends StatelessWidget {
  final QuotedItem quoted;
  final VoidCallback? onTap;

  const QuotedPreviewCard({
    super.key,
    required this.quoted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? Colors.black.withAlpha(50) : Colors.black.withAlpha(15);
    final senderColor = isDark ? const Color(0xFF53BDEB) : const Color(0xFF008069);
    final textSnippet = quoted.text.replaceAll('\n', ' ').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: senderColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _resolveSenderTitle(quoted.senderJid),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: senderColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        textSnippet.isNotEmpty ? textSnippet : 'Attachment',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveSenderTitle(String jid) {
    if (jid.isEmpty || jid == 'me') return 'You';
    final userPart = jid.split('@').first;
    if (userPart.isNotEmpty) {
      if (userPart.length > 10 && !userPart.contains('+')) {
        return '+$userPart';
      }
      return userPart;
    }
    return jid;
  }
}
