import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:teamflow_mobile/features/teams/presentation/providers/team_details_providers.dart';
import 'package:teamflow_mobile/features/sprints/presentation/providers/sprints_providers.dart';
import 'package:teamflow_mobile/features/sprints/data/models/sprint_model.dart';

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
    final selectedPriority = useState<String>('MEDIUM');
    final selectedSprintId = useState<String?>(null);
    final selectedStoryPoints = useState<int?>(null);
    final isRecurring = useState<bool>(false);
    final selectedRecurrence = useState<String>('DAILY');

    final sprintsAsync = ref.watch(sprintsListProvider(projectId));

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
            priority: selectedPriority.value,
            sprintId: selectedSprintId.value,
            storyPoints: selectedStoryPoints.value,
            isRecurring: isRecurring.value,
            recurrence: isRecurring.value ? selectedRecurrence.value : null,
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
            value: teamDetailState.members.any((m) => m.userId == selectedAssigneeId.value)
                ? selectedAssigneeId.value
                : null,
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

          const SizedBox(height: 16),

          const AppSheetLabel('Priority'),

          DropdownButtonFormField<String>(
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
            value: selectedPriority.value,
            items: const [
              DropdownMenuItem<String>(
                value: 'LOW',
                child: Text('Low', style: TextStyle(color: AppColors.textPrimary)),
              ),
              DropdownMenuItem<String>(
                value: 'MEDIUM',
                child: Text('Medium', style: TextStyle(color: AppColors.textPrimary)),
              ),
              DropdownMenuItem<String>(
                value: 'HIGH',
                child: Text('High', style: TextStyle(color: AppColors.textPrimary)),
              ),
              DropdownMenuItem<String>(
                value: 'URGENT',
                child: Text('Urgent', style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                selectedPriority.value = val;
              }
            },
          ),

          const SizedBox(height: 16),

          const AppSheetLabel('Sprint (Optional)'),

          sprintsAsync.when(
            data: (sprints) {
              final activeAndPlanned = sprints
                  .where((s) => s.status == SprintStatus.PLANNED || s.status == SprintStatus.ACTIVE)
                  .toList();
              
              return DropdownButtonFormField<String?>(
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
                value: activeAndPlanned.any((s) => s.id == selectedSprintId.value)
                    ? selectedSprintId.value
                    : null,
                hint: const Text('No Sprint', style: TextStyle(color: AppColors.textSecondary)),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No Sprint', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  ...activeAndPlanned.map((s) {
                    return DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary)),
                    );
                  }),
                ],
                onChanged: (val) {
                  selectedSprintId.value = val;
                },
              );
            },
            loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (err, stack) => const Text('Error loading sprints', style: TextStyle(color: AppColors.danger)),
          ),

          const SizedBox(height: 16),

          const AppSheetLabel('Story Points'),

          DropdownButtonFormField<int?>(
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
            value: selectedStoryPoints.value,
            hint: const Text('None', style: TextStyle(color: AppColors.textSecondary)),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('None', style: TextStyle(color: AppColors.textPrimary)),
              ),
              ...[1, 2, 3, 5, 8, 13, 21].map((pts) {
                return DropdownMenuItem<int?>(
                  value: pts,
                  child: Text('$pts Points', style: const TextStyle(color: AppColors.textPrimary)),
                );
              }),
            ],
            onChanged: (val) {
              selectedStoryPoints.value = val;
            },
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Is Recurring Task',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Switch(
                value: isRecurring.value,
                onChanged: (val) => isRecurring.value = val,
                activeColor: AppColors.primary,
              ),
            ],
          ),

          if (isRecurring.value) ...[
            const SizedBox(height: 8),
            const AppSheetLabel('Recurrence Pattern'),
            DropdownButtonFormField<String>(
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
              value: selectedRecurrence.value,
              items: const [
                DropdownMenuItem<String>(
                  value: 'DAILY',
                  child: Text('Daily', style: TextStyle(color: AppColors.textPrimary)),
                ),
                DropdownMenuItem<String>(
                  value: 'WEEKLY',
                  child: Text('Weekly', style: TextStyle(color: AppColors.textPrimary)),
                ),
                DropdownMenuItem<String>(
                  value: 'MONTHLY',
                  child: Text('Monthly', style: TextStyle(color: AppColors.textPrimary)),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  selectedRecurrence.value = val;
                }
              },
            ),
          ],

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
