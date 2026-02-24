import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // Theme-aware colors
  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary =>
      isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get surface =>
      isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get card => isDark ? AppColors.cardDark : AppColors.cardLight;
  Color get background =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get divider =>
      isDark ? AppColors.dividerDark : AppColors.dividerLight;
  List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))]
      : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))];

  // Media Query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  double get bottomPadding => padding.bottom;
  double get topPadding => padding.top;

  // Snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

}
