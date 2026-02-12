import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand orange
  static const Color primary = Color(0xFFF7931A);
  static const Color primaryLight = Color(0xFFFFB347);
  static const Color primaryDark = Color(0xFFC97500);
  static const Color onPrimary = Color(0xFF000000);

  // Dark mode backgrounds
  static const Color bgApp = Color(0xFF0E0F12);
  static const Color bgSurface = Color(0xFF151821);
  static const Color bgSurfaceHover = Color(0xFF1C2030);

  // Dark mode borders
  static const Color borderFintech = Color(0xFF23283A);
  static const Color borderSubtle = Color(0xFF1C2030);

  // Dark mode text
  static const Color textPrimary = Color(0xFFE6E8EE);
  static const Color textSecondary = Color(0xFFA2A8BD);
  static const Color textMuted = Color(0xFF6E748A);

  // Navigation
  static const Color navIconInactive = Color(0xFF7B8198);
  static const Color navIconActive = primary;

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutrals
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);
}
