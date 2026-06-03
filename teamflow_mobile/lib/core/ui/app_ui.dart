/// app_ui.dart
///
/// Single import for the shared design system used across TeamsPage,
/// TeamDetailPage, and any future feature screens.
///
/// Usage:
///   import 'package:teamflow_mobile/core/ui/app_ui.dart';
///
library app_ui;

import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────

abstract class AppColors {
  static const bg = Color(0xFFF0F0F5);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E8F0);

  static const primary = Color(0xFF5B5FCF);
  static const primaryLight = Color(0xFFEDEDF8);

  static const textPrimary = Color(0xFF1C1C28);
  static const textSecondary = Color(0xFF9090A8);
  static const textMuted = Color(0xFFC8C8D8);
  static const dark = Color(0xFF1C1C28);

  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEE2E2);

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFF0FDF4);

  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFEDE9FE);
  static const purpleText = Color(0xFF5B21B6);

  static const adminBg = Color(0xFFFEF9C3);
  static const adminText = Color(0xFF854D0E);

  // Circle-button background (unfilled state)
  static const circleBtnBg = Color(0xFFE4E4EC);
  static const circleBtnIcon = Color(0xFF3C3C52);
}

// ─── Spacing ──────────────────────────────────────────────────────────────────

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

// ─── AppCircleButton ──────────────────────────────────────────────────────────
///
/// Round 38×38 tap target. Pass [filled] = true for primary-coloured (add/CTA)
/// variant; default is the subtle grey variant used for back/more buttons.

class AppCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final double size;

  const AppCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.circleBtnBg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.47,
        color: filled ? Colors.white : AppColors.circleBtnIcon,
      ),
    ),
  );
}

// ─── AppActionButton ──────────────────────────────────────────────────────────
///
/// Small 28×28 icon button with a tinted background, used for edit / delete
/// actions inside list rows and cards.

class AppActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const AppActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  /// Convenience constructor for the standard Edit action.
  factory AppActionButton.edit({required VoidCallback onTap}) =>
      AppActionButton(
        icon: Icons.edit_outlined,
        tooltip: 'Edit',
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
        onTap: onTap,
      );

  /// Convenience constructor for the standard Delete action.
  factory AppActionButton.delete({required VoidCallback onTap}) =>
      AppActionButton(
        icon: Icons.delete_outline_rounded,
        tooltip: 'Delete',
        color: AppColors.danger,
        bgColor: AppColors.dangerLight,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    ),
  );
}

// ─── AppPrimaryButton ─────────────────────────────────────────────────────────
///
/// Full-width pill-shaped primary button used as a CTA (e.g. "New project",
/// "Invite member", "Create Your First Team").

class AppPrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const AppPrimaryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─── AppAvatar ────────────────────────────────────────────────────────────────
///
/// Rounded initials avatar. Background colour is deterministically derived from
/// [name] so the same person always gets the same colour.

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;

  const AppAvatar({super.key, required this.name, required this.size});

  static const _palette = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF0F766E),
    Color(0xFFB45309),
    Color(0xFF9D174D),
    Color(0xFF065F46),
  ];

  Color get _bg {
    final idx =
        name.codeUnits.fold<int>(0, (s, c) => s + c) % _palette.length;
    return _palette[idx];
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(size / 2.8),
    ),
    child: Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

// ─── AppRoleBadge ─────────────────────────────────────────────────────────────
///
/// Small pill showing a member's role (owner / admin / member).
/// Pass [role] as the raw string from your entity (case-insensitive).

class AppRoleBadge extends StatelessWidget {
  final String role;

  const AppRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final lower = role.toLowerCase();
    final (bg, fg) = switch (lower) {
      'owner' => (AppColors.purpleLight, AppColors.purpleText),
      'admin' => (AppColors.adminBg, AppColors.adminText),
      _ => (AppColors.primaryLight, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }
}

// ─── AppStatChip ──────────────────────────────────────────────────────────────
///
/// Card-style chip showing a large [value] above an uppercase [label].
/// Used in the hero/header of both TeamsPage and TeamDetailPage.

class AppStatChip extends StatelessWidget {
  final String value;
  final String label;

  const AppStatChip({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1.5),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

// ─── AppLoadingView ───────────────────────────────────────────────────────────
///
/// Centred spinner + optional message. Use while async data is loading.

class AppLoadingView extends StatelessWidget {
  final String? message;

  const AppLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    ),
  );
}

// ─── AppErrorView ─────────────────────────────────────────────────────────────
///
/// Centred error icon + title + [message] + optional [onRetry] button.

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 26,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            AppPrimaryButton(
              icon: Icons.refresh_rounded,
              label: 'Try Again',
              onTap: onRetry!,
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── AppSheetShell ────────────────────────────────────────────────────────────
///
/// White bottom-sheet container with a drag handle, title, and [child] content.
/// Automatically adjusts for the keyboard via [viewInsets].

class AppSheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  const AppSheetShell({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl,
          36 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.circleBtnBg,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

// ─── AppSheetLabel ────────────────────────────────────────────────────────────
///
/// Small uppercase field label used above inputs inside bottom sheets.

class AppSheetLabel extends StatelessWidget {
  final String text;

  const AppSheetLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ─── AppSheetInput ────────────────────────────────────────────────────────────
///
/// Styled text field for use inside bottom sheets.

class AppSheetInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const AppSheetInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F8FC),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

// ─── AppSheetActions ──────────────────────────────────────────────────────────
///
/// Cancel + Confirm row for bottom sheets. [confirmColor] defaults to primary;
/// pass [AppColors.danger] for destructive actions.

class AppSheetActions extends StatelessWidget {
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const AppSheetActions({
    super.key,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.confirmColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            side: const BorderSide(color: AppColors.border, width: 2),
            backgroundColor: const Color(0xFFF4F4F8),
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    ],
  );
}

// ─── AppSearchBar ─────────────────────────────────────────────────────────────
///
/// Card-surfaced search field with a clear button.

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search…',
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border, width: 1.5),
    ),
    child: TextField(
      controller: controller,
      style:
      const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, val, __) => val.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onPressed: controller.clear,
          )
              : const SizedBox.shrink(),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 13,
        ),
      ),
    ),
  );
}