import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/reaction_item.dart';
import '../../../../theme/app_colors.dart';

/// Renders aggregate emoji reaction pills positioned at the corner of a message bubble.
class ReactionPills extends StatelessWidget {
  final List<ReactionItem> reactions;
  final ValueChanged<String>? onReactionTap;

  const ReactionPills({
    super.key,
    required this.reactions,
    this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // Group reactions by emoji
    final counts = <String, int>{};
    final userReactions = <String>{};
    for (final r in reactions) {
      counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
      if (r.senderJid == 'me') {
        userReactions.add(r.emoji);
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: counts.entries.map((entry) {
          final isMine = userReactions.contains(entry.key);
          return InkWell(
            onTap: () => onReactionTap?.call(entry.key),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isMine
                    ? AppColors.primaryGreen.withAlpha(isDark ? 50 : 30)
                    : bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMine ? AppColors.primaryGreen : border,
                  width: isMine ? 1.0 : 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (entry.value > 1) ...[
                    const SizedBox(width: 3),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
