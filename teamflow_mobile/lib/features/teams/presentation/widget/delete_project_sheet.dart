import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../../../projects/domain/entitties/project_entity.dart';
import '../providers/team_details_providers.dart';

class DeleteProjectSheet extends HookConsumerWidget {
  final String teamId;
  final ProjectEntity project;

  const DeleteProjectSheet({
    super.key,
    required this.project,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(deleteProjectControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      await ref
          .read(deleteProjectControllerProvider.notifier)
          .deleteProject(teamId: teamId, projectId: project.id);

      if (ref.read(deleteProjectControllerProvider) is! AsyncError) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return AppSheetShell(
      title: 'Delete project',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Are you sure you want to delete "${project.name}"? '
                    'This cannot be undone.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          AppSheetActions(
            confirmLabel: 'Delete project',
            isLoading: isLoading,
            onCancel: isLoading ? null : () => Navigator.of(context).pop(),
            onConfirm: submit,
            confirmColor: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
