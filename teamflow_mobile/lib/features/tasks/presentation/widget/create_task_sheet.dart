import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/team_details_providers.dart';

import '../../../../core/ui/app_ui.dart';

class CreateTaskSheet extends HookConsumerWidget {
  final String projectId;
  final String teamId;

  const CreateTaskSheet({super.key, required this.projectId, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleCtrl = useTextEditingController();
    final titleError = useState<String?>(null);
    final selectedAssigneeId = useState<String?>(null);

    final teamDetailState = ref.watch(teamDetailStateNotifierProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(teamDetailStateNotifierProvider.notifier).loadTeamDetail(teamId);
      });
      return null;
    }, [teamId]);

    final controllerState = ref.watch(createTaskControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final title = titleCtrl.text.trim();

      if (title.isEmpty) {
        titleError.value = 'Task title is required';
        return;
      }

      titleError.value = null;

      await ref
          .read(createTaskControllerProvider.notifier)
          .createTask(
            projectId: projectId,
            title: title,
            assigneeId: selectedAssigneeId.value,
          );

      if (ref.read(createTaskControllerProvider) is! AsyncError) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return AppSheetShell(
      title: 'New Task',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetLabel('Task Title'),

          AppSheetInput(
            controller: titleCtrl,
            hint: 'e.g. Mobile Redesign',
            errorText: titleError.value,
            autofocus: true,
            onChanged: (_) => titleError.value = null,
            onSubmitted: (_) => submit(),
          ),

          const SizedBox(height: 16),

          const AppSheetLabel('Assignee'),

          DropdownButtonFormField<String?>(
            dropdownColor: AppColors.surface,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            value: selectedAssigneeId.value,
            hint: const Text('Unassigned', style: TextStyle(color: AppColors.textSecondary)),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Unassigned', style: TextStyle(color: AppColors.textPrimary)),
              ),
              ...teamDetailState.members.map((m) {
                final name = m.user?.name ?? 'Unknown User';
                return DropdownMenuItem<String?>(
                  value: m.userId,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppAvatar(name: name, size: 20),
                      const SizedBox(width: 8),
                      Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (val) {
              selectedAssigneeId.value = val;
            },
          ),

          const SizedBox(height: 24),

          AppSheetActions(
            confirmLabel: 'Create',
            isLoading: isLoading,
            onCancel: isLoading ? null : () => Navigator.of(context).pop(),
            onConfirm: submit,
          ),
        ],
      ),
    );
  }
}
