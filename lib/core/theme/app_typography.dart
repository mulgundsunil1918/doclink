import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get doctorTextTheme => TextTheme(
        displayLarge: GoogleFonts.syne(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.syne(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.syne(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 15, color: Colors.white),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, color: Colors.white70),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, color: Colors.white60),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      );

  static TextTheme get patientTextTheme => TextTheme(
        displayLarge: GoogleFonts.syne(
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.syne(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 15),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13),
        labelSmall: GoogleFonts.dmSans(fontSize: 11, letterSpacing: 0.8),
      );
}
