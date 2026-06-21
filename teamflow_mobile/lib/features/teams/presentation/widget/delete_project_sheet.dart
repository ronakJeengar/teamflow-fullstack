import 'package:google_fonts/google_fonts.dart';
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.danger.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Are you sure you want to delete "${project.name}"? '
                    'This cannot be undone.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

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
