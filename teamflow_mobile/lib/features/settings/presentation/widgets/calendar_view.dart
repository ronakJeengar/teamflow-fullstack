import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widget/edit_task_sheet.dart';
import '../../../tasks/domain/entitties/task_entity.dart';
import '../../../sprints/presentation/providers/sprints_providers.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';

class CalendarView extends HookConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);
    final currentDate = useState(DateTime.now());
    final selectedDate = useState(DateTime.now());
    final calendarMode = useState('Month'); // 'Day' | 'Week' | 'Month'

    return tasksAsync.when(
          data: (tasks) {
            // Month details
            final year = currentDate.value.year;
            final month = currentDate.value.month;
            final firstDayOfMonth = DateTime(year, month, 1);
            final lastDayOfMonth = DateTime(year, month + 1, 0);
            final daysInMonth = lastDayOfMonth.day;
            final startWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

            // Navigate months
            void nextMonth() {
              currentDate.value = DateTime(year, month + 1, 1);
            }

            void prevMonth() {
              currentDate.value = DateTime(year, month - 1, 1);
            }

            // Group tasks by date
            List<TaskEntity> getTasksForDate(DateTime date) {
              return tasks.where((t) {
                if (t.dueDate == null) return false;
                final due = t.dueDate!.toLocal();
                return due.year == date.year && due.month == date.month && due.day == date.day;
              }).toList();
            }

            final dayTasks = getTasksForDate(selectedDate.value);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(currentDate.value),
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                          onPressed: prevMonth,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          onPressed: nextMonth,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                    return SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.muted),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Calendar Month grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: daysInMonth + startWeekday - 1,
                  itemBuilder: (context, index) {
                    if (index < startWeekday - 1) {
                      return const SizedBox.shrink();
                    }

                    final dayNumber = index - startWeekday + 2;
                    final dayDate = DateTime(year, month, dayNumber);
                    final isSelected = selectedDate.value.day == dayNumber &&
                        selectedDate.value.month == month &&
                        selectedDate.value.year == year;
                    final isToday = DateTime.now().day == dayNumber &&
                        DateTime.now().month == month &&
                        DateTime.now().year == year;

                    final dateTasks = getTasksForDate(dayDate);

                    return GestureDetector(
                      onTap: () => selectedDate.value = dayDate,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : isToday
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : AppColors.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNumber',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                              ),
                            ),
                            if (dateTasks.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dateTasks.take(3).map((t) {
                                  return Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Tasks list for selected day
                Text(
                  'Tasks Due on ${DateFormat('MMM dd, yyyy').format(selectedDate.value)}',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                dayTasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'No tasks due on this day',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dayTasks.length,
                        itemBuilder: (context, idx) {
                          final task = dayTasks[idx];
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
                                'Priority: ${task.priority ?? "Medium"} • Status: ${task.status.name}',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => EditTaskSheet(
                                    task: task,
                                    projectId: task.projectId,
                                    teamId: '',
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ],
            );
          },
          loading: () => const Center(child: TeamFlowLoader(size: 40)),
          error: (e, __) => Center(child: Text('Error loading calendar: $e')),
        );
  }
}
