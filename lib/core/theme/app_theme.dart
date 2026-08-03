import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'clinic_theme.dart';

class AppTheme {
  AppTheme._();

  /// Default light theme, used before the doctor's preferences load and by any
  /// caller that just wants "the Doclink look".
  static ThemeData get light => from(const ClinicTheme(), Brightness.light);

  // Kept so existing screens referencing these keep compiling.
  static ThemeData get doctorTheme => light;
  static ThemeData get patientTheme => light;

  /// Builds a complete theme from the doctor's [ClinicTheme] choices.
  ///
  /// Everything downstream — buttons, inputs, cards, nav, chips, dialogs —
  /// derives from here, so changing a single preference re-skins the whole app
  /// without touching a screen.
  static ThemeData from(ClinicTheme cfg, Brightness brightness) {
    final dark = brightness == Brightness.dark;

    // Seed the harmonious extras from the brand, then pin primary to exactly
    // the colour the doctor picked — a seeded scheme drifts, and a doctor who
    // chooses their practice colour should get that colour.
    final seeded = ColorScheme.fromSeed(
      seedColor: cfg.brand,
      brightness: brightness,
    );
    final scheme = seeded.copyWith(
      primary: cfg.brand,
      onPrimary: _readableOn(cfg.brand),
      error: dark ? const Color(0xFFFF6B6B) : AppColors.error,
    );

    final surface = dark ? const Color(0xFF17121F) : Colors.white;
    final background = dark ? const Color(0xFF0F0B16) : _tint(cfg.brand);
    final onSurface = dark ? const Color(0xFFEDE7F3) : AppColors.textPrimary;
    final onSurfaceMuted = dark ? const Color(0x99EDE7F3) : AppColors.textSecondary;
    final border = dark ? const Color(0xFF2C2438) : AppColors.border;

    final r = cfg.cornerRadius;
    final d = cfg.density.scale;
    final text = _textTheme(cfg.fontScale, onSurface, onSurfaceMuted, dark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: text,
      dividerColor: border,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        foregroundColor: onSurface,
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: text.titleLarge?.copyWith(
          fontSize: 18 * cfg.fontScale,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurfaceMuted, size: 22),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1E1829) : AppColors.surfaceVariant,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14 * d),
        border: _inputBorder(r, border),
        enabledBorder: _inputBorder(r, border),
        focusedBorder: _inputBorder(r, cfg.brand, width: 2),
        errorBorder: _inputBorder(r, scheme.error),
        labelStyle: TextStyle(color: onSurfaceMuted, fontSize: 14 * cfg.fontScale),
        hintStyle: TextStyle(
          color: onSurfaceMuted.withValues(alpha: 0.7),
          fontSize: 14 * cfg.fontScale,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cfg.brand,
          foregroundColor: _readableOn(cfg.brand),
          elevation: 0,
          minimumSize: Size(double.infinity, 52 * d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r * 0.85),
          ),
          textStyle: TextStyle(
            fontSize: 15 * cfg.fontScale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cfg.brand,
          side: BorderSide(color: border),
          minimumSize: Size(double.infinity, 52 * d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r * 0.85),
          ),
          textStyle: TextStyle(
            fontSize: 15 * cfg.fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cfg.brand,
          textStyle: TextStyle(
            fontSize: 14 * cfg.fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cfg.brand,
        foregroundColor: _readableOn(cfg.brand),
        elevation: 2,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: cfg.brand,
        unselectedItemColor: onSurfaceMuted.withValues(alpha: 0.65),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11 * cfg.fontScale,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11 * cfg.fontScale),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: cfg.brand.withValues(alpha: 0.14),
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: dark ? const Color(0xFF1E1829) : AppColors.surfaceVariant,
        selectedColor: cfg.brand.withValues(alpha: dark ? 0.28 : 0.14),
        labelStyle: TextStyle(
          fontSize: 12 * cfg.fontScale,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6 * d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r * 1.25),
        ),
        side: BorderSide(color: border, width: 0.5),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r * 1.15),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(r * 1.3)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF2C2438) : AppColors.slate800,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 13 * cfg.fontScale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r * 0.75),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cfg.brand : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? cfg.brand.withValues(alpha: 0.4)
              : null,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: cfg.brand,
        thumbColor: cfg.brand,
        inactiveTrackColor: cfg.brand.withValues(alpha: 0.2),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: cfg.brand),

      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceMuted,
        textColor: onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r * 0.75),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: cfg.brand,
        unselectedLabelColor: onSurfaceMuted,
        indicatorColor: cfg.brand,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(double r, Color c, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(r * 0.75),
        borderSide: BorderSide(color: c, width: width),
      );

  /// A very light wash of the brand so the background belongs to the palette
  /// instead of being flat grey.
  static Color _tint(Color brand) =>
      Color.alphaBlend(brand.withValues(alpha: 0.05), const Color(0xFFF8FAFC));

  /// Black or white, whichever stays legible on [c].
  static Color _readableOn(Color c) =>
      c.computeLuminance() > 0.55 ? const Color(0xFF1A1523) : Colors.white;

  static TextTheme _textTheme(
    double s,
    Color primary,
    Color secondary,
    bool dark,
  ) {
    final muted = dark ? const Color(0x8AEDE7F3) : AppColors.textMuted;
    return TextTheme(
      displayLarge: TextStyle(fontSize: 36 * s, fontWeight: FontWeight.w800, color: primary, letterSpacing: -1),
      displayMedium: TextStyle(fontSize: 28 * s, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 24 * s, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: TextStyle(fontSize: 20 * s, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontSize: 18 * s, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700, color: primary),
      titleMedium: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600, color: primary),
      titleSmall: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: TextStyle(fontSize: 15 * s, color: primary, height: 1.5),
      bodyMedium: TextStyle(fontSize: 13 * s, color: secondary, height: 1.5),
      bodySmall: TextStyle(fontSize: 12 * s, color: muted),
      labelLarge: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: primary),
      labelSmall: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w500, letterSpacing: 0.4, color: muted),
    );
  }
}
