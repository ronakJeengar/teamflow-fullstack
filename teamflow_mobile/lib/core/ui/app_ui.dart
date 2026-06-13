/// app_ui.dart
///
/// Single import for the TeamFlow shared design system.
///
/// Usage:
///   import 'package:teamflow_mobile/core/ui/app_ui.dart';
///
library app_ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 · COLOR SYSTEM
// ─────────────────────────────────────────────────────────────────────────────
//
// Dual-mode tokens:  light surface / dark surface.
// Every raw hex is defined once as a constant; semantic names reference them.
//
// Naming convention:
//   [role]            – primary semantic use (bg, surface, border …)
//   [role]Alt         – secondary variant (surfaceAlt)
//   [hue]             – brand colour family (brand, success, warning, danger)
//   [hue]Surface      – tinted wash (1–5% opacity equivalent, hardcoded)
//   [hue]Muted        – stronger tinted wash (~10–15%)
//   text[Weight]      – typography hierarchy (textPrimary, textSecondary, textHint)
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bg          = Color(0xFFF8FAFC);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceAlt  = Color(0xFFF1F5F9);

  // "card" kept for compatibility with existing widget references
  static const Color card        = Color(0xFFFFFFFF);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border      = Color(0xFFE8EDF3);
  static const Color borderMid   = Color(0xFFCBD5E1);

  // ── Brand (indigo) ────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF6366F1);
  static const Color primaryLight   = Color(0xFFEEF2FF); // compat alias
  static const Color primaryDark    = Color(0xFF4F46E5);
  static const Color brandSurface   = Color(0xFFEEF2FF);
  static const Color brandMuted     = Color(0xFFE0E7FF);

  // ── Success (emerald) ─────────────────────────────────────────────────────
  static const Color success        = Color(0xFF059669);
  static const Color successLight   = Color(0xFFF0FDF4); // compat alias
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color successMuted   = Color(0xFFD1FAE5);

  // ── Warning (amber) ───────────────────────────────────────────────────────
  static const Color warning        = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningMuted   = Color(0xFFFEF3C7);

  // ── Danger (red) ──────────────────────────────────────────────────────────
  static const Color danger         = Color(0xFFDC2626);
  static const Color dangerLight    = Color(0xFFFEF2F2); // compat alias
  static const Color dangerSurface  = Color(0xFFFEF2F2);
  static const Color dangerMuted    = Color(0xFFFECACA);

  // ── Purple (accent) ───────────────────────────────────────────────────────
  static const Color purple      = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleText  = Color(0xFF6D28D9);

  // ── Typography ────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint      = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFFCBD5E1);

  /// Kept for backward-compat (was Color(0xFF1C1C28))
  static const Color dark = textPrimary;

  // ── Role badge colours ────────────────────────────────────────────────────
  static const Color adminBg   = Color(0xFFFFFBEB);
  static const Color adminText = Color(0xFFD97706);

  // ── Legacy control colours ────────────────────────────────────────────────
  /// Use [surfaceAlt] for new code.
  static const Color circleBtnBg   = Color(0xFFF1F5F9);
  static const Color circleBtnIcon = Color(0xFF64748B);
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 · SPACING SCALE
// ─────────────────────────────────────────────────────────────────────────────
//
// 4-point grid. All values are multiples of 4.
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppSpacing {
  static const double xs   =  4.0;
  static const double sm   =  8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 · RADIUS SCALE
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppRadius {
  static const double xs  =  6.0;
  static const double sm  =  8.0;
  static const double md  = 12.0;
  static const double lg  = 14.0;
  static const double xl  = 16.0;
  static const double xxl = 20.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 · TYPOGRAPHY SCALE
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppText {
  static const TextStyle displayLg = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.05,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMd = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
    fontFamily: 'monospace',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 · ELEVATION / SHADOW SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppShadow {
  /// Subtle shadow for cards and list rows.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium shadow for floating elements (FAB, modals).
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  /// Brand-tinted shadow for primary CTAs.
  static List<BoxShadow> brand({double opacity = 0.28}) => [
    BoxShadow(
      color: AppColors.primary.withOpacity(opacity),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Success-tinted shadow for accept/confirm CTAs.
  static List<BoxShadow> success({double opacity = 0.22}) => [
    BoxShadow(
      color: AppColors.success.withOpacity(opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 · COMPONENT LIBRARY
// ─────────────────────────────────────────────────────────────────────────────

// ─── AppIconButton ────────────────────────────────────────────────────────────
///
/// 40×40 rounded-square tap target.
/// Replaces the circle variant — squares have better alignment in grids and rows.
/// The [variant] controls fill style.
///
/// Variants:
///   ghost   – surfaceAlt background, secondary icon colour      (default)
///   filled  – brand background, white icon
///   danger  – dangerSurface background, danger icon colour

enum AppIconButtonVariant { ghost, filled, danger }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AppIconButtonVariant variant;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = AppIconButtonVariant.ghost,
    this.size = 40,
    this.tooltip,
  });

  Color get _bg => switch (variant) {
    AppIconButtonVariant.filled => AppColors.primary,
    AppIconButtonVariant.danger => AppColors.dangerSurface,
    AppIconButtonVariant.ghost  => AppColors.surfaceAlt,
  };

  Color get _fg => switch (variant) {
    AppIconButtonVariant.filled => Colors.white,
    AppIconButtonVariant.danger => AppColors.danger,
    AppIconButtonVariant.ghost  => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(icon, size: size * 0.44, color: _fg),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

/// Backward-compat shim so existing callsites compile unchanged.
typedef AppCircleButton = AppIconButton;

// ─── AppActionButton ─────────────────────────────────────────────────────────
///
/// 32×32 icon button with tinted background, used for inline edit/delete actions.

// ─── AppPrimaryButton ─────────────────────────────────────────────────────────
///
/// Full-width primary CTA. Supports [isLoading] and optional [variant] for
/// destructive actions.

enum AppPrimaryButtonVariant { brand, success, danger }

class AppPrimaryButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final AppPrimaryButtonVariant variant;

  const AppPrimaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.variant = AppPrimaryButtonVariant.brand,
    // Legacy positional compat – ignored, use [variant]
    Color color = AppColors.primary,
  });

  Color get _bg => switch (variant) {
    AppPrimaryButtonVariant.success => AppColors.success,
    AppPrimaryButtonVariant.danger  => AppColors.danger,
    AppPrimaryButtonVariant.brand   => AppColors.primary,
  };

  List<BoxShadow> get _shadow => switch (variant) {
    AppPrimaryButtonVariant.success => AppShadow.success(),
    AppPrimaryButtonVariant.danger  => [],
    AppPrimaryButtonVariant.brand   => AppShadow.brand(),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || onTap == null) ? null : () {
        HapticFeedback.lightImpact();
        onTap!();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: (isLoading || onTap == null)
              ? _bg.withOpacity(0.65)
              : _bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: (isLoading || onTap == null) ? [] : _shadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AppAvatar ────────────────────────────────────────────────────────────────
///
/// Rounded-square initials avatar. Colour is deterministically derived from
/// [name] across a 7-colour palette so the same name always maps to the same
/// colour. Background is always a light tint; foreground is the saturated hue.

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;

  const AppAvatar({super.key, required this.name, required this.size});

  static const _palette = <(Color, Color)>[
    (Color(0xFFEDE9FE), Color(0xFF7C3AED)), // purple
    (Color(0xFFD1FAE5), Color(0xFF059669)), // green
    (Color(0xFFFEF3C7), Color(0xFFD97706)), // amber
    (Color(0xFFDBEAFE), Color(0xFF2563EB)), // blue
    (Color(0xFFFCE7F3), Color(0xFFDB2777)), // pink
    (Color(0xFFFFEDD5), Color(0xFFEA580C)), // orange
    (Color(0xFFECFDF5), Color(0xFF059669)), // teal
  ];

  (Color, Color) get _colors {
    if (name.isEmpty) return _palette[0];
    final hash = name.codeUnits.fold<int>(0, (s, c) => s + c);
    return _palette[hash % _palette.length];
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty
        ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: fg,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

// ─── AppRoleBadge ─────────────────────────────────────────────────────────────
///
/// Semantic role pill. Three roles supported: owner, admin, and default member.
/// Colours derived from the design token set above.

class AppRoleBadge extends StatelessWidget {
  final String role;

  const AppRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final lower = role.toLowerCase();
    final (bg, fg, label) = switch (lower) {
      'owner' => (AppColors.brandSurface, AppColors.primary, 'Owner'),
      'admin' => (AppColors.warningSurface, AppColors.warning, 'Admin'),
      _       => (AppColors.surfaceAlt, AppColors.textSecondary, 'Member'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: fg,
        ),
      ),
    );
  }
}

// ─── AppStatChip ──────────────────────────────────────────────────────────────
///
/// Coloured metric tile. Each chip takes an explicit [color] and [surface] so
/// teams/projects/tasks can use distinct semantic colours (indigo/green/amber).
/// Includes an [icon] for at-a-glance comprehension.

class AppStatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color surface;

  const AppStatChip({
    super.key,
    required this.value,
    required this.label,
    this.icon = Icons.bar_chart_rounded,
    this.color = AppColors.primary,
    this.surface = AppColors.brandSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.6,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


///
/// Centred spinner + optional message.

// ─── AppSheetShell ────────────────────────────────────────────────────────────
///
/// Bottom-sheet container with drag handle and title.
/// Keyboard-aware via [viewInsets].

class AppSheetShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const AppSheetShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxxl + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppText.titleLg),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppText.bodySm),
          ],
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

// ─── AppSheetLabel ────────────────────────────────────────────────────────────
///
/// Field label for use inside bottom sheets.

class AppSheetLabel extends StatelessWidget {
  final String text;

  const AppSheetLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppText.labelMd),
    );
  }
}

// ─── AppSheetInput ────────────────────────────────────────────────────────────
///
/// Styled text input for bottom sheets. Focus-aware border animation.

class AppSheetInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? errorText;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  const AppSheetInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.autofocus = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  State<AppSheetInput> createState() => _AppSheetInputState();
}

class _AppSheetInputState extends State<AppSheetInput> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(
            () => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasError
              ? AppColors.danger
              : _focused
              ? AppColors.primary
              : AppColors.border,
          width: _focused || hasError ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 0,
            spreadRadius: 3,
          )
        ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        autofocus: widget.autofocus,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        maxLines: widget.maxLines,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          hintStyle: AppText.bodySm.copyWith(fontSize: 14),
          errorStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.danger,
            height: 1.4,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

// ─── AppSheetActions ──────────────────────────────────────────────────────────
///
/// Cancel + Confirm button row for bottom sheets.

class AppSheetActions extends StatelessWidget {
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;
  final bool isLoading;
  // Legacy compat
  final Color confirmColor;

  const AppSheetActions({
    super.key,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.isDestructive = false,
    this.isLoading = false,
    this.confirmColor = AppColors.primary,
  });

  Color get _confirmBg =>
      isDestructive ? AppColors.danger : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cancel
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : onCancel,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Confirm
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : onConfirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 48,
              decoration: BoxDecoration(
                color:
                isLoading ? _confirmBg.withOpacity(0.65) : _confirmBg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: isLoading
                    ? []
                    : isDestructive
                    ? []
                    : AppShadow.brand(opacity: 0.2),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white),
                  ),
                )
                    : Text(
                  confirmLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── AppSearchBar ─────────────────────────────────────────────────────────────
///
/// Focus-aware search field with animated border and clear button.

class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<bool>? onFocusChanged;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search…',
    this.onFocusChanged,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _focus = FocusNode();
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _active = _focus.hasFocus);
      widget.onFocusChanged?.call(_focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _active
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.lg),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: _active ? AppColors.primary : AppColors.textHint,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppText.bodySm.copyWith(fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (_, val, __) {
              if (val.text.isEmpty) return const SizedBox(width: AppSpacing.lg);
              return GestureDetector(
                onTap: widget.controller.clear,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.textHint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── AppMetaChip ──────────────────────────────────────────────────────────────
///
/// Inline icon + text label for secondary metadata (member count, task count, date).

class AppMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const AppMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textHint;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: c),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c == AppColors.textHint ? AppColors.textSecondary : c,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ─── AppDateChip ──────────────────────────────────────────────────────────────
///
/// Parses an ISO 8601 string and renders a formatted date chip (e.g. "Jun 3").

class AppDateChip extends StatelessWidget {
  final String? iso;

  const AppDateChip({super.key, this.iso});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _label {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso!);
      return '${_months[d.month - 1]} ${d.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: AppText.mono),
    );
  }
}

// ─── AppStatusAccentBar ───────────────────────────────────────────────────────
///
/// 3px coloured top bar rendered inside a ClipRRect card.
/// Encodes status without a text badge — used on task, project and invitation cards.

class AppStatusAccentBar extends StatelessWidget {
  final Color color;

  const AppStatusAccentBar({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: 3, color: color);
  }
}

// ─── AppEmptyState ────────────────────────────────────────────────────────────
///
/// Reusable empty state with icon, title, subtitle and optional CTA.

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconSurface = AppColors.brandSurface,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconSurface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppText.bodySm.copyWith(height: 1.6),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actionIcon != null) ...[
                        Icon(actionIcon, size: 16, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}