import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/chat_filter_type.dart';
import '../../../../theme/app_colors.dart';

/// Horizontal pill bar providing category filtering for desktop chat list.
class ChatFilterPills extends StatelessWidget {
  final ChatFilterType activeFilter;
  final ValueChanged<ChatFilterType> onSelectFilter;
  final int unreadCount;
  final List<ChatFilterType> filters;

  const ChatFilterPills({
    super.key,
    required this.activeFilter,
    required this.onSelectFilter,
    this.unreadCount = 0,
    this.filters = const [
      ChatFilterType.all,
      ChatFilterType.unread,
      ChatFilterType.groups,
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildPill(context, filter, isDark),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPill(BuildContext context, ChatFilterType filter, bool isDark) {
    final isSelected = activeFilter == filter;
    final pillBg = isSelected
        ? AppColors.primaryGreen.withAlpha(isDark ? 50 : 35)
        : (isDark ? AppColors.darkPanel : AppColors.lightBackground);
    final pillBorder = isSelected
        ? AppColors.primaryGreen
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final textColor = isSelected
        ? (isDark ? AppColors.primaryGreen : AppColors.darkTeal)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelectFilter(filter),
        borderRadius: BorderRadius.circular(16),
        hoverColor: isSelected
            ? AppColors.primaryGreen.withAlpha(isDark ? 70 : 50)
            : (isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: pillBorder,
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (filter == ChatFilterType.unread && unreadCount > 0)
                _buildUnreadBadge(isSelected, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnreadBadge(bool isSelected, bool isDark) {
    final badgeBg = isSelected
        ? (isDark ? AppColors.primaryGreen : AppColors.darkTeal)
        : (isDark
            ? AppColors.primaryGreen.withAlpha(45)
            : AppColors.primaryGreen.withAlpha(35));
    final badgeText = isSelected
        ? (isDark ? const Color(0xFF111B21) : Colors.white)
        : (isDark ? AppColors.primaryGreen : AppColors.darkTeal);

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: badgeText,
        ),
      ),
    );
  }
}
