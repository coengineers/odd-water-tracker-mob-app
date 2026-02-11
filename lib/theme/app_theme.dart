import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.neutral800,
      onSecondary: AppColors.neutral50,
      error: AppColors.error,
      onError: AppColors.neutral50,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
    );

    final headingStyle = const TextStyle(
      fontFamily: AppTypography.fontFamilyHeading,
      letterSpacing: AppTypography.letterSpacingHeading,
    );

    final bodyStyle = const TextStyle(
      fontFamily: AppTypography.fontFamilyBody,
    );

    final textTheme = TextTheme(
      displayLarge: headingStyle.copyWith(
        fontSize: AppTypography.fontSize4xl,
        fontWeight: FontWeight.w700,
        height: AppTypography.lineHeightTight,
      ),
      displayMedium: headingStyle.copyWith(
        fontSize: AppTypography.fontSize3xl,
        fontWeight: FontWeight.w700,
        height: AppTypography.lineHeightTight,
      ),
      displaySmall: headingStyle.copyWith(
        fontSize: AppTypography.fontSize2xl,
        fontWeight: FontWeight.w700,
        height: AppTypography.lineHeightTight,
      ),
      headlineLarge: headingStyle.copyWith(
        fontSize: AppTypography.fontSize2xl,
        fontWeight: FontWeight.w700,
        height: AppTypography.lineHeightTight,
      ),
      headlineMedium: headingStyle.copyWith(
        fontSize: AppTypography.fontSizeXl,
        fontWeight: FontWeight.w600,
        height: AppTypography.lineHeightTight,
      ),
      headlineSmall: headingStyle.copyWith(
        fontSize: AppTypography.fontSizeLg,
        fontWeight: FontWeight.w600,
        height: AppTypography.lineHeightTight,
      ),
      titleLarge: headingStyle.copyWith(
        fontSize: AppTypography.fontSizeLg,
        fontWeight: FontWeight.w500,
        height: AppTypography.lineHeightNormal,
      ),
      titleMedium: headingStyle.copyWith(
        fontSize: AppTypography.fontSizeBase,
        fontWeight: FontWeight.w500,
        height: AppTypography.lineHeightNormal,
      ),
      titleSmall: headingStyle.copyWith(
        fontSize: AppTypography.fontSizeSm,
        fontWeight: FontWeight.w500,
        height: AppTypography.lineHeightNormal,
      ),
      bodyLarge: bodyStyle.copyWith(
        fontSize: AppTypography.fontSizeBase,
        fontWeight: FontWeight.w400,
        height: AppTypography.lineHeightNormal,
      ),
      bodyMedium: bodyStyle.copyWith(
        fontSize: AppTypography.fontSizeSm,
        fontWeight: FontWeight.w400,
        height: AppTypography.lineHeightNormal,
      ),
      bodySmall: bodyStyle.copyWith(
        fontSize: AppTypography.fontSizeXs,
        fontWeight: FontWeight.w400,
        height: AppTypography.lineHeightNormal,
      ),
      labelLarge: bodyStyle.copyWith(
        fontSize: AppTypography.fontSizeSm,
        fontWeight: FontWeight.w500,
        height: AppTypography.lineHeightNormal,
      ),
      labelMedium: bodyStyle.copyWith(
        fontSize: AppTypography.fontSizeXs,
        fontWeight: FontWeight.w500,
        height: AppTypography.lineHeightNormal,
      ),
      labelSmall: bodyStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: AppTypography.lineHeightNormal,
      ),
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgApp,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgApp,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingStyle.copyWith(
          fontSize: AppTypography.fontSizeLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.navIconActive,
        unselectedItemColor: AppColors.navIconInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: const BorderSide(color: AppColors.borderFintech),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.borderFintech),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.borderFintech),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderFintech,
        thickness: 1,
      ),
    );
  }
}
