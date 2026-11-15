import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../theme/app_colors.dart';
import '../../controllers/settings_controller.dart';

/// General settings tab for keyboard input, auto-start, and language options.
class GeneralTab extends StatefulWidget {
  final SettingsController controller;

  const GeneralTab({super.key, required this.controller});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  bool _startOnBoot = false;
  String _selectedLanguage = 'system';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('Keyboard & Messaging'),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(FluentIcons.keyboard_24_regular),
              title: const Text('Enter is Send'),
              subtitle: const Text(
                'Press Enter to send message, Shift+Enter for newline',
              ),
              activeThumbColor: AppColors.primaryGreen,
              value: widget.controller.preferences.enterIsSend,
              onChanged: (val) => widget.controller.updateEnterIsSend(val),
            ),
            const Divider(height: 32),
            _buildSectionHeader('System Integration'),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(FluentIcons.power_24_regular),
              title: const Text('Start on system boot'),
              subtitle: const Text(
                'Automatically launch WhatsApp in background on login',
              ),
              activeThumbColor: AppColors.primaryGreen,
              value: _startOnBoot,
              onChanged: (val) => setState(() => _startOnBoot = val),
            ),
            const Divider(height: 32),
            _buildSectionHeader('Language'),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(FluentIcons.local_language_24_regular),
              title: const Text('Display Language'),
              subtitle: const Text('Choose interface language'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text('System Default'),
                  ),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                  DropdownMenuItem(value: 'pt', child: Text('Português')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
