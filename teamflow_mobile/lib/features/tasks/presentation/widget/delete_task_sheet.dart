import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../../domain/entitties/task_entity.dart';
import '../providers/task_providers.dart';

class DeleteTaskSheet extends HookConsumerWidget {
  final String projectId;
  final TaskEntity task;

  const DeleteTaskSheet({
    super.key,
    required this.task,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(deleteTaskControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      await ref
          .read(deleteTaskControllerProvider.notifier)
          .deleteTask(projectId: projectId, taskId: task.id);

      if (ref.read(deleteTaskControllerProvider) is! AsyncError) {
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
                    'Are you sure you want to delete "${task.title}"? '
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
            confirmLabel: 'Delete Task',
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
