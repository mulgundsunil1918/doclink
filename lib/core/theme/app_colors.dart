import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  // Doclink violet/blush, matched to the identity on doclink-site so the
  // marketing site and the product read as one product.
  static const primary        = Color(0xFF6D4C9F);
  static const primaryDark    = Color(0xFF573D80);
  static const primaryDeep    = Color(0xFF4A3267);
  static const primaryLight   = Color(0xFFF3EDFA);
  static const primaryMid     = Color(0xFFD6C7EC);

  static const accent         = Color(0xFFDE638A);
  static const accentDark     = Color(0xFFC04C72);
  static const accentLight    = Color(0xFFFDF0F4);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const background     = Color(0xFFF9F7FC);
  static const surface        = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF6F3FA);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const textPrimary    = Color(0xFF1F1730);
  static const textSecondary  = Color(0xFF574A6B);
  static const textMuted      = Color(0xFF9A8FAD);

  // ── Border ────────────────────────────────────────────────────────────────
  static const border         = Color(0xFFE7E0F0);
  static const borderLight    = Color(0xFFF2EDF8);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const success        = Color(0xFF22C55E);
  static const successLight   = Color(0xFFF0FDF4);
  static const warning        = Color(0xFFF59E0B);
  static const warningLight   = Color(0xFFFFFBEB);
  static const error          = Color(0xFFEF4444);
  static const errorLight     = Color(0xFFFEF2F2);
  static const info           = Color(0xFF3B82F6);
  static const infoLight      = Color(0xFFEFF6FF);

  // ── Neutral scale ─────────────────────────────────────────────────────────
  static const slate50        = Color(0xFFF8FAFC);
  static const slate100       = Color(0xFFF1F5F9);
  static const slate200       = Color(0xFFE2E8F0);
  static const slate300       = Color(0xFFCBD5E1);
  static const slate400       = Color(0xFF94A3B8);
  static const slate500       = Color(0xFF64748B);
  static const slate600       = Color(0xFF475569);
  static const slate700       = Color(0xFF334155);
  static const slate800       = Color(0xFF1E293B);
  static const slate900       = Color(0xFF0F172A);

  // ── Legacy aliases so existing screens compile unchanged ──────────────────
  static const doctorPrimary  = primary;
  static const doctorAccent   = accent;
  static const doctorSurface  = background;
  static const doctorCard     = surface;
  static const doctorBorder   = border;
  static const patientPrimary = primary;
  static const patientSecondary = Color(0xFF0891B2);
  static const patientSurface = background;
  static const patientCard    = surface;
  static const patientBorder  = border;

  // ── Dark surfaces (video call, AI chat) ───────────────────────────────────
  static const darkBg         = Color(0xFF0F0B16);
  static const darkCard       = Color(0xFF1E1829);
  static const darkBorder     = Color(0xFF2C2438);
}
