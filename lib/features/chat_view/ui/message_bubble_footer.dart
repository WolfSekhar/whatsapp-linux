import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../domain/models/message_item.dart';
import '../../../theme/app_colors.dart';

/// Renders timestamp, star indicator, and read/delivery receipt ticks for a message.
class MessageBubbleFooter extends StatelessWidget {
  final MessageItem message;

  const MessageBubbleFooter({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final h = message.timestamp.hour.toString().padLeft(2, '0');
    final m = message.timestamp.minute.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isStarred) ...[
          const Icon(FluentIcons.star_12_filled, size: 11, color: Colors.amber),
          const SizedBox(width: 4),
        ],
        Text('$h:$m', style: TextStyle(fontSize: 11, color: timeColor)),
        if (message.isFromMe) ...[
          const SizedBox(width: 4),
          Icon(
            message.status == 'read'
                ? FluentIcons.checkmark_starburst_16_regular
                : FluentIcons.checkmark_16_regular,
            size: 13,
            color: message.status == 'read' ? const Color(0xFF53BDEB) : Colors.grey,
          ),
        ],
      ],
    );
  }
}
