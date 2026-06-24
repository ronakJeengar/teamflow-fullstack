import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teamflow_mobile/features/projects/domain/entitties/project_entity.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';

class ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String category;
  final String? ownerName;

  const ProjectCard({
    super.key,
    required this.project,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    this.category = 'Design',
    this.ownerName,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  Color get _workspaceColor {
    const colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
    ];
    final hash = widget.project.name.codeUnits.fold<int>(0, (s, c) => s + c);
    return colors[hash % colors.length];
  }

  String get _dateStr {
    try {
      final d = DateTime.parse(widget.project.createdAt);
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${m[d.month - 1]} ${d.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskCount = widget.project.count?.tasks ?? 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isHeightBounded = constraints.maxHeight != double.infinity && constraints.maxHeight > 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.border,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: isHeightBounded ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    // Top layer: Avatar + Title + Menu
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                      child: Row(
                        children: [
                          // Workspace avatar (radius 8px)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _workspaceColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.project.name.isNotEmpty
                                  ? widget.project.name[0].toUpperCase()
                                  : 'P',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.project.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _hovered ? Colors.white : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.canManage)
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                size: 16,
                                color: AppColors.muted,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 100),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  widget.onEdit();
                                } else if (val == 'delete') {
                                  widget.onDelete();
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
                    ),

                    // Category + Task Count
                    Padding(
                      padding: const EdgeInsets.only(left: 60, top: 4, right: 16),
                      child: Text(
                        '${widget.category} · $taskCount tasks',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (isHeightBounded) const Spacer() else const SizedBox(height: 16),

                    const Divider(
                      color: AppColors.border,
                      height: 1,
                      thickness: 1,
                    ),

                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: LayoutBuilder(
                        builder: (context, footerConstraints) {
                          final showDateTime = footerConstraints.maxWidth > 150;
                          return Row(
                            children: [
                              // Avatar and Owner Name (Flexible)
                              if (widget.ownerName != null)
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppAvatar(
                                        name: widget.ownerName!,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.ownerName!,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (widget.ownerName != null && showDateTime) const SizedBox(width: 8),
                              if (showDateTime && _dateStr.isNotEmpty)
                                Text(
                                  'Updated $_dateStr',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
