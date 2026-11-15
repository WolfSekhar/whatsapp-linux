import 'package:material_ui/material_ui.dart';
import '../../../../theme/app_colors.dart';

/// Floating emoji reaction bar providing quick reactions on message hover/context.
class ReactionBar extends StatelessWidget {
  static const List<String> defaultEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  final ValueChanged<String> onReact;
  final VoidCallback? onDismiss;

  const ReactionBar({
    super.key,
    required this.onReact,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: defaultEmojis.map((emoji) {
            return _EmojiButton(
              emoji: emoji,
              onTap: () {
                onReact(emoji);
                onDismiss?.call();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiButton({required this.emoji, required this.onTap});

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.25 : 1.0,
            _isHovered ? 1.25 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
