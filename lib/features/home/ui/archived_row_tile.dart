import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';
import '../../../theme/app_colors.dart';

/// Desktop tile representing the top Archived chats entry point.
class ArchivedRowTile extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const ArchivedRowTile({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return YaruListTile(
      onTap: onTap,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          FluentIcons.archive_24_regular,
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ),
      title: Text(
        'Archived',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
      ),
      trailing: count > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
