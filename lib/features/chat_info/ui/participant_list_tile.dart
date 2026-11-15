import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../domain/models/group_participant.dart';
import '../../../theme/app_colors.dart';

/// Single group participant tile displaying avatar, admin badge, and action menu.
class ParticipantListTile extends StatelessWidget {
  final GroupParticipant participant;
  final bool isCurrentUserAdmin;
  final VoidCallback? onMakeAdmin;
  final VoidCallback? onDemoteAdmin;
  final VoidCallback? onRemove;
  final VoidCallback? onMessage;

  const ParticipantListTile({
    super.key,
    required this.participant,
    this.isCurrentUserAdmin = false,
    this.onMakeAdmin,
    this.onDemoteAdmin,
    this.onRemove,
    this.onMessage,
  });

  String get _displayName {
    final name = participant.displayName;
    if (name != null && name.trim().isNotEmpty) return name;
    return participant.jid.split('@').first;
  }

  Widget _buildAvatar() {
    final name = _displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.tealGreen,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget? _buildAdminBadge() {
    if (!participant.isAdmin && !participant.isSuperAdmin) return null;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withAlpha(35),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primaryGreen, width: 0.8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.shield_person_20_regular,
            size: 12,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 4),
          Text(
            'Group Admin',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _item(String v, IconData i, String t, [Color? c]) =>
      PopupMenuItem<String>(
        value: v,
        child: Row(
          children: [
            Icon(i, size: 18, color: c),
            const SizedBox(width: 8),
            Text(t, style: TextStyle(color: c)),
          ],
        ),
      );

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) => [
    _item('msg', FluentIcons.chat_20_regular, 'Message $_displayName'),
    if (isCurrentUserAdmin) ...[
      if (!participant.isAdmin)
        _item('mk', FluentIcons.shield_badge_20_regular, 'Make group admin')
      else
        _item('dm', FluentIcons.shield_dismiss_20_regular, 'Dismiss admin'),
      _item('rm', FluentIcons.person_delete_20_regular, 'Remove', Colors.red),
    ],
  ];

  void _onMenuSelected(String a) {
    if (a == 'msg') onMessage?.call();
    if (a == 'mk') onMakeAdmin?.call();
    if (a == 'dm') onDemoteAdmin?.call();
    if (a == 'rm') onRemove?.call();
  }

  @override
  Widget build(BuildContext context) {
    final badge = _buildAdminBadge();
    return ListTile(
      leading: _buildAvatar(),
      title: Row(
        children: [
          Flexible(
            child: Text(
              _displayName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?badge,
        ],
      ),
      subtitle: Text(
        participant.jid,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(FluentIcons.more_vertical_24_regular, size: 18),
        tooltip: 'More options',
        onSelected: _onMenuSelected,
        itemBuilder: _buildMenuItems,
      ),
    );
  }
}
