import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../domain/chat.dart';
import '../../../theme/app_colors.dart';
import 'media_viewer_dialog.dart';

/// Top bar for an active conversation pane showing participant info and actions.
class ChatHeader extends StatelessWidget {
  final Chat chat;

  const ChatHeader({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final name = chat.name;
    final clean = name.replaceAll('+', '').trim();
    final initial = clean.isNotEmpty ? clean[0].toUpperCase() : '?';

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: panelBg,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.tealGreen,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.image_24_regular, size: 20),
            tooltip: 'Media Viewer',
            onPressed: () => MediaViewerDialog.show(
              context,
              title: 'Media Gallery',
              subtitle: name,
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.search_24_regular, size: 20),
            tooltip: 'Search in Chat',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
