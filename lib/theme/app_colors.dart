import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

/// Centralized color tokens combining WhatsApp brand with Yaru Linux desktop colors.
abstract final class AppColors {
  // WhatsApp Signature Brand Accents
  static const Color primaryGreen = Color(0xFF25D366);
  static const Color tealGreen = Color(0xFF128C7E);
  static const Color darkTeal = Color(0xFF075E54);
  static const Color viridian = YaruColors.viridian;

  // Dark Theme Palette (Zinc / Dark Slate)
  static const Color darkBackground = Color(0xFF111B21);
  static const Color darkPanel = Color(0xFF202C33);
  static const Color darkRail = Color(0xFF182229);
  static const Color darkBorder = Color(0xFF2A3942);
  static const Color darkInputBg = Color(0xFF202C33);
  static const Color darkTextPrimary = Color(0xFFE9EDEF);
  static const Color darkTextSecondary = Color(0xFF8696A0);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightPanel = Color(0xFFFFFFFF);
  static const Color lightRail = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0xFFE9EDEF);
  static const Color lightInputBg = Color(0xFFF0F2F5);
  static const Color lightTextPrimary = Color(0xFF111B21);
  static const Color lightTextSecondary = Color(0xFF667781);

  // Semantic
  static const Color unreadBadge = primaryGreen;
  static const Color errorRed = Color(0xFFEA0038);
}
