import 'package:flutter/material.dart';

abstract class AppTokens {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  static const double r8 = 8;
  static const double r10 = 10;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;

  static const Color bg = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF1F5F9);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderAlt = Color(0xFFE8EDF3);
  static const Color borderMid = Color(0xFFCBD5E1);
  static const Color borderFocus = Color(0xFF6366F1);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color brand = Color(0xFF6366F1);
  static const Color brandDark = Color(0xFF4F46E5);
  static const Color brandSurface = Color(0xFFEEF2FF);
  static const Color brandMuted = Color(0xFFE0E7FF);

  static const Color success = Color(0xFF059669);
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color successMuted = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningMuted = Color(0xFFFEF3C7);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSurface = Color(0xFFFEF2F2);
  static const Color dangerMuted = Color(0xFFFECACA);

  static const TextStyle displayLg = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.05,
    color: textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textSecondary,
  );

  static const TextStyle labelXs = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: textSecondary,
  );
}
