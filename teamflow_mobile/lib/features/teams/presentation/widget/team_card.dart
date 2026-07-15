import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';

class TeamCard extends StatefulWidget {
  final TeamEntity team;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> {
  bool _hovered = false;

  Color get _accentColor {
    const colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
    ];
    final idx = widget.team.name.codeUnits
        .fold<int>(0, (sum, c) => sum + c) %
        colors.length;
    return colors[idx];
  }

  Widget _buildAvatarStack(List<String> names) {
    final visible = names.take(5).toList();
    final extra = names.length - visible.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++)
          Align(
            widthFactor: 0.72,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 1.5,
                ),
              ),
              child: AppAvatar(
                name: visible[i],
                size: 24,
              ),
            ),
          ),
        if (extra > 0) ...[
          const SizedBox(width: 8),
          Text(
            '+$extra members',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = widget.team.members.length;
    final projectCount = widget.team.projects.length;
    final memberNames = widget.team.members
        .map((m) => m.user?.name ?? 'Member')
        .toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
            width: 1.2,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team avatar with gradient
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _accentColor,
                              _accentColor.withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: _accentColor.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.team.name.isNotEmpty
                              ? widget.team.name[0].toUpperCase()
                              : 'T',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.team.name,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _hovered
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.team.description?.isNotEmpty == true
                                  ? widget.team.description!
                                  : 'No description provided',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Menu action button
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
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
                  
                  const SizedBox(height: 16),
                  
                  // Metadata Badges (Projects & Members)
                  Row(
                    children: [
                      _buildMiniBadge(
                        icon: Icons.folder_open_rounded,
                        label: '$projectCount ${projectCount == 1 ? 'project' : 'projects'}',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      _buildMiniBadge(
                        icon: Icons.people_outline_rounded,
                        label: '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bottom section divider line
                  Container(
                    height: 1,
                    color: AppColors.border.withOpacity(0.6),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Footer section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAvatarStack(memberNames),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _hovered ? 1.0 : 0.6,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: _hovered ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}