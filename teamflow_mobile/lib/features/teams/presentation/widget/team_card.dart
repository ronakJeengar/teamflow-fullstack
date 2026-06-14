import 'package:flutter/material.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import '../../../../core/theme/app_theme.dart';

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
      Color(0xFF4F6EF7),
      Color(0xFF7C3AED),
      Color(0xFF0D9488),
      Color(0xFFD97706),
      Color(0xFFDB2777),
      Color(0xFF059669),
    ];

    final idx = widget.team.name.codeUnits
        .fold<int>(0, (sum, c) => sum + c) %
        colors.length;

    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final hasDesc =
        widget.team.description != null &&
            widget.team.description!.isNotEmpty;

    final memberCount = widget.team.members.length;
    final projectCount = widget.team.projects.length;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? _accentColor.withOpacity(0.45)
                : AppColors.border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
            BoxShadow(
              color: _accentColor.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────────────── Header ─────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TeamAvatar(
                        name: widget.team.name,
                        color: _accentColor,
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.team.name,
                              style: AppTextStyles.heading3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            if (hasDesc) ...[
                              const SizedBox(height: 4),

                              // Reduced to 1 line to avoid overflow
                              Text(
                                widget.team.description!,
                                style: AppTextStyles.bodySm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit team',
                            onTap: widget.onEdit,
                            color: AppColors.primary,
                            bgColor: AppColors.primaryLight,
                          ),

                          const SizedBox(width: AppSpacing.xs),

                          _ActionButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Delete team',
                            onTap: widget.onDelete,
                            color: AppColors.danger,
                            bgColor: AppColors.dangerLight,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  const Divider(
                    color: AppColors.border,
                    height: 1,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ───────────────── Stats ─────────────────
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.people_outline_rounded,
                        value: '$memberCount',
                        label: memberCount == 1
                            ? 'member'
                            : 'members',
                        color: _accentColor,
                      ),

                      const SizedBox(width: AppSpacing.md),

                      _StatBadge(
                        icon: Icons.folder_outlined,
                        value: '$projectCount',
                        label: projectCount == 1
                            ? 'project'
                            : 'projects',
                        color: _accentColor,
                      ),
                    ],
                  ),

                  // ───────────────── Chips ─────────────────
                  if (memberCount > 0 || projectCount > 0) ...[
                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      height: 30,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...widget.team.members.take(3).map(
                                (m) => Padding(
                              padding: const EdgeInsets.only(
                                right: 6,
                              ),
                              child: _Chip(
                                label: m.user?.name ?? '?',
                                bgColor: AppColors.memberChip,
                                textColor: AppColors.primary,
                                icon:
                                Icons.person_outline_rounded,
                              ),
                            ),
                          ),

                          if (memberCount > 3)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 6,
                              ),
                              child: _Chip(
                                label:
                                '+${memberCount - 3} more',
                                bgColor:
                                AppColors.memberChip,
                                textColor:
                                AppColors.primary,
                              ),
                            ),

                          ...widget.team.projects.take(2).map(
                                (p) => Padding(
                              padding: const EdgeInsets.only(
                                right: 6,
                              ),
                              child: _Chip(
                                label: p.name,
                                bgColor:
                                AppColors.projectChip,
                                textColor:
                                const Color(0xFF1D4ED8),
                                icon:
                                Icons.folder_outlined,
                              ),
                            ),
                          ),

                          if (projectCount > 2)
                            _Chip(
                              label:
                              '+${projectCount - 2} more',
                              bgColor:
                              AppColors.projectChip,
                              textColor:
                              const Color(0xFF1D4ED8),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────── Avatar ─────────────────

class _TeamAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _TeamAvatar({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty
              ? name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ───────────────── Action Button ─────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ───────────────── Stats ─────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.textTertiary,
        ),

        const SizedBox(width: 4),

        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 3),

        Text(
          label,
          style: AppTextStyles.bodySm,
        ),
      ],
    );
  }
}

// ───────────────── Chip ─────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: textColor,
            ),

            const SizedBox(width: 3),
          ],

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}