import 'package:material_ui/material_ui.dart';
import '../../../theme/app_colors.dart';

/// Panel displaying step-by-step instructions for phone QR linking.
class InstructionsPanel extends StatelessWidget {
  const InstructionsPanel({super.key});

  static const List<Map<String, String>> _steps = [
    {
      'num': '1',
      'text': 'Open WhatsApp on your phone',
    },
    {
      'num': '2',
      'text': 'Tap Menu or Settings and select Linked Devices',
    },
    {
      'num': '3',
      'text': 'Tap on Link a Device',
    },
    {
      'num': '4',
      'text': 'Point your phone to this screen to capture the code',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'To use WhatsApp on your computer:',
          style: TextStyle(
            color: primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        ..._steps.map((step) => _buildStep(step, primary, secondary, isDark)),
      ],
    );
  }

  Widget _buildStep(
    Map<String, String> step,
    Color primary,
    Color secondary,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              shape: BoxShape.circle,
            ),
            child: Text(
              step['num']!,
              style: TextStyle(
                color: primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                step['text']!,
                style: TextStyle(color: secondary, fontSize: 14, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
