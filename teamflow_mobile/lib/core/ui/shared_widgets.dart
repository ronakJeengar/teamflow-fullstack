import 'package:flutter/material.dart';
import 'app_tokens.dart';
import 'app_ui.dart';

class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTokens.brand,
            borderRadius: BorderRadius.circular(AppTokens.r14),
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: AppTokens.s10),
        const Text(
          'TeamFlow',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTokens.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class AppFieldLabel extends StatelessWidget {
  final String label;

  const AppFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTokens.textPrimary,
      ),
    );
  }
}

class AppInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final Widget? suffix;
  final TextCapitalization textCapitalization;

  const AppInputField({
    super.key,
    required this.controller,
    this.focusNode,
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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode?.hasFocus ?? false);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r14),
        border: Border.all(
          color: _hasError
              ? AppTokens.danger
              : _focused
              ? AppTokens.borderFocus
              : AppTokens.border,
          width: _focused || _hasError ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppTokens.brand.withOpacity(0.08),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppTokens.s14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              widget.icon,
              size: 18,
              color: _focused ? AppTokens.brand : AppTokens.textHint,
            ),
          ),
          const SizedBox(width: AppTokens.s10),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              onFieldSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTokens.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textHint,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppTokens.s16, horizontal: AppTokens.s8
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
              validator: (v) {
                final err = widget.validator?.call(v);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _hasError = err != null);
                });
                return err;
              },
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
          const SizedBox(width: AppTokens.s4),
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(AppTokens.s12),
        child: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: AppTokens.textHint,
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: isLoading ? AppTokens.brand.withOpacity(0.7) : AppTokens.brand,
          borderRadius: BorderRadius.circular(AppTokens.r14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTokens.brand.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class AppErrorBanner extends StatelessWidget {
  final String message;

  const AppErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s14,
        vertical: AppTokens.s12,
      ),
      decoration: BoxDecoration(
        color: AppTokens.dangerSurface,
        borderRadius: BorderRadius.circular(AppTokens.r12),
        border: Border.all(color: AppTokens.danger.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppTokens.danger,
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
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

class AppOrDivider extends StatelessWidget {
  const AppOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTokens.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
          child: const Text(
            'or',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTokens.textHint,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTokens.border, thickness: 1)),
      ],
    );
  }
}

class AppAuthNavPrompt extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  const AppAuthNavPrompt({
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTokens.textSecondary,
          ),
        ),
        const SizedBox(width: AppTokens.s6),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTokens.brand,
            ),
          ),
        ),
      ],
    );
  }
}

const _kAvatarPalette = [
  (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
  (Color(0xFFD1FAE5), Color(0xFF059669)),
  (Color(0xFFFEF3C7), Color(0xFFD97706)),
  (Color(0xFFDBEAFE), Color(0xFF2563EB)),
  (Color(0xFFFCE7F3), Color(0xFFDB2777)),
  (Color(0xFFFFEDD5), Color(0xFFEA580C)),
  (Color(0xFFF0FDF4), Color(0xFF16A34A)),
];

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;

  const AppAvatar({super.key, required this.name, this.size = 40});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty
        ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
        : '?';
  }

  (Color, Color) get _colors {
    if (name.isEmpty) return _kAvatarPalette[0];
    return _kAvatarPalette[name.codeUnitAt(0) % _kAvatarPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.34,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

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
    required this.iconColor,
    required this.iconSurface,
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
        padding: const EdgeInsets.all(AppTokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconSurface,
                borderRadius: BorderRadius.circular(AppTokens.r20),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: AppTokens.s20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTokens.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppTokens.s6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTokens.bodySm.copyWith(height: 1.6),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTokens.s24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s20,
                    vertical: AppTokens.s12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.brand,
                    borderRadius: BorderRadius.circular(AppTokens.r12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        actionIcon ?? Icons.add_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppTokens.s8),
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

class AppLoadingView extends StatelessWidget {
  final String? message;

  const AppLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTokens.brand,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTokens.s16),
            Text(message!, style: AppTokens.bodySm),
          ],
        ],
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTokens.dangerSurface,
                borderRadius: BorderRadius.circular(AppTokens.r20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: AppTokens.danger,
              ),
            ),
            const SizedBox(height: AppTokens.s20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppTokens.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.bodySm.copyWith(height: 1.6),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTokens.s24),
              AppPrimaryButton(
                label: 'Try again',
                isLoading: false,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTokens.r12),
        ),
        child: Icon(
          icon,
          size: size * 0.45,
          color: iconColor ?? AppTokens.textSecondary,
        ),
      ),
    );
  }
}

class AppActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTokens.r8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = AppTokens.danger,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(AppTokens.s16),
    ),
  );
}

class AppRoleBadge extends StatelessWidget {
  final String role;

  const AppRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final lower = role.toLowerCase();
    final (bg, fg, label) = switch (lower) {
      'owner' => (AppColors.brandSurface, AppColors.primary, 'Owner'),
      'admin' => (AppColors.warningSurface, AppColors.warning, 'Admin'),
      _ => (AppColors.surfaceAlt, AppColors.textSecondary, 'Member'),
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
