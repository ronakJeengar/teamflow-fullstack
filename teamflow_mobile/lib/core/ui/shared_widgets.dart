import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'app_tokens.dart';

// ─── Brand mark ──────────────────────────────────────────────────────────────

class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTokens.brand,
            borderRadius: BorderRadius.circular(AppTokens.r8),
          ),
          child: Icon(Icons.hub_rounded, color: Colors.white, size: 20),
        ),
        SizedBox(width: AppTokens.s10),
        Text(
          'teamflow',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTokens.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class AppFieldLabel extends StatelessWidget {
  final String label;

  AppFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTokens.textPrimary,
        letterSpacing: -0.1,
      ),
    );
  }
}

// ─── Input field ─────────────────────────────────────────────────────────────

class AppInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffix;
  final TextCapitalization textCapitalization;

  const AppInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        border: Border.all(
          color: _focused ? AppTokens.brand : AppTokens.border,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        enabled: widget.enabled,
        textCapitalization: widget.textCapitalization,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppTokens.textPrimary,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTokens.textHint,
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 18,
            color: _focused ? AppTokens.brand : AppTokens.textHint,
          ),
          suffixIcon: widget.suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppTokens.s16,
            horizontal: AppTokens.s4,
          ),
          errorStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTokens.danger,
          ),
        ),
      ),
    );
  }
}

// ─── Visibility toggle ────────────────────────────────────────────────────────

class AppVisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;

  const AppVisibilityToggle({
    super.key,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.only(right: AppTokens.s4),
        child: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
          color: AppTokens.textSecondary,
        ),
      ),
    );
  }
}

// ─── Primary button ───────────────────────────────────────────────────────────

class AppPrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          decoration: BoxDecoration(
            color: widget.onPressed != null && !widget.isLoading
                ? AppTokens.brand
                : AppTokens.surfaceAlt,
            borderRadius: BorderRadius.circular(AppTokens.r8),
            border: Border.all(color: AppTokens.border, width: 1),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: widget.onPressed != null
                    ? Colors.white
                    : AppTokens.textHint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class AppErrorBanner extends StatelessWidget {
  final String message;

  const AppErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      decoration: BoxDecoration(
        color: AppTokens.dangerSurface,
        borderRadius: BorderRadius.circular(AppTokens.r12),
        border: Border.all(color: AppTokens.dangerBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppTokens.danger,
          ),
          SizedBox(width: AppTokens.s10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTokens.danger,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Or divider ───────────────────────────────────────────────────────────────

class AppOrDivider extends StatelessWidget {
  AppOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTokens.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
          child: Text(
            'or',
            style: AppTokens.labelSm.copyWith(
              color: AppTokens.textHint,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTokens.border)),
      ],
    );
  }
}

// ─── Auth nav prompt ──────────────────────────────────────────────────────────

class AppAuthNavPrompt extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  AppAuthNavPrompt({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTokens.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: AppTokens.s6),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTokens.brand,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Icon button ──────────────────────────────────────────────────────────────

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _pressed ? AppTokens.surfaceDeep : AppTokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTokens.r12),
          border: Border.all(color: AppTokens.border),
        ),
        child: Icon(
          widget.icon,
          size: 18,
          color: widget.color ?? AppTokens.textSecondary,
        ),
      ),
    );
  }
}

// ─── Action button (small icon-only, edit/delete) ────────────────────────────

class AppActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AppActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<AppActionButton> createState() => _AppActionButtonState();
}

class _AppActionButtonState extends State<AppActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.14)
              : widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTokens.r10),
        ),
        child: Icon(widget.icon, size: 16, color: widget.color),
      ),
    );
  }
}

// ─── Avatar ──────────────────────────────────────────────────────────────────

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;

  const AppAvatar({super.key, required this.name, required this.size});

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  Color _colorFromName(String name) {
    final colors = [
      AppColors.primary,
      AppColors.primary,
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      AppColors.primary,
    ];
    int hash = 0;
    for (final c in name.codeUnits) {
      hash = (hash * 31 + c) & 0xFFFFFFFF;
    }
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bg = _colorFromName(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.inter(
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Role badge ───────────────────────────────────────────────────────────────

class AppRoleBadge extends StatelessWidget {
  final String role;

  const AppRoleBadge({super.key, required this.role});

  ({String label, Color color, Color surface, Color border}) get _style =>
      switch (role.toUpperCase()) {
        'OWNER' => (
        label: 'Owner',
        color: AppTokens.brand,
        surface: AppTokens.brandSurface,
        border: AppTokens.brandBorder,
        ),
        'ADMIN' => (
        label: 'Admin',
        color: AppTokens.warning,
        surface: AppTokens.warningSurface,
        border: AppTokens.warningBorder,
        ),
        'MEMBER' => (
        label: 'Member',
        color: AppTokens.success,
        surface: AppTokens.successSurface,
        border: AppTokens.successBorder,
        ),
        _ => (
        label: 'Viewer',
        color: AppTokens.textSecondary,
        surface: AppTokens.surfaceAlt,
        border: AppTokens.border,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        border: Border.all(color: s.border, width: 1),
      ),
      child: Text(
        s.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: s.color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─── Loading view ─────────────────────────────────────────────────────────────

class AppLoadingView extends StatelessWidget {
  final String message;

  const AppLoadingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTokens.brand),
            ),
          ),
          SizedBox(height: AppTokens.s16),
          Text(message, style: AppTokens.bodySm),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTokens.dangerSurface,
                borderRadius: BorderRadius.circular(AppTokens.r8),
                border: Border.all(color: AppTokens.dangerBorder),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 26,
                color: AppTokens.danger,
              ),
            ),
            SizedBox(height: AppTokens.s20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTokens.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: AppTokens.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.bodySm.copyWith(height: 1.6),
            ),
            SizedBox(height: AppTokens.s24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s20,
                  vertical: AppTokens.s12,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.brand,
                  borderRadius: BorderRadius.circular(AppTokens.r8),
                ),
                child: Text(
                  'Try again',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

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
    this.iconColor = AppTokens.brandMuted,
    this.iconSurface = Colors.transparent,
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
        padding: const EdgeInsets.all(AppTokens.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTokens.border,
                  width: 1,
                ),
                color: Colors.transparent,
              ),
              child: Icon(icon, size: 24, color: AppTokens.brandMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionIcon != null) ...[
                      Icon(actionIcon, size: 15, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      actionLabel!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Snackbar ────────────────────────────────────────────────────────────────

void showAppSnackBar(
    BuildContext context,
    String message, {
      Color? backgroundColor,
    }) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: backgroundColor ?? AppTokens.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.r12),
      ),
      margin: const EdgeInsets.all(AppTokens.s16),
      duration: const Duration(seconds: 3),
    ),
  );
}