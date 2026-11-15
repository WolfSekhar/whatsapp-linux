import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// Reusable section card with desktop theme styling and borders.
class InfoSectionCard extends StatelessWidget {
  final List<Widget> children;

  const InfoSectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Simple info tile displaying an icon, label, and content string.
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final Color? iconColor;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: iconColor ?? secondaryColor),
      title: Text(title, style: TextStyle(color: secondaryColor, fontSize: 12)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: primaryColor, fontSize: 14),
      ),
    );
  }
}
