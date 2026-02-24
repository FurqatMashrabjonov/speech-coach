import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFFB5A2FF);
  static const primaryLight = Color(0xFFD4CCFF);
  static const primaryDark = Color(0xFF8B7BDB);

  // Secondary (Pink/Rose)
  static const secondary = Color(0xFFFD7ED5);
  static const secondaryLight = Color(0xFFFDBEF4);

  // Accent (Lime green)
  static const accent = Color(0xFFC9EA00);
  static const accentLight = Color(0xFFE8F7A1);

  // Extended palette
  static const lime = Color(0xFFC9EA00);
  static const skyBlue = Color(0xFF39B4F7);
  static const gold = Color(0xFFFFD84D);
  static const lavender = Color(0xFFC9C1F4);
  static const softPink = Color(0xFFFDBEF4);

  // Success / Warning / Error
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFFF3B30);

  // Neutrals - Light
  static const white = Color(0xFFFFFFFF);
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF0EFF5);
  static const cardLight = Color(0xFFFFFFFF);
  static const dividerLight = Color(0xFFDFDEE6);
  static const textPrimaryLight = Color(0xFF1A1A1A);
  static const textSecondaryLight = Color(0xFF8E8E93);
  static const textTertiaryLight = Color(0xFF9898A0);

  // Neutrals - Dark (purple-tinted)
  static const backgroundDark = Color(0xFF13111A);
  static const surfaceDark = Color(0xFF1E1B2E);
  static const cardDark = Color(0xFF2A2640);
  static const dividerDark = Color(0xFF3A3555);
  static const textPrimaryDark = Color(0xFFF1F1F6);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const textTertiaryDark = Color(0xFF6B7280);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF13111A), Color(0xFF1E1B2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [lime, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category colors
  static const categoryPresentations = Color(0xFFB5A2FF);
  static const categoryInterviews = Color(0xFF39B4F7);
  static const categoryPublicSpeaking = Color(0xFFFD7ED5);
  static const categoryConversations = Color(0xFFC9EA00);
  static const categoryDebates = Color(0xFFFFD84D);
  static const categoryStorytelling = Color(0xFFC9C1F4);

  // Legacy aliases
  static const streakOrange = Color(0xFFFF9800);
  static const streakYellow = Color(0xFFFFEB3B);
}
