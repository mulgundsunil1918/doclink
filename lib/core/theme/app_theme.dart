import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get doctorTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.doctorSurface,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.doctorPrimary,
          secondary: AppColors.doctorAccent,
          surface: AppColors.doctorCard,
          error: AppColors.error,
        ),
        textTheme: AppTypography.doctorTextTheme,
        cardTheme: const CardThemeData(
          color: AppColors.doctorCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.doctorBorder, width: 0.5),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.doctorSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.doctorTextTheme.titleLarge,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.doctorCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.doctorBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.doctorBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.doctorPrimary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.slate400),
          hintStyle: const TextStyle(color: AppColors.slate500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.doctorPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTypography.doctorTextTheme.labelLarge,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.doctorCard,
          selectedItemColor: AppColors.doctorPrimary,
          unselectedItemColor: AppColors.slate500,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static ThemeData get patientTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.patientSurface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.patientPrimary,
          secondary: AppColors.doctorAccent,
          surface: AppColors.patientCard,
          error: AppColors.error,
        ),
        textTheme: AppTypography.patientTextTheme,
        cardTheme: const CardThemeData(
          color: AppColors.patientCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.patientBorder, width: 0.5),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.patientSurface,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.slate900),
          titleTextStyle: AppTypography.patientTextTheme.titleLarge
              ?.copyWith(color: AppColors.slate900),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.patientCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.patientBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.patientBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.patientPrimary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.patientPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
