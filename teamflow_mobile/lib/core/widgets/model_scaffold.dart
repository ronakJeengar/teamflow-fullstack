import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Shared full-screen backdrop + centred card for every modal.
/// Drop this as the last child in a [Stack] — it sizes to fill the Stack.
class ModalScaffold extends StatelessWidget {
  final Widget child;

  /// Optional: called when the backdrop is tapped (dismiss).
  final VoidCallback? onDismiss;

  const ModalScaffold({
    super.key,
    required this.child,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: ColoredBox(
        color: AppColors.background.withOpacity(0.45),
        child: Center(
          child: GestureDetector(
            // Prevent backdrop tap from propagating through the card
            onTap: () {},
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: AppColors.card,
                  borderRadius: AppRadius.xl,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets used by all modals ────────────────────────────────────

/// Modal section label (e.g. "Team Name")
class ModalLabel extends StatelessWidget {
  final String text;
  const ModalLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text.toUpperCase(), style: AppTextStyles.label),
  );
}

/// Standard modal action row: [cancel] [confirm]
class ModalActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String confirmLabel;
  final bool isLoading;
  final bool isDanger;

  const ModalActions({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.confirmLabel,
    this.isLoading = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: Text('Cancel'),
        ),
        SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          onPressed: isLoading ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppColors.danger : AppColors.primary,
          ),
          child: isLoading
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(confirmLabel),
        ),
      ],
    );
  }
}