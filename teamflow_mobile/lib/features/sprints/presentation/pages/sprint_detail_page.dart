import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../../core/widgets/task_card.dart';
import '../../../tasks/domain/entitties/task_entity.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/models/sprint_model.dart';
import '../providers/sprint_controller.dart';
import '../providers/sprints_providers.dart';

class SprintDetailPage extends HookConsumerWidget {
  final String sprintId;
  final String teamId;
  final bool isViewer;

  const SprintDetailPage({
    super.key,
    required this.sprintId,
    required this.teamId,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sprintAsync = ref.watch(sprintDetailsProvider(sprintId));
    final activeTab = useState(0); // 0 = Tasks, 1 = Metrics

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: sprintAsync.maybeWhen(
          data: (sprint) => Text(sprint.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          orElse: () => Text('Sprint Detail', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: sprintAsync.when(
        data: (sprint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSprintHeader(context, ref, sprint),
              const Divider(color: AppColors.border, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildTabButton('Tasks', 0, activeTab),
                    const SizedBox(width: 16),
                    _buildTabButton('Board', 1, activeTab),
                    const SizedBox(width: 16),
                    _buildTabButton('Metrics', 2, activeTab),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: activeTab.value == 0
                    ? _buildTasksTab(context, ref, sprint)
                    : activeTab.value == 1
                        ? _buildBoardTab(context, ref, sprint)
                        : _buildMetricsTab(context, ref, sprint),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, ValueNotifier<int> activeTab) {
    final isSelected = activeTab.value == index;
    return GestureDetector(
      onTap: () => activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2))
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSprintHeader(BuildContext context, WidgetRef ref, SprintModel sprint) {
    final startStr = DateFormat('MMM dd, yyyy').format(sprint.startDate);
    final endStr = DateFormat('MMM dd, yyyy').format(sprint.endDate);
    final isPlanned = sprint.status == SprintStatus.PLANNED;
    final isActive = sprint.status == SprintStatus.ACTIVE;

    final controllerState = ref.watch(sprintControllerProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${sprint.status.name}',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
              ),
              if (!isViewer) ...[
                if (isPlanned) ...[
                  ElevatedButton(
                    onPressed: controllerState.isLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(sprintControllerProvider.notifier)
                                .startSprint(sprint.id, sprint.projectId);
                            if (success && context.mounted) {
                              showAppSnackBar(context, 'Sprint "${sprint.name}" started!');
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 16)),
                    child: Text('Start Sprint', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: controllerState.isLoading
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: Text('Cancel Sprint', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                content: Text('Are you sure you want to cancel sprint "${sprint.name}"?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.danger))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final success = await ref
                                  .read(sprintControllerProvider.notifier)
                                  .cancelSprint(sprint.id, sprint.projectId);
                              if (success && context.mounted) {
                                showAppSnackBar(context, 'Sprint cancelled successfully!');
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger), padding: const EdgeInsets.symmetric(horizontal: 16)),
                    child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
                if (isActive) ...[
                  ElevatedButton(
                    onPressed: controllerState.isLoading
                        ? null
                        : () async {
                            // Check if complete has force needed
                            final stats = ref.read(sprintStatsProvider(sprint.id)).value;
                            final remaining = stats?.remaining ?? 0;

                            bool force = false;
                            if (remaining > 0) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: Text('Unfinished Tasks', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  content: Text('This sprint has $remaining open tasks. Do you want to move them back to the backlog and complete the sprint?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Complete (Force)', style: TextStyle(color: AppColors.warning))),
                                  ],
                                ),
                              );
                              if (confirm != true) return;
                              force = true;
                            }

                            final success = await ref
                                .read(sprintControllerProvider.notifier)
                                .completeSprint(sprint.id, sprint.projectId, force: force);
                            if (success && context.mounted) {
                              showAppSnackBar(context, 'Sprint completed successfully!');
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 16)),
                    child: Text('Complete Sprint', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: controllerState.isLoading
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: Text('Cancel Sprint', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                content: Text('Are you sure you want to cancel sprint "${sprint.name}"?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.danger))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final success = await ref
                                  .read(sprintControllerProvider.notifier)
                                  .cancelSprint(sprint.id, sprint.projectId);
                              if (success && context.mounted) {
                                showAppSnackBar(context, 'Sprint cancelled successfully!');
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger), padding: const EdgeInsets.symmetric(horizontal: 16)),
                    child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '$startStr - $endStr',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (sprint.goal != null && sprint.goal!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Sprint Goal:',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              sprint.goal!,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, WidgetRef ref, SprintModel sprint) {
    final tasks = sprint.tasks ?? [];

    return Column(
      children: [
        if (!isViewer && sprint.status == SprintStatus.PLANNED)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _showAssignTasksModal(context, ref, sprint),
              icon: const Icon(Icons.add_task_rounded, size: 16, color: AppColors.primary),
              label: Text('Assign Tasks to Sprint', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        Expanded(
          child: tasks.isEmpty
              ? Center(child: Text('No tasks in this sprint', style: GoogleFonts.inter(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, idx) {
                    final t = tasks[idx];
                    // Convert TaskModel to TaskEntity to reuse TaskCard
                    final taskEntity = TaskEntity(
                      id: t.id,
                      title: t.title,
                      description: t.description,
                      status: t.status,
                      priority: t.priority,
                      dueDate: t.dueDate,
                      tags: t.tags,
                      projectId: t.projectId,
                      createdById: t.createdById,
                      assignedToId: t.assignedToId,
                      createdAt: t.createdAt,
                      updatedAt: t.updatedAt,
                      sprintId: t.sprintId,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              task: taskEntity,
                              projectName: sprint.name,
                              onEdit: () {},
                              onDelete: () {},
                              canEdit: !isViewer,
                              canDelete: !isViewer,
                              onTap: () {},
                            ),
                          ),
                          if (!isViewer && sprint.status == SprintStatus.PLANNED) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.danger),
                              onPressed: () async {
                                final success = await ref
                                    .read(sprintControllerProvider.notifier)
                                    .removeTask(sprint.id, sprint.projectId, t.id);
                                if (success && context.mounted) {
                                  showAppSnackBar(context, 'Task removed from sprint');
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetricsTab(BuildContext context, WidgetRef ref, SprintModel sprint) {
    final statsAsync = ref.watch(sprintStatsProvider(sprint.id));
    final burndownAsync = ref.watch(sprintBurndownProvider(sprint.id));
    final velocityAsync = ref.watch(sprintVelocityProvider(sprint.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SPRINT PROGRESS STATS',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          statsAsync.when(
            data: (stats) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatTile('Total Tasks', '${stats.totalTasks}'),
                  _buildStatTile('Completed', '${stats.completed}'),
                  _buildStatTile('Remaining', '${stats.remaining}'),
                  _buildStatTile('Overdue Tasks', '${stats.overdue}', isDanger: stats.overdue > 0),
                  _buildStatTile('Completed Points', '${stats.completedPoints} / ${stats.totalPoints}'),
                  _buildStatTile('Completion Rate', '${stats.completionPercentage}%'),
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (err, stack) => Text('Error loading stats: $err'),
          ),
          const SizedBox(height: 24),
          Text(
            'BURNDOWN HISTORY',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          burndownAsync.when(
            data: (burndown) {
              if (burndown.isEmpty) return const Text('No burndown details.');
              return Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
                          Text('Remaining Tasks', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
                          Text('Ideal Tasks', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
                        ],
                      ),
                      const Divider(color: AppColors.border),
                      ...burndown.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.date, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary)),
                              Text('${entry.actual}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              Text('${entry.ideal}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (err, stack) => Text('Error loading burndown: $err'),
          ),
          const SizedBox(height: 24),
          Text(
            'VELOCITY METRICS (Completed Points)',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          velocityAsync.when(
            data: (velocity) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Average Project Velocity:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                        Text('${velocity.averageVelocity} Points', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (velocity.history.isEmpty)
                    Text('No completed sprints to compute historical velocity.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: velocity.history.length,
                      itemBuilder: (ctx, idx) {
                        final v = velocity.history[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(v.sprintName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary)),
                              Text('${v.completedPoints} Completed Points', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (err, stack) => Text('Error loading velocity: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, {bool isDanger = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDanger ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignTasksModal(BuildContext context, WidgetRef ref, SprintModel sprint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      builder: (_) {
        return _AssignTasksSheet(sprint: sprint);
      },
    );
  }

  Widget _buildBoardTab(BuildContext context, WidgetRef ref, SprintModel sprint) {
    final tasks = sprint.tasks ?? [];
    
    // Group tasks by status
    final todoTasks = tasks.where((t) => t.status == TaskStatus.TODO).toList();
    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.IN_PROGRESS).toList();
    final reviewTasks = tasks.where((t) => t.status == TaskStatus.REVIEW).toList();
    final blockedTasks = tasks.where((t) => t.status == TaskStatus.BLOCKED).toList();
    final doneTasks = tasks.where((t) => t.status == TaskStatus.DONE).toList();

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Todo (${todoTasks.length})'),
              Tab(text: 'In Progress (${inProgressTasks.length})'),
              Tab(text: 'Review (${reviewTasks.length})'),
              Tab(text: 'Blocked (${blockedTasks.length})'),
              Tab(text: 'Done (${doneTasks.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBoardColumn(context, ref, sprint, todoTasks, 'Todo'),
                _buildBoardColumn(context, ref, sprint, inProgressTasks, 'In Progress'),
                _buildBoardColumn(context, ref, sprint, reviewTasks, 'Review'),
                _buildBoardColumn(context, ref, sprint, blockedTasks, 'Blocked'),
                _buildBoardColumn(context, ref, sprint, doneTasks, 'Done'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardColumn(
    BuildContext context,
    WidgetRef ref,
    SprintModel sprint,
    List<TaskModel> tasksList,
    String columnName,
  ) {
    if (tasksList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(
              'No tasks in $columnName',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasksList.length,
      itemBuilder: (context, idx) {
        final t = tasksList[idx];
        final taskEntity = TaskEntity(
          id: t.id,
          title: t.title,
          description: t.description,
          status: t.status,
          priority: t.priority,
          dueDate: t.dueDate,
          tags: t.tags,
          projectId: t.projectId,
          createdById: t.createdById,
          assignedToId: t.assignedToId,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
          sprintId: t.sprintId,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TaskCard(
            task: taskEntity,
            projectName: sprint.name,
            onEdit: () {},
            onDelete: () {},
            canEdit: !isViewer,
            canDelete: !isViewer,
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _AssignTasksSheet extends HookConsumerWidget {
  final SprintModel sprint;

  const _AssignTasksSheet({required this.sprint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskStateNotifierProvider);
    final selectedTasks = useState<Set<String>>({});
    final controllerState = ref.watch(sprintControllerProvider);

    // Filter tasks in the project that don't belong to any sprint yet
    final unassignedTasks = tasksAsync.tasks.where((t) => t.sprintId == null).toList();

    void handleAssign() async {
      if (selectedTasks.value.isEmpty) {
        showAppSnackBar(context, 'Please select at least one task');
        return;
      }

      final success = await ref
          .read(sprintControllerProvider.notifier)
          .assignTasks(sprint.id, sprint.projectId, selectedTasks.value.toList());

      if (success && context.mounted) {
        showAppSnackBar(context, 'Tasks assigned successfully!');
        Navigator.pop(context);
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assign Tasks to ${sprint.name}',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: AppColors.border),
          Expanded(
            child: unassignedTasks.isEmpty
                ? Center(child: Text('No unassigned tasks in project', style: GoogleFonts.inter(color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: unassignedTasks.length,
                    itemBuilder: (ctx, idx) {
                      final t = unassignedTasks[idx];
                      final isSelected = selectedTasks.value.contains(t.id);

                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        title: Text(t.title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                        subtitle: Text('Status: ${t.status.name}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                        onChanged: (val) {
                          final updated = Set<String>.from(selectedTasks.value);
                          if (val == true) {
                            updated.add(t.id);
                          } else {
                            updated.remove(t.id);
                          }
                          selectedTasks.value = updated;
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controllerState.isLoading ? null : handleAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: controllerState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Assign Selected Tasks', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
