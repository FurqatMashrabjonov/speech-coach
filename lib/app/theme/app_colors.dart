import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Warm Terracotta/Orange
  static const primary = Color(0xFFE8793A);
  static const primaryLight = Color(0xFFFADCC8);
  static const primaryDark = Color(0xFFC96830);

  // Secondary - Soft Peach (used sparingly)
  static const secondary = Color(0xFFE8793A);
  static const secondaryLight = Color(0xFFFBE8D8);

  // Accent - Warm Amber
  static const accent = Color(0xFFE8A849);
  static const accentLight = Color(0xFFFBE8D8);

  // Extended palette - Warm tones only
  static const lime = Color(0xFFE8A849);
  static const skyBlue = Color(0xFFD4845A);
  static const gold = Color(0xFFE8A849);
  static const lavender = Color(0xFFF2C4A0);
  static const softPink = Color(0xFFFBE8D8);

  // Success / Warning / Error
  static const success = Color(0xFF5A9A5C);
  static const warning = Color(0xFFE8A849);
  static const error = Color(0xFFD44C3F);

  // Neutrals - Light (warm-tinted)
  static const white = Color(0xFFFFFFFF);
  static const backgroundLight = Color(0xFFFAF8F5);
  static const surfaceLight = Color(0xFFF2EEEA);
  static const cardLight = Color(0xFFFFFFFF);
  static const dividerLight = Color(0xFFE8E4DF);
  static const textPrimaryLight = Color(0xFF1A1715);
  static const textSecondaryLight = Color(0xFF8E8880);
  static const textTertiaryLight = Color(0xFFA8A29E);

  // Neutrals - Dark (warm-tinted)
  static const backgroundDark = Color(0xFF161412);
  static const surfaceDark = Color(0xFF211E1B);
  static const cardDark = Color(0xFF2C2825);
  static const dividerDark = Color(0xFF3D3833);
  static const textPrimaryDark = Color(0xFFF5F0EB);
  static const textSecondaryDark = Color(0xFFA8A098);
  static const textTertiaryDark = Color(0xFF706860);

  // Gradients - Subtle, single-family
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFE8793A), Color(0xFFD4845A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF161412), Color(0xFF211E1B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFFE8793A), Color(0xFFD4845A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFFE8A849), Color(0xFFE8793A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category colors - Subtle warm variations
  static const categoryPresentations = Color(0xFFE8793A);
  static const categoryInterviews = Color(0xFFD4845A);
  static const categoryPublicSpeaking = Color(0xFFE0956A);
  static const categoryConversations = Color(0xFFC8956E);
  static const categoryDebates = Color(0xFFE8A849);
  static const categoryStorytelling = Color(0xFFD4A87A);

  // Legacy aliases
  static const streakOrange = Color(0xFFE8793A);
  static const streakYellow = Color(0xFFE8A849);
}
