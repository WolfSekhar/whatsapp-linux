import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../theme/app_colors.dart';
import '../../controllers/settings_controller.dart';

/// Tab for customizing theme mode, chat wallpaper, and desktop font scaling.
class ChatsAppearanceTab extends StatelessWidget {
  final SettingsController controller;

  const ChatsAppearanceTab({super.key, required this.controller});

  static const _wallpapers = [
    ('default', 'Default', Color(0xFF111B21)),
    ('teal', 'Teal', Color(0xFF075E54)),
    ('doodles', 'Doodles', Color(0xFF1F2C34)),
    ('midnight', 'Midnight', Color(0xFF0C1317)),
    ('slate', 'Slate', Color(0xFF263238)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final prefs = controller.preferences;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _header('Theme Mode'),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'system',
                  label: Text('System'),
                  icon: Icon(FluentIcons.desktop_24_regular),
                ),
                ButtonSegment(
                  value: 'light',
                  label: Text('Light'),
                  icon: Icon(FluentIcons.weather_sunny_24_regular),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Dark'),
                  icon: Icon(FluentIcons.weather_moon_24_regular),
                ),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) => controller.updateThemeMode(s.first),
            ),
            const Divider(height: 32),
            _header('Chat Wallpaper'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _wallpapers
                    .map((w) => _buildTile(w.$1, w.$2, w.$3, prefs.customWallpaper))
                    .toList(),
              ),
            ),
            const Divider(height: 32),
            _header('Text Scaling'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(FluentIcons.text_font_size_24_regular, size: 16),
                Expanded(
                  child: Slider(
                    value: prefs.fontScale.clamp(0.8, 1.3),
                    min: 0.8,
                    max: 1.3,
                    divisions: 5,
                    label: '${(prefs.fontScale * 100).round()}%',
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) => controller.updateFontScale(v),
                  ),
                ),
                const Icon(FluentIcons.text_font_size_24_regular, size: 24),
                const SizedBox(width: 8),
                Text('${(prefs.fontScale * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _header(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      );

  Widget _buildTile(String id, String label, Color col, String? current) {
    final isSelected = (current == null && id == 'default') || current == id;
    return InkWell(
      onTap: () => controller.updateWallpaper(id == 'default' ? null : id),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: col,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(FluentIcons.checkmark_24_regular,
                      color: AppColors.primaryGreen, size: 22)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
