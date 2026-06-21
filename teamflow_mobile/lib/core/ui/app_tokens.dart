import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTokens {
  // ── Colors ──────────────────────────────────────────────────────────
  static const Color brand        = Color(0xFF7C5CFF); // Primary
  static const Color brandLight   = Color(0xFF7C5CFF);
  static const Color brandSurface = Color(0xFF161A21); // Surface
  static const Color brandBorder  = Color(0xFF1F2430); // Border
  static const Color brandMuted   = Color(0xFF687280); // Muted

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brand, brand],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF22C55E);
  static const Color successSurface = Color(0x1A22C55E); // 10% opacity
  static const Color successBorder  = Color(0xFF1F2430);

  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0x1AF59E0B); // 10% opacity
  static const Color warningBorder  = Color(0xFF1F2430);

  static const Color danger        = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0x1AEF4444); // 10% opacity
  static const Color dangerBorder  = Color(0xFF1F2430);

  // ── Neutral canvas ──────────────────────────────────────────────────────────
  static const Color bg          = Color(0xFF0F1115);
  static const Color surface     = Color(0xFF161A21);
  static const Color surfaceAlt  = Color(0xFF161A21);
  static const Color surfaceDeep = Color(0xFF161A21);

  // ── Borders ─────────────────────────────────────────────────────────────────
  static const Color border    = Color(0xFF1F2430);
  static const Color borderAlt = Color(0xFF1F2430);
  static const Color borderMid = Color(0xFF1F2430);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE6EBEB);
  static const Color textSecondary = Color(0xFF8893A6);
  static const Color textHint      = Color(0xFF687280);

  // ── Spacing (strict 4px grid mappings) ──────────────────────────────────────
  static const double s2  = 4;
  static const double s4  = 4;
  static const double s6  = 8;
  static const double s8  = 8;
  static const double s10 = 12;
  static const double s12 = 12;
  static const double s14 = 16;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 32;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  // ── Radii (strict max 8px rounded corners) ──────────────────────────────────
  static const double r6  = 6;
  static const double r8  = 8;
  static const double r10 = 8;
  static const double r12 = 8;
  static const double r14 = 8;
  static const double r16 = 8;
  static const double r20 = 8;
  static const double r24 = 8;

  // ── Typography ──────────────────────────────────────────────────────────────
  static TextStyle get displayLg => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get titleMd => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelXs => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textHint,
  );
}