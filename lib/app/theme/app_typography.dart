import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return GoogleFonts.nunitoTextTheme();
  }

  // Display
  static TextStyle displayLarge({Color? color}) => GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.2,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.3,
      );

  // Headings
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.nunito(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.35,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  // Title
  static TextStyle titleLarge({Color? color}) => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.45,
      );

  // Body
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.55,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.55,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // Label
  static TextStyle labelLarge({Color? color}) => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // Button
  static TextStyle button({Color? color}) => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.2,
        letterSpacing: 0.3,
      );
}
