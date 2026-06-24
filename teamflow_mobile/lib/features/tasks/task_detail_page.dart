import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/comments_providers.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/activities_providers.dart';

import '../auth/presentation/providers/providers.dart';
import '../teams/domain/entities/team_member_entity.dart';
import '../teams/presentation/providers/teams_providers.dart';

class TaskDetailPage extends HookConsumerWidget {
  final TaskEntity task;
  final String projectName;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.projectName,
  });

  Color _priorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'URGENT':
        return AppColors.danger;
      case 'HIGH':
        return AppColors.warning;
      case 'MEDIUM':
        return AppColors.primary;
      case 'LOW':
        return AppColors.success;
      default:
        return AppColors.muted;
    }
  }

  String _priorityText(String? priority) {
    if (priority == null || priority.isEmpty) return 'Medium';
    return priority[0].toUpperCase() + priority.substring(1).toLowerCase();
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.IN_PROGRESS:
        return AppColors.primary;
      case TaskStatus.DONE:
        return AppColors.success;
      case TaskStatus.TODO:
        return AppColors.warning;
      case TaskStatus.REVIEW:
        return AppColors.danger;
      case TaskStatus.BLOCKED:
        return AppColors.muted;
    }
  }

  String get _statusText {
    switch (task.status) {
      case TaskStatus.IN_PROGRESS:
        return 'In Progress';
      case TaskStatus.DONE:
        return 'Done';
      case TaskStatus.TODO:
        return 'To Do';
      case TaskStatus.REVIEW:
        return 'Review';
      case TaskStatus.BLOCKED:
        return 'Blocked';
    }
  }

  Widget _buildMetaRow(String label, Widget valueWidget) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String name, String time, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: name, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentCtrl = useTextEditingController();
    final commentsAsync = ref.watch(taskCommentsProvider(task.id));
    final activitiesAsync = ref.watch(taskActivitiesProvider(task.id));
    final activeTabIdx = useState(0);

    final currentUser = ref.watch(authStateNotifierProvider).user;
    final currentUserName = currentUser?.name ?? 'User';

    final teamsState = ref.watch(teamsStateNotifierProvider);
    final allMembers = teamsState.teams.expand((t) => t.members).toList();
    final assigneeMember = allMembers.cast<TeamMemberEntity?>().firstWhere(
      (m) => m?.userId == task.assignedToId,
      orElse: () => null,
    );
    final assigneeName = assigneeMember?.user?.name ?? 'Unassigned';

    final dueDateStr = task.dueDate != null
        ? '${_getMonthName(task.dueDate!.month)} ${task.dueDate!.day}, ${task.dueDate!.year}'
        : 'No due date';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              projectName.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                border: Border.all(color: _statusColor.withOpacity(0.2), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _statusText,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    task.description != null && task.description!.trim().isNotEmpty
                        ? task.description!
                        : 'No description provided.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Meta section
                  _buildMetaRow(
                    'Assignees',
                    Row(
                      children: [
                        AppAvatar(name: assigneeName, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          assigneeName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+ Add',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMetaRow(
                    'Due Date',
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Text(
                          dueDateStr,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMetaRow(
                    'Priority',
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _priorityColor(task.priority),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _priorityText(task.priority),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMetaRow(
                    'Tags',
                    Row(
                      children: [
                        if (task.tags != null && task.tags!.isNotEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: task.tags!.map((tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          tag,
                                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.close_rounded, size: 10, color: AppColors.muted),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                          )
                        else
                          Text(
                            'No tags',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.muted,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          '+ Add',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tab Bar for Activity / Comments
                  Container(
                    height: 36,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => activeTabIdx.value = 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: activeTabIdx.value == 0
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Activity',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: activeTabIdx.value == 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: activeTabIdx.value == 0
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => activeTabIdx.value = 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: activeTabIdx.value == 1
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Comments',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: activeTabIdx.value == 1
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: activeTabIdx.value == 1
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (activeTabIdx.value == 0)
                    activitiesAsync.when(
                      data: (activities) {
                        if (activities.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No activity logs yet',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return Column(
                          children: activities.map((act) {
                            return _buildActivityItem(
                              act.user.name,
                              act.createdAt.split('T').first,
                              act.content,
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading activities', style: GoogleFonts.inter(color: AppColors.danger)),
                    )
                  else
                    commentsAsync.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No comments yet',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return Column(
                          children: comments.map((c) {
                            final member = allMembers.cast<TeamMemberEntity?>().firstWhere(
                              (m) => m?.userId == c.userId,
                              orElse: () => null,
                            );
                            final commenterName = member?.user?.name ?? 'User (${c.userId.length > 4 ? c.userId.substring(0, 4) : c.userId})';
                            return _buildActivityItem(
                              commenterName,
                              c.createdAt.split('T').first,
                              c.content,
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading comments', style: GoogleFonts.inter(color: AppColors.danger)),
                    ),
                ],
              ),
            ),
          ),

          // Comment input at bottom
          if (activeTabIdx.value == 1)
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AppAvatar(name: currentUserName, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      final content = commentCtrl.text.trim();
                      if (content.isNotEmpty) {
                        ref.read(taskCommentsProvider(task.id).notifier).postComment(content);
                        commentCtrl.clear();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
