import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../data/models/sprint_model.dart';
import '../providers/sprint_controller.dart';
import '../providers/sprints_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/domain/entitties/task_entity.dart';

class SprintPlanningView extends HookConsumerWidget {
  final String projectId;
  final String teamId;
  final bool isViewer;

  const SprintPlanningView({
    super.key,
    required this.projectId,
    required this.teamId,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sprintsAsync = ref.watch(sprintsListProvider(projectId));
    final tasksState = ref.watch(taskStateNotifierProvider);

    final selectedSprintId = useState<String?>(null);
    final activePlanningTab = useState(0); // 0 = Backlog Tasks, 1 = Sprint Tasks

    return sprintsAsync.when(
      data: (sprints) {
        final planableSprints = sprints.where((s) => s.status == SprintStatus.PLANNED || s.status == SprintStatus.ACTIVE).toList();

        if (planableSprints.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Create or activate a sprint first to start planning.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        // Default selection if not selected yet
        if (selectedSprintId.value == null && planableSprints.isNotEmpty) {
          selectedSprintId.value = planableSprints.first.id;
        }

        final selectedSprint = planableSprints.firstWhere(
          (s) => s.id == selectedSprintId.value,
          orElse: () => planableSprints.first,
        );

        // All tasks belonging to the current project
        final projectTasks = tasksState.tasks;

        // Backlog tasks
        final backlogTasks = projectTasks.where((t) => t.sprintId == null).toList();

        // Tasks in the selected sprint
        final sprintTasks = projectTasks.where((t) => t.sprintId == selectedSprint.id).toList();

        // Sum points
        final totalPoints = sprintTasks.fold<int>(0, (sum, t) => sum + (t.storyPoints ?? 0));
        const maxCapacity = 20; // Example capacity limit
        final overCapacity = totalPoints > maxCapacity;

        // Priority distribution
        final lowCount = sprintTasks.where((t) => t.priority?.toUpperCase() == 'LOW').length;
        final mediumCount = sprintTasks.where((t) => t.priority?.toUpperCase() == 'MEDIUM' || t.priority == null).length;
        final highCount = sprintTasks.where((t) => t.priority?.toUpperCase() == 'HIGH').length;
        final urgentCount = sprintTasks.where((t) => t.priority?.toUpperCase() == 'URGENT').length;

        void handleAssign(TaskEntity task) async {
          if (isViewer) return;
          await ref.read(sprintControllerProvider.notifier).assignTasks(
            selectedSprint.id,
            projectId,
            [task.id],
          );
          ref.invalidate(taskStateNotifierProvider);
        }

        void handleRemove(TaskEntity task) async {
          if (isViewer) return;
          await ref.read(sprintControllerProvider.notifier).removeTask(
            selectedSprint.id,
            projectId,
            task.id,
          );
          ref.invalidate(taskStateNotifierProvider);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sprint Dropdown Selector
              Row(
                children: [
                  Text(
                    'Target Sprint:',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSprint.id,
                          onChanged: (val) => selectedSprintId.value = val,
                          dropdownColor: AppColors.surface,
                          items: planableSprints.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text(
                                s.name,
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Capacity Warning Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: overCapacity ? AppColors.danger.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: overCapacity ? AppColors.danger : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sprint Capacity Planned:',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                        Text(
                          '$totalPoints / $maxCapacity pts',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: overCapacity ? AppColors.danger : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (totalPoints / maxCapacity).clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(overCapacity ? AppColors.danger : AppColors.primary),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    if (overCapacity) ...[
                      const SizedBox(height: 8),
                      Text(
                        '⚠️ Warning: Selected sprint is over capacity! Review your assignments.',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Priority distribution grouping row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriorityStat('Low', lowCount),
                  _buildPriorityStat('Med', mediumCount),
                  _buildPriorityStat('High', highCount),
                  _buildPriorityStat('Urgent', urgentCount),
                ],
              ),
              const SizedBox(height: 16),

              // Tabs
              Row(
                children: [
                  _buildPlanningTab('Backlog (${backlogTasks.length})', 0, activePlanningTab),
                  const SizedBox(width: 16),
                  _buildPlanningTab('Sprint Tasks (${sprintTasks.length})', 1, activePlanningTab),
                ],
              ),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),

              // Tab View Lists
              Expanded(
                child: activePlanningTab.value == 0
                    ? _buildPlanningList(backlogTasks, 'Backlog', handleAssign, isAdd: true)
                    : _buildPlanningList(sprintTasks, 'Sprint', handleRemove, isAdd: false),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: TeamFlowLoader(size: 40)),
      error: (e, __) => Center(child: Text('Error loading planning view: $e')),
    );
  }

  Widget _buildPriorityStat(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: $count',
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildPlanningTab(String label, int index, ValueNotifier<int> activeTab) {
    final isSelected = activeTab.value == index;
    return GestureDetector(
      onTap: () => activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanningList(
    List<TaskEntity> tasks,
    String name,
    void Function(TaskEntity) onAction, {
    required bool isAdd,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks in $name',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, idx) {
        final task = tasks[idx];
        final pts = task.storyPoints ?? 0;

        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            dense: true,
            title: Text(
              task.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              'Points: ${pts > 0 ? pts : "None"} • Priority: ${task.priority ?? "Medium"}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            ),
            trailing: isViewer
                ? null
                : ElevatedButton(
                    onPressed: () => onAction(task),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAdd ? AppColors.primary : AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(
                      isAdd ? 'Add' : 'Remove',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
