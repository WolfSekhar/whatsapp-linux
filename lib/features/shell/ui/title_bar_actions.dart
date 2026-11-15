import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

/// Header action buttons providing quick desktop actions.
class TitleBarActions extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onSettings;

  const TitleBarActions({
    super.key,
    this.onRefresh,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(FluentIcons.arrow_clockwise_24_regular, size: 18),
            tooltip: 'Refresh',
            onPressed: onRefresh,
          ),
        if (onSettings != null)
          IconButton(
            icon: const Icon(FluentIcons.settings_24_regular, size: 18),
            tooltip: 'Settings',
            onPressed: onSettings,
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
