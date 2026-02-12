import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/theme/app_colors.dart';
import 'package:water_log/theme/app_theme.dart';

void main() {
  group('AppTheme dark', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.dark;
    });

    test('has correct primary color', () {
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });

    test('has correct scaffold background', () {
      expect(theme.scaffoldBackgroundColor, equals(AppColors.bgApp));
    });

    test('has dark brightness', () {
      expect(theme.colorScheme.brightness, equals(Brightness.dark));
    });
  });
}
