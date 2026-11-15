import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/quoted_item.dart';
import '../../../../theme/app_colors.dart';

/// Dismissible reply preview banner displayed above the message input bar.
class ReplyInputBanner extends StatelessWidget {
  final QuotedItem quoted;
  final VoidCallback onDismiss;

  const ReplyInputBanner({
    super.key,
    required this.quoted,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1F2C34) : const Color(0xFFF0F2F5);
    final accent = isDark ? const Color(0xFF53BDEB) : const Color(0xFF008069);
    final snippet = quoted.text.replaceAll('\n', ' ').trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withAlpha(40) : Colors.white.withAlpha(150),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _resolveSenderTitle(quoted.senderJid),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snippet.isNotEmpty ? snippet : 'Attachment',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  FluentIcons.dismiss_20_regular,
                  size: 18,
                ),
                tooltip: 'Cancel reply',
                onPressed: onDismiss,
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
