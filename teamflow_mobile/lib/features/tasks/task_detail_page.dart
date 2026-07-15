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
import 'package:teamflow_mobile/features/tasks/data/models/comment_model.dart';
import 'package:teamflow_mobile/core/mappers/user_mapper.dart';
import 'package:teamflow_mobile/features/sprints/presentation/providers/sprints_providers.dart';

import '../auth/presentation/providers/providers.dart';
import '../teams/domain/entities/team_member_entity.dart';
import '../teams/presentation/providers/teams_providers.dart';
import 'presentation/providers/task_providers.dart';
import 'presentation/widget/edit_task_sheet.dart';

class TaskDetailPage extends HookConsumerWidget {
  final TaskEntity task;
  final String projectName;
  final String teamId;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.projectName,
    required this.teamId,
  });

  Color _priorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'URGENT':
        return const Color(0xFFA855F7);
      case 'HIGH':
        return AppColors.danger;
      case 'MEDIUM':
        return AppColors.warning;
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

  Color _getStatusColor(TaskEntity task) {
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

  String _getStatusText(TaskEntity task) {
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

  Widget _buildCommentItem(BuildContext context, WidgetRef ref, CommentModel c, List<TeamMemberEntity> allMembers, String? currentUserId) {
    final member = allMembers.cast<TeamMemberEntity?>().firstWhere(
      (m) => m?.userId == c.userId,
      orElse: () => null,
    );
    final commenterName = c.user?.name ?? member?.user?.name ?? 'User';
    final isAuthor = c.userId == currentUserId;

    String timeStr = '';
    try {
      final parsedDate = DateTime.parse(c.createdAt).toLocal();
      final now = DateTime.now();
      if (parsedDate.year == now.year && parsedDate.month == now.month && parsedDate.day == now.day) {
        timeStr = '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      } else {
        timeStr = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
    } catch (_) {
      timeStr = c.createdAt.split('T').first;
    }

    final isEdited = c.editedAt != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: commenterName, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      commenterName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    if (isEdited) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(edited)',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isAuthor)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 100),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditDialog(context, ref, task.id, c);
                          } else if (val == 'delete') {
                            _showDeleteDialog(context, ref, task.id, c);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            height: 32,
                            child: Text(
                              'Edit',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            height: 32,
                            child: Text(
                              'Delete',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c.content,
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

  void _showEditDialog(BuildContext context, WidgetRef ref, String taskId, CommentModel comment) {
    final editCtrl = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Edit Comment',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: editCtrl,
          maxLines: null,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final text = editCtrl.text.trim();
              if (text.isNotEmpty) {
                ref.read(taskCommentsProvider(taskId).notifier).editComment(comment.id, text);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String taskId, CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Comment',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.danger,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(taskCommentsProvider(taskId).notifier).removeComment(comment.id);
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch taskStateNotifierProvider to reactively update on edit
    final taskState = ref.watch(taskStateNotifierProvider);
    final task = taskState.tasks.firstWhere(
      (t) => t.id == this.task.id,
      orElse: () => this.task,
    );

    final commentCtrl = useTextEditingController();
    final scrollController = useScrollController();
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
                color: _getStatusColor(task).withOpacity(0.1),
                border: Border.all(color: _getStatusColor(task).withOpacity(0.2), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(task),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(task),
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 18),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => EditTaskSheet(
                  task: task,
                  projectId: task.projectId,
                  teamId: teamId,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(taskCommentsProvider(task.id).notifier).loadComments();
                await ref.read(taskActivitiesProvider(task.id).notifier).loadActivities();
              },
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
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
                    if (task.sprintId != null)
                      _buildMetaRow(
                        'Sprint',
                        ref.watch(sprintDetailsProvider(task.sprintId!)).maybeWhen(
                          data: (sprint) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, color: AppColors.primary, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    sprint.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          orElse: () => Text(
                            'Loading...',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
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
                        loading: () => const Center(child: TeamFlowLoader(size: 32)),
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

                          final notifier = ref.read(taskCommentsProvider(task.id).notifier);

                          return Column(
                            children: [
                              if (notifier.hasMore)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
                                    label: Text(
                                      'Load older comments',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () => ref.read(taskCommentsProvider(task.id).notifier).loadMoreComments(),
                                  ),
                                ),
                              ...comments.map((c) => _buildCommentItem(context, ref, c, allMembers, currentUser?.id)).toList(),
                            ],
                          );
                        },
                        loading: () => _buildShimmerSkeleton(),
                        error: (err, stack) => Text('Error loading comments', style: GoogleFonts.inter(color: AppColors.danger)),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Comment input at bottom
          if (activeTabIdx.value == 1)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    AppAvatar(name: currentUserName, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: commentCtrl,
                          maxLines: null,
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        final content = commentCtrl.text.trim();
                        if (content.isNotEmpty) {
                          ref.read(taskCommentsProvider(task.id).notifier).postComment(content, currentUser?.toModel());
                          commentCtrl.clear();
                          // Auto-scroll to bottom of list
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
