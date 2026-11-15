import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../../../theme/app_colors.dart';

/// Message input control bar supporting desktop keyboard submission and attachments.
class MessageInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;

  const MessageInputBar({
    super.key,
    required this.onSend,
    this.onAttach,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkRail : AppColors.lightRail;
    final inputBg = isDark ? AppColors.darkInputBg : AppColors.lightPanel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: bg,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.emoji_24_regular, size: 22),
            tooltip: 'Emoji',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(FluentIcons.attach_24_regular, size: 22),
            tooltip: 'Attach Media',
            onPressed: widget.onAttach,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.enter): _submit,
                },
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _hasText ? FluentIcons.send_24_filled : FluentIcons.mic_24_regular,
              size: 22,
              color: _hasText ? AppColors.primaryGreen : null,
            ),
            tooltip: _hasText ? 'Send Message' : 'Voice Message',
            onPressed: _hasText ? _submit : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
