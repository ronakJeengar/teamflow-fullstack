import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/model_scaffold.dart';
import '../providers/teams_providers.dart';

class EditTeamModal extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditTeamModal({
    super.key,
    required this.nameController,
    required this.descController,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
    ref.watch(updateTeamControllerProvider) is AsyncLoading;

    return ModalScaffold(
      onDismiss: isLoading ? null : onCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Edit Team', style: AppTextStyles.heading2),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Name field ─────────────────────────────────────────────────
          const ModalLabel('Team Name'),
          TextField(
            controller: nameController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Team name',
              prefixIcon: Icon(
                Icons.group_outlined,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Description field ──────────────────────────────────────────
          const ModalLabel('Description'),
          TextField(
            controller: descController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'What does this team work on?',
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Actions ────────────────────────────────────────────────────
          ModalActions(
            onCancel: onCancel,
            onConfirm: onSave,
            confirmLabel: 'Save Changes',
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}