import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teamflow_mobile/features/tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';

class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final String projectName;
  final String category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool>? onCheckboxChanged;
  final bool isFloating;
  final VoidCallback? onTap;
  final bool canEdit;
  final bool canDelete;
  final String? assigneeName;

  const TaskCard({
    super.key,
    required this.task,
    this.projectName = 'Website Redesign',
    this.category = 'Design',
    required this.onEdit,
    required this.onDelete,
    this.onCheckboxChanged,
    this.isFloating = false,
    this.onTap,
    this.canEdit = false,
    this.canDelete = false,
    this.assigneeName,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _hovered = false;

  Color get _statusColor {
    switch (widget.task.status) {
      case TaskStatus.IN_PROGRESS:
        return AppColors.primary;
      case TaskStatus.DONE:
        return AppColors.success;
      case TaskStatus.TODO:
        return AppColors.warning;
      case TaskStatus.REVIEW:
        return Colors.blue;
      case TaskStatus.BLOCKED:
        return AppColors.danger;
    }
  }

  String get _statusText {
    switch (widget.task.status) {
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

  String get _priorityLabel {
    // Determine priority (since tasks in the app map to high by default or similar)
    return 'High';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;
    final isCompleted = widget.task.status == TaskStatus.DONE;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            // Main card
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isFloating
                      ? statusColor.withOpacity(0.3)
                      : (_hovered
                          ? AppColors.primary.withOpacity(0.4)
                          : AppColors.border),
                  width: widget.isFloating ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Layer 1: Checkbox + Title + Status
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 12,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Custom Checkbox
                          GestureDetector(
                            onTap: () {
                              if (widget.onCheckboxChanged != null) {
                                widget.onCheckboxChanged!(!isCompleted);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isCompleted
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 11,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? AppColors.muted
                                    : AppColors.textPrimary,
                                decoration:
                                    isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.05),
                              border: Border.all(
                                color: statusColor.withOpacity(0.15),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Layer 2: Project Path
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 48,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Text(
                        '${widget.projectName} · ${widget.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.muted,
                        ),
                      ),
                    ),

                    // 1px Border Divider
                    const Divider(
                      color: AppColors.border,
                      height: 1,
                      thickness: 1,
                    ),

                    // Layer 3: Meta row (darker background)
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Due date
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.task.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Priority
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _priorityLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Assignee Stack
                          Expanded(
                            child: Row(
                              children: [
                                if (widget.assigneeName != null) ...[
                                  AppAvatar(
                                    name: widget.assigneeName!,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.assigneeName!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.muted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Unassigned',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Actions menu
                          if (widget.canEdit || widget.canDelete)
                            PopupMenuButton<String>(
                              icon: Icon(
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
                                  widget.onEdit();
                                } else if (val == 'delete') {
                                  widget.onDelete();
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                if (widget.canEdit)
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
                                if (widget.canDelete)
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
                    ),
                  ],
                ),
              ),
            ),

            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 3,
                decoration: BoxDecoration(
                  color: _hovered ? statusColor : statusColor.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
