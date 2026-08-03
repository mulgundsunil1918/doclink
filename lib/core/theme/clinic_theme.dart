import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/dl_loader.dart';

/// How dense the doctor wants the interface.
///
/// A paediatrician working through a full OPD list wants more rows on screen;
/// someone reviewing a single case wants room to breathe.
enum ClinicDensity {
  compact,
  comfortable,
  spacious;

  String get label => switch (this) {
        ClinicDensity.compact => 'Compact',
        ClinicDensity.comfortable => 'Comfortable',
        ClinicDensity.spacious => 'Spacious',
      };

  /// Multiplier applied to vertical padding across themed components.
  double get scale => switch (this) {
        ClinicDensity.compact => 0.82,
        ClinicDensity.comfortable => 1.0,
        ClinicDensity.spacious => 1.18,
      };
}

/// Every appearance choice the doctor can make, in one serialisable object.
///
/// This is the doctor's own branding — the same principle as the rest of
/// Doclink, where the practice belongs to them rather than to the platform.
@immutable
class ClinicTheme {
  const ClinicTheme({
    this.brand = defaultBrand,
    this.mode = ThemeMode.light,
    this.density = ClinicDensity.comfortable,
    this.cornerRadius = 16,
    this.fontScale = 1.0,
    this.loader = DlLoaderStyle.heartbeat,
    this.gradientAccents = true,
  });

  /// Doclink violet — matches the brand on doclink-site.
  static const defaultBrand = Color(0xFF6D4C9F);

  /// Starting points offered in settings. The doctor is not limited to these;
  /// the custom picker writes any colour it likes.
  static const presets = <String, Color>{
    'Doclink Violet': defaultBrand,
    'Blush': Color(0xFFDE638A),
    'Clinical Blue': Color(0xFF2563EB),
    'Teal': Color(0xFF0D9488),
    'Forest': Color(0xFF15803D),
    'Amber': Color(0xFFD97706),
    'Crimson': Color(0xFFDC2626),
    'Slate': Color(0xFF475569),
  };

  final Color brand;
  final ThemeMode mode;
  final ClinicDensity density;

  /// Base corner radius in logical pixels, 0 (sharp) to 28 (very round).
  final double cornerRadius;

  /// Multiplies every text size. Meaningful accessibility control for doctors
  /// reading dosages on a phone at the end of a long day.
  final double fontScale;

  final DlLoaderStyle loader;

  /// Whether buttons and headers use a brand gradient or a flat fill.
  final bool gradientAccents;

  ClinicTheme copyWith({
    Color? brand,
    ThemeMode? mode,
    ClinicDensity? density,
    double? cornerRadius,
    double? fontScale,
    DlLoaderStyle? loader,
    bool? gradientAccents,
  }) =>
      ClinicTheme(
        brand: brand ?? this.brand,
        mode: mode ?? this.mode,
        density: density ?? this.density,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        fontScale: fontScale ?? this.fontScale,
        loader: loader ?? this.loader,
        gradientAccents: gradientAccents ?? this.gradientAccents,
      );

  Map<String, dynamic> toJson() => {
        // toARGB32 rather than the deprecated .value.
        'brand': brand.toARGB32(),
        'mode': mode.name,
        'density': density.name,
        'cornerRadius': cornerRadius,
        'fontScale': fontScale,
        'loader': loader.name,
        'gradientAccents': gradientAccents,
      };

  /// Tolerant of missing or malformed keys — a bad stored value should fall
  /// back to the default, never leave the doctor staring at a broken app.
  factory ClinicTheme.fromJson(Map<String, dynamic> json) {
    T pick<T>(Iterable<T> values, Object? name, T fallback) {
      for (final v in values) {
        if ((v as dynamic).name == name) return v;
      }
      return fallback;
    }

    return ClinicTheme(
      brand: switch (json['brand']) {
        final int v => Color(v),
        _ => defaultBrand,
      },
      mode: pick(ThemeMode.values, json['mode'], ThemeMode.light),
      density: pick(ClinicDensity.values, json['density'], ClinicDensity.comfortable),
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble().clamp(0.0, 28.0) ?? 16,
      fontScale: (json['fontScale'] as num?)?.toDouble().clamp(0.85, 1.30) ?? 1.0,
      loader: pick(DlLoaderStyle.values, json['loader'], DlLoaderStyle.heartbeat),
      gradientAccents: json['gradientAccents'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ClinicTheme &&
      other.brand == brand &&
      other.mode == mode &&
      other.density == density &&
      other.cornerRadius == cornerRadius &&
      other.fontScale == fontScale &&
      other.loader == loader &&
      other.gradientAccents == gradientAccents;

  @override
  int get hashCode => Object.hash(
        brand, mode, density, cornerRadius, fontScale, loader, gradientAccents,
      );
}

/// Persists the doctor's appearance choices and exposes them to the app.
///
/// Storage is local: appearance is a per-device preference, so a doctor can run
/// a dense layout on their clinic tablet and a larger one on their phone.
class ClinicThemeController extends StateNotifier<ClinicTheme> {
  ClinicThemeController() : super(const ClinicTheme()) {
    _restore();
  }

  static const _key = 'clinic_theme_v1';

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      state = ClinicTheme.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt preference: keep the default rather than failing to start.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state.toJson()));
    } catch (_) {
      // A failed write only costs the doctor their preference on next launch.
    }
  }

  void update(ClinicTheme next) {
    state = next;
    _persist();
  }

  void setBrand(Color v) => update(state.copyWith(brand: v));
  void setMode(ThemeMode v) => update(state.copyWith(mode: v));
  void setDensity(ClinicDensity v) => update(state.copyWith(density: v));
  void setCornerRadius(double v) => update(state.copyWith(cornerRadius: v));
  void setFontScale(double v) => update(state.copyWith(fontScale: v));
  void setLoader(DlLoaderStyle v) => update(state.copyWith(loader: v));
  void setGradientAccents(bool v) => update(state.copyWith(gradientAccents: v));

  void reset() => update(const ClinicTheme());
}

final clinicThemeProvider =
    StateNotifierProvider<ClinicThemeController, ClinicTheme>(
  (ref) => ClinicThemeController(),
);

/// The doctor's chosen loader style, for widgets that just want to draw one.
final loaderStyleProvider = Provider<DlLoaderStyle>(
  (ref) => ref.watch(clinicThemeProvider).loader,
);
