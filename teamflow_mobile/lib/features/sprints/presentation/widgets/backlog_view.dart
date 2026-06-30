import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../../core/widgets/task_card.dart';
import '../../../tasks/domain/entitties/task_entity.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

class BacklogView extends HookConsumerWidget {
  final String projectId;
  final String teamId;
  final bool isViewer;

  const BacklogView({
    super.key,
    required this.projectId,
    required this.teamId,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskStateNotifierProvider);
    final activeColumn = useState(0); // 0 = Ungroomed, 1 = Ready, 2 = Blocked

    // Backlog tasks (no sprintId assigned)
    final backlogTasks = tasksState.tasks.where((t) => t.sprintId == null).toList();

    final ungroomedTasks = backlogTasks.where((t) => t.backlogStatus == 'UNGROOMED' || t.backlogStatus == null).toList();
    final readyTasks = backlogTasks.where((t) => t.backlogStatus == 'READY').toList();
    final blockedTasks = backlogTasks.where((t) => t.backlogStatus == 'BLOCKED').toList();

    final lists = [ungroomedTasks, readyTasks, blockedTasks];
    final titles = ['Ungroomed', 'Ready', 'Blocked'];
    final statuses = ['UNGROOMED', 'READY', 'BLOCKED'];
    final colors = [AppColors.textSecondary, AppColors.success, AppColors.danger];

    void handleDropped(TaskEntity task, int columnIndex) async {
      final targetStatus = statuses[columnIndex];
      if (task.backlogStatus == targetStatus) return;

      HapticFeedback.mediumImpact();
      await ref.read(updateTaskControllerProvider.notifier).updateTask(
            projectId: projectId,
            taskId: task.id,
            backlogStatus: targetStatus,
          );
      ref.invalidate(taskStateNotifierProvider);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal list of headers with DragTargets
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final count = lists[i].length;
              final isSelected = activeColumn.value == i;

              return DragTarget<TaskEntity>(
                onWillAcceptWithDetails: (d) => !isViewer && d.data.backlogStatus != statuses[i],
                onAcceptWithDetails: (d) => handleDropped(d.data, i),
                builder: (context, candidates, _) {
                  final hovering = candidates.isNotEmpty;

                  return GestureDetector(
                    onTap: () => activeColumn.value = i,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: hovering
                            ? colors[i].withValues(alpha: 0.1)
                            : isSelected
                                ? AppColors.surface
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: hovering
                              ? colors[i]
                              : isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            titles[i],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: lists[activeColumn.value].isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
                      const SizedBox(height: 8),
                      Text(
                        'No ${titles[activeColumn.value].toLowerCase()} backlog tasks',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lists[activeColumn.value].length,
                  itemBuilder: (context, idx) {
                    final t = lists[activeColumn.value][idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Draggable<TaskEntity>(
                        data: t,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 32,
                            child: TaskCard(
                              task: t,
                              projectName: '',
                              onEdit: () {},
                              onDelete: () {},
                              onTap: () {},
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: TaskCard(
                            task: t,
                            projectName: '',
                            onEdit: () {},
                            onDelete: () {},
                            onTap: () {},
                          ),
                        ),
                        child: TaskCard(
                          task: t,
                          projectName: '',
                          onEdit: () {},
                          onDelete: () {},
                          onTap: () {},
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
