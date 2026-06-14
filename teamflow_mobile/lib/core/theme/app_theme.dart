import 'package:flutter/material.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const primary = Color(0xFF4F6EF7);
  static const primaryLight = Color(0xFFEEF2FF);
  static const primaryDark = Color(0xFF3451D1);

  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFF0FDF4);

  static const surface = Color(0xFFFAFAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E8EF);
  static const borderFocus = Color(0xFF4F6EF7);

  static const textPrimary = Color(0xFF0F0F1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFFADB5BD);

  static const memberChip = Color(0xFFEEF2FF);
  static const projectChip = Color(0xFFDBEAFE);
}

// ─── Text Styles ──────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  static const heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const heading3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );
}

// ─── Spacing ──────────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

// ─── Radii ────────────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(20));
  static const pill = BorderRadius.all(Radius.circular(50));
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      outline: AppColors.border,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTextStyles.bodyMd,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      space: 1,
      thickness: 1,
    ),
  );
}