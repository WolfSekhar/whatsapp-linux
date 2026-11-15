import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../controllers/chat_info_controller.dart';
import 'add_participant_dialog.dart';
import 'info_section_card.dart';
import 'participant_list_tile.dart';

/// Card displaying participants header, search field, and member list tiles.
class GroupParticipantsCard extends StatelessWidget {
  final ChatInfoController controller;

  const GroupParticipantsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final div = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final participants = controller.filteredParticipants;
    final total = controller.groupInfo?.participants.length ?? 0;

    return InfoSectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Text(
                '$total participants',
                style: TextStyle(
                  color: sec,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(FluentIcons.person_add_20_regular, size: 18),
                tooltip: 'Add Participant',
                onPressed: () => AddParticipantDialog.show(
                  context,
                  onAdd: controller.addParticipant,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              hintText: 'Search participants...',
              prefixIcon: const Icon(FluentIcons.search_20_regular, size: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onChanged: controller.setSearchQuery,
          ),
        ),
        const SizedBox(height: 4),
        Divider(height: 1, color: div),
        ...participants.map(
          (p) => ParticipantListTile(
            participant: p,
            isCurrentUserAdmin: true,
            onMakeAdmin: () => controller.promoteParticipant(p.jid),
            onDemoteAdmin: () => controller.demoteParticipant(p.jid),
            onRemove: () => controller.removeParticipant(p.jid),
            onMessage: () {},
          ),
        ),
      ],
    );
  }
}
