import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/model_scaffold.dart';
import '../providers/teams_providers.dart';

class DeleteTeamModal extends ConsumerWidget {
  final String teamName;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const DeleteTeamModal({
    super.key,
    required this.teamName,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
    ref.watch(deleteTeamControllerProvider) is AsyncLoading;

    return ModalScaffold(
      onDismiss: isLoading ? null : onCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title with danger icon ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Delete Team?',
                style: AppTextStyles.heading2.copyWith(color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Warning body ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: AppRadius.md,
              border: Border.all(
                color: AppColors.danger.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.danger,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.danger.withOpacity(0.85),
                      ),
                      children: [
                        const TextSpan(text: 'This will permanently delete '),
                        TextSpan(
                          text: teamName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text:
                          ' and all its projects. This action cannot be undone.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Actions ────────────────────────────────────────────────────
          ModalActions(
            onCancel: onCancel,
            onConfirm: onConfirm,
            confirmLabel: 'Delete Team',
            isLoading: isLoading,
            isDanger: true,
          ),
        ],
      ),
    );
  }
}