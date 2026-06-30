import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../tasks/presentation/providers/activities_providers.dart';

class ActivityFeedView extends HookConsumerWidget {
  const ActivityFeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final workspaceId = authState.user?.activeWorkspaceId;

    if (workspaceId == null) {
      return Center(
        child: Text(
          'No active workspace found',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    final activitiesAsync = ref.watch(workspaceActivitiesProvider(workspaceId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Workspace Activity Timeline',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No activities logged yet in this workspace',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, idx) {
                final log = activities[idx];
                final parsedDate = DateTime.tryParse(log.createdAt)?.toLocal() ?? DateTime.now();
                final formattedTime = DateFormat('MMM dd, hh:mm a').format(parsedDate);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline node line and dot
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                        Container(
                          width: 2,
                          height: 60,
                          color: idx == activities.length - 1 ? Colors.transparent : AppColors.border,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Activity details card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppAvatar(name: log.user.name, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  log.user.name,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                const Spacer(),
                                Text(
                                  formattedTime,
                                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                  log.content,
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, __) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text('Error loading activity feed: $e'),
            ),
          ),
        ),
      ],
    );
  }
}
