import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Reusable tile displaying contact phone number with copy button.
class ContactPhoneTile extends StatelessWidget {
  final String phone;
  final Color primaryColor;
  final Color secondaryColor;

  const ContactPhoneTile({
    super.key,
    required this.phone,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        FluentIcons.call_20_regular,
        size: 20,
        color: secondaryColor,
      ),
      title: Text(
        'Phone number',
        style: TextStyle(color: secondaryColor, fontSize: 12),
      ),
      subtitle: Text(
        phone,
        style: TextStyle(color: primaryColor, fontSize: 14),
      ),
      trailing: IconButton(
        icon: const Icon(FluentIcons.copy_20_regular, size: 18),
        tooltip: 'Copy phone number',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: phone));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
