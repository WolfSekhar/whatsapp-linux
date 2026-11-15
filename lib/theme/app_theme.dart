import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';
import 'app_colors.dart';

/// App theme configurations providing native Linux desktop theme integration.
abstract final class AppTheme {
  /// Linux desktop light theme styled with WhatsApp viridian accents.
  static ThemeData get lightTheme {
    return createYaruLightTheme(
      primaryColor: AppColors.tealGreen,
      elevatedButtonColor: AppColors.tealGreen,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightPanel,
      dividerColor: AppColors.lightBorder,
      // Inherit system default font family from desktop environment (KDE/GNOME)
      textTheme: const TextTheme(),
    );
  }

  /// Linux desktop dark theme styled with WhatsApp viridian accents.
  static ThemeData get darkTheme {
    return createYaruDarkTheme(
      primaryColor: AppColors.primaryGreen,
      elevatedButtonColor: AppColors.primaryGreen,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkPanel,
      dividerColor: AppColors.darkBorder,
      // Inherit system default font family from desktop environment (KDE/GNOME)
      textTheme: const TextTheme(),
    );
  }
}
