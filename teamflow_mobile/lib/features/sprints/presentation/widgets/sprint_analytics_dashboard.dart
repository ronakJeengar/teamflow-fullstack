import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tasks/domain/entitties/task_entity.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/models/sprint_model.dart';
import '../providers/sprints_providers.dart';

class SprintAnalyticsDashboard extends HookConsumerWidget {
  final String projectId;

  const SprintAnalyticsDashboard({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskStateNotifierProvider);
    final sprintsAsync = ref.watch(sprintsListProvider(projectId));

    return sprintsAsync.when(
      data: (sprints) {
        if (sprints.isEmpty) return const SizedBox.shrink();

        final projectTasks = tasksState.tasks;

        // Calculate Velocity for past COMPLETED sprints
        final completedSprints = sprints.where((s) => s.status == SprintStatus.COMPLETED).toList();
        final velocityData = completedSprints.map((s) {
          final pts = projectTasks
              .where((t) => t.sprintId == s.id && t.status == TaskStatus.DONE)
              .fold<int>(0, (sum, t) => sum + (t.storyPoints ?? 0));
          return _VelocityBar(sprintName: s.name, points: pts);
        }).toList();

        // Calculate Burndown for the ACTIVE sprint
        final activeSprint = sprints.firstWhere(
          (s) => s.status == SprintStatus.ACTIVE,
          orElse: () => sprints.first,
        );

        final activeSprintTasks = projectTasks.where((t) => t.sprintId == activeSprint.id).toList();
        final totalSprintPoints = activeSprintTasks.fold<int>(0, (sum, t) => sum + (t.storyPoints ?? 0));
        final completedSprintPoints = activeSprintTasks
            .where((t) => t.status == TaskStatus.DONE)
            .fold<int>(0, (sum, t) => sum + (t.storyPoints ?? 0));

        // Generate burndown points array (Ideal vs Actual)
        final daysCount = 10; // Default 10 sprint working days
        final idealPoints = List.generate(daysCount, (i) {
          return totalSprintPoints - (i * (totalSprintPoints / (daysCount - 1)));
        });

        // Simple actual simulation based on completion ratio
        final actualPoints = List.generate(daysCount, (i) {
          if (i < 4) {
            return totalSprintPoints.toDouble();
          } else if (i < 7) {
            return (totalSprintPoints - (completedSprintPoints * 0.4)).toDouble();
          } else {
            return (totalSprintPoints - completedSprintPoints).toDouble();
          }
        });

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sprint Insights',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              // 2-column or list based layout
              Text(
                'Sprint Burndown (Ideal vs Actual)',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _BurndownPainter(ideal: idealPoints, actual: actualPoints),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(AppColors.primary, 'Ideal Burndown'),
                  const SizedBox(width: 24),
                  _buildLegend(AppColors.success, 'Remaining Effort'),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),

              Text(
                'Team Velocity (Completed Points)',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              velocityData.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Complete your first sprint to track velocity.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: velocityData.map((bar) {
                          final heightPct = (bar.points / 30).clamp(0.1, 1.0); // max 30 pts reference
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${bar.points}p',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 24,
                                height: 80 * heightPct,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, Color(0xFF6366F1)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bar.sprintName,
                                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VelocityBar {
  final String sprintName;
  final int points;

  _VelocityBar({required this.sprintName, required this.points});
}

class _BurndownPainter extends CustomPainter {
  final List<double> ideal;
  final List<double> actual;

  _BurndownPainter({required this.ideal, required this.actual});

  @override
  void paint(Canvas canvas, Size size) {
    final idealPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final actualPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;

    // Determine graph range
    final maxPts = ideal.isNotEmpty ? ideal.first : 20.0;
    final w = size.width;
    final h = size.height;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 3; i++) {
      final y = h * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    if (ideal.isEmpty) return;

    // Plot Ideal Line
    final idealPath = Path();
    for (int i = 0; i < ideal.length; i++) {
      final x = w * (i / (ideal.length - 1));
      final y = h - (h * (ideal[i] / maxPts));
      if (i == 0) {
        idealPath.moveTo(x, y);
      } else {
        idealPath.lineTo(x, y);
      }
    }
    canvas.drawPath(idealPath, idealPaint);

    // Plot Actual Line
    final actualPath = Path();
    for (int i = 0; i < actual.length; i++) {
      final x = w * (i / (actual.length - 1));
      final y = h - (h * (actual[i].clamp(0.0, maxPts) / maxPts));
      if (i == 0) {
        actualPath.moveTo(x, y);
      } else {
        actualPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
    canvas.drawPath(actualPath, actualPaint);
  }

  @override
  bool shouldRepaint(covariant _BurndownPainter oldDelegate) => true;
}
