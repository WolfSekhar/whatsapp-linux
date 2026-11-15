import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../theme/app_colors.dart';
import '../controllers/status_controller.dart';

/// Left sidebar listing contacts with available ephemeral status stories.
class StatusContactSidebar extends StatelessWidget {
  final StatusController controller;

  const StatusContactSidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final grouped = controller.groupedStories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 320,
      color: isDark ? AppColors.darkPanel : AppColors.lightPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: grouped.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final jid = grouped.keys.elementAt(index);
                      final stories = grouped[jid]!;
                      return _buildContactTile(context, jid, stories);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        'Status',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.status_24_regular, size: 40, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No status updates available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    String jid,
    List<dynamic> stories,
  ) {
    final isSelected = controller.selectedSenderJid == jid;
    final first = stories.first;
    final hasUnread = stories.any((s) => !s.isViewed);
    final count = stories.length;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      leading: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasUnread ? AppColors.primaryGreen : Colors.grey.withValues(alpha: 0.5),
            width: 2.2,
          ),
        ),
        child: const CircleAvatar(
          radius: 18,
          child: Icon(FluentIcons.person_24_regular, size: 20),
        ),
      ),
      title: Text(
        first.senderName.isNotEmpty ? first.senderName : jid,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        '$count ${count == 1 ? 'update' : 'updates'} • ${_formatTime(first.timestamp)}',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () => controller.selectContact(jid),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
