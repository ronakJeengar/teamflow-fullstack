import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../data/models/sprint_model.dart';
import '../providers/sprint_controller.dart';
import '../providers/sprints_providers.dart';
import 'create_sprint_sheet.dart';
import 'edit_sprint_sheet.dart';
import '../pages/sprint_detail_page.dart';
import 'sprint_analytics_dashboard.dart';

class SprintListView extends HookConsumerWidget {
  final String projectId;
  final String teamId;
  final bool isViewer;

  const SprintListView({
    super.key,
    required this.projectId,
    required this.teamId,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sprintsAsync = ref.watch(sprintsListProvider(projectId));
    final activeTab = useState(0); // 0 = Active & Planned, 1 = Completed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SprintAnalyticsDashboard(projectId: projectId),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildTabButton('Active & Planned', 0, activeTab),
              const SizedBox(width: 16),
              _buildTabButton('Completed', 1, activeTab),
              const Spacer(),
              if (!isViewer)
                ElevatedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CreateSprintSheet(projectId: projectId),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: Text('Plan Sprint', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
            child: sprintsAsync.when(
              data: (sprints) {
                final filtered = sprints.where((s) {
                  if (activeTab.value == 0) {
                    return s.status == SprintStatus.PLANNED || s.status == SprintStatus.ACTIVE;
                  } else {
                    return s.status == SprintStatus.COMPLETED || s.status == SprintStatus.CANCELLED;
                  }
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        activeTab.value == 0 ? 'No active or planned sprints' : 'No completed sprints',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final sprint = filtered[index];
                    return _buildSprintCard(context, ref, sprint);
                  },
                );
              },
              loading: () => const Center(child: TeamFlowLoader(size: 40)),
              error: (err, stack) => Center(
                child: Text('Error loading sprints: $err', style: GoogleFonts.inter(color: AppColors.danger)),
              ),
            ),
          ),
        ],
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
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSprintCard(BuildContext context, WidgetRef ref, SprintModel sprint) {
    final startStr = DateFormat('MMM dd').format(sprint.startDate);
    final endStr = DateFormat('MMM dd, yyyy').format(sprint.endDate);
    final isSprintActive = sprint.status == SprintStatus.ACTIVE;

    Color statusColor;
    switch (sprint.status) {
      case SprintStatus.ACTIVE:
        statusColor = AppColors.primary;
        break;
      case SprintStatus.COMPLETED:
        statusColor = AppColors.success;
        break;
      case SprintStatus.CANCELLED:
        statusColor = AppColors.danger;
        break;
      case SprintStatus.PLANNED:
      default:
        statusColor = AppColors.textSecondary;
        break;
    }

    // In a FutureProvider we fetch stats reactively for progress
    final statsAsync = ref.watch(sprintStatsProvider(sprint.id));

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSprintActive ? AppColors.primary.withOpacity(0.5) : AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SprintDetailPage(sprintId: sprint.id, teamId: teamId, isViewer: isViewer),
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sprint.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sprint.status.name,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (!isViewer) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 100),
                      onSelected: (val) async {
                        if (val == 'edit') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EditSprintSheet(sprint: sprint),
                          );
                        } else if (val == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: Text('Delete Sprint', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              content: Text('Are you sure you want to delete this sprint?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(sprintControllerProvider.notifier).deleteSprint(sprint.id, sprint.projectId);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', height: 32, child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', height: 32, child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                  ],
                ],
              ),
              if (sprint.goal != null && sprint.goal!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  sprint.goal!,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 14, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    '$startStr - $endStr',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
                  ),
                  const Spacer(),
                  statsAsync.maybeWhen(
                    data: (stats) => Text(
                      '${stats.completed}/${stats.totalTasks} Tasks',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              statsAsync.maybeWhen(
                data: (stats) => Column(
                  children: [
                    LinearProgressIndicator(
                      value: stats.totalTasks > 0 ? stats.completed / stats.totalTasks : 0,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted),
                        ),
                        Text(
                          '${stats.completionPercentage}%',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                orElse: () => const LinearProgressIndicator(value: 0, minHeight: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
