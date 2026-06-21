import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/ui/app_tokens.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../auth/presentation/widgets/logout_modal.dart';
import '../../../invitation/presentation/widgets/invite_member_sheet.dart';
import '../../../projects/domain/entitties/project_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../providers/team_detail_state_notifier.dart';
import '../providers/team_details_providers.dart';
import '../widget/create_project_sheet.dart';
import '../widget/delete_project_sheet.dart';
import '../widget/edit_project_sheet.dart';

class TeamDetailPage extends HookConsumerWidget {
  final String teamId;

  const TeamDetailPage({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamDetailStateNotifierProvider);
    final currentUserId = ref.watch(authStateNotifierProvider).user?.id ?? '';

    useEffect(() {
      Future.microtask(
        () => ref
            .read(teamDetailStateNotifierProvider.notifier)
            .loadTeamDetail(teamId),
      );
      return null;
    }, const []);

    final tabIndex = useState(0);

    for (final p in [
      createProjectControllerProvider,
      updateProjectControllerProvider,
      deleteProjectControllerProvider,
    ]) {
      ref.listen<AsyncValue<void>>(
        p,
        (_, next) => next.whenOrNull(
          error: (e, _) => showAppSnackBar(context, e.toString()),
        ),
      );
    }

    // Listen for member removal errors
    ref.listen<AsyncValue<void>>(
      removeMemberControllerProvider,
      (_, next) => next.whenOrNull(
        error: (e, _) => showAppSnackBar(context, e.toString()),
      ),
    );

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: switch (state.status) {
        TeamDetailStatus.unknown => const AppLoadingView(
          message: 'Loading team…',
        ),
        TeamDetailStatus.error => AppErrorView(
          title: 'Failed to load team',
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(teamDetailStateNotifierProvider.notifier)
              .loadTeamDetail(teamId),
        ),
        TeamDetailStatus.loaded => _Body(
          state: state,
          teamId: teamId,
          currentUserId: currentUserId,
          tabIndex: tabIndex.value,
          onTabChanged: (i) {
            tabIndex.value = i;
            HapticFeedback.selectionClick();
          },
          onCreateProject: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateProjectSheet(teamId: teamId),
          ),
          onEditProject: (p) => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => EditProjectSheet(project: p, teamId: teamId),
          ),
          onDeleteProject: (p) => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => DeleteProjectSheet(project: p, teamId: teamId),
          ),
          onRemoveMember: (memberId) => ref
              .read(removeMemberControllerProvider.notifier)
              .removeMember(teamId: teamId, memberId: memberId),
        ),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final TeamDetailState state;
  final String teamId;
  final String currentUserId;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onCreateProject;
  final ValueChanged<ProjectEntity> onEditProject;
  final ValueChanged<ProjectEntity> onDeleteProject;
  final ValueChanged<String> onRemoveMember;

  const _Body({
    required this.state,
    required this.teamId,
    required this.currentUserId,
    required this.tabIndex,
    required this.onTabChanged,
    required this.onCreateProject,
    required this.onEditProject,
    required this.onDeleteProject,
    required this.onRemoveMember,
  });

  String get _currentUserRole {
    final match = state.members.where((m) => m.userId == currentUserId);
    return match.isEmpty ? 'VIEWER' : match.first.role.name;
  }

  String? get _ownerUserId {
    final owner = state.members.where((m) => m.role.name == 'OWNER');
    return owner.isEmpty ? null : owner.first.userId;
  }

  bool get _canManage => ['OWNER', 'ADMIN'].contains(_currentUserRole);

  /// Role-based remove permission:
  /// - OWNER can remove ADMIN, MEMBER, VIEWER (anyone except owner themselves)
  /// - ADMIN can remove MEMBER and VIEWER only
  bool _canRemoveMember(TeamMemberEntity target) {
    final targetRole = target.role.name.toUpperCase();
    if (targetRole == 'OWNER') return false; // nobody removes the owner
    switch (_currentUserRole.toUpperCase()) {
      case 'OWNER':
        return true; // owner removes anyone except another owner (guarded above)
      case 'ADMIN':
        return targetRole == 'MEMBER' || targetRole == 'VIEWER';
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = state.team!;
    final projects = state.projects;
    final members = state.members;
    final totalTasks = projects.fold(
      0,
      (sum, p) => sum + (p.count?.tasks ?? 0),
    );

    return Column(
      children: [
        _Header(
          team: team,
          projectCount: projects.length,
          memberCount: members.length,
          totalTasks: totalTasks,
          tabIndex: tabIndex,
          onTabChanged: onTabChanged,
          canManage: _canManage,
          onNewProject: onCreateProject,
          onInvite: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InviteMemberSheet(teamId: team.id),
          ),
          onLogout: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => const LogoutSheet(),
          ),
          onBack: context.canPop() ? () => context.pop() : null,
        ),
        Expanded(
          child: IndexedStack(
            index: tabIndex,
            children: [
              _ProjectsTab(
                projects: projects,
                canManage: _canManage,
                onNewProject: onCreateProject,
                onEdit: onEditProject,
                onDelete: onDeleteProject,
              ),
              _MembersTab(
                members: members,
                canInvite: _canManage,
                canRemoveMember: _canRemoveMember,
                onInvite: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => InviteMemberSheet(teamId: team.id),
                ),
                onRemoveMember: onRemoveMember,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TeamEntity team;
  final int projectCount;
  final int memberCount;
  final int totalTasks;
  final int tabIndex;
  final bool canManage;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onNewProject;
  final VoidCallback onInvite;
  final VoidCallback onLogout;
  final VoidCallback? onBack;

  const _Header({
    required this.team,
    required this.projectCount,
    required this.memberCount,
    required this.totalTasks,
    required this.tabIndex,
    required this.canManage,
    required this.onTabChanged,
    required this.onNewProject,
    required this.onInvite,
    required this.onLogout,
    this.onBack,
  });

  String get _createdLabel {
    try {
      final d = DateTime.parse(team.createdAt);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return 'Since ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color: AppTokens.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: top + AppTokens.s16),

          // ── Back / Title row ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s20),
            child: Row(
              children: [
                if (onBack != null) ...[
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack!,
                  ),
                  SizedBox(width: AppTokens.s10),
                ],
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTokens.brand,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _headerInitials(team.name),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppTokens.s14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: AppTokens.displayLg.copyWith(fontSize: 22),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_createdLabel.isNotEmpty) ...[
                              SizedBox(height: AppTokens.s4),
                              Text(_createdLabel, style: AppTokens.labelXs),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(icon: Icons.logout_rounded, onTap: onLogout),
              ],
            ),
          ),

          SizedBox(height: AppTokens.s20),

          // ── Stats row ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s24),
            child: Row(
              children: [
                _StatCard(
                  value: '$projectCount',
                  label: 'Projects',
                  icon: Icons.folder_rounded,
                  color: AppTokens.brand,
                  surface: AppTokens.brandSurface,
                ),
                SizedBox(width: AppTokens.s10),
                _StatCard(
                  value: '$memberCount',
                  label: 'Members',
                  icon: Icons.group_rounded,
                  color: AppTokens.success,
                  surface: AppTokens.successSurface,
                ),
                SizedBox(width: AppTokens.s10),
                _StatCard(
                  value: '$totalTasks',
                  label: 'Tasks',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTokens.warning,
                  surface: AppTokens.warningSurface,
                ),
              ],
            ),
          ),

          SizedBox(height: AppTokens.s20),

          // ── Tabs + CTA ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s24),
            child: Row(
              children: [
                Expanded(
                  child: TabStrip(
                    labels: const ['Projects', 'Members'],
                    icons: const [Icons.folder_outlined, Icons.group_outlined],
                    selected: tabIndex,
                    onChanged: onTabChanged,
                  ),
                ),
                SizedBox(width: AppTokens.s10),
                _PrimaryBtn(
                  icon: tabIndex == 0
                      ? Icons.add_rounded
                      : Icons.person_add_outlined,
                  label: tabIndex == 0 ? 'New' : 'Invite',
                  onTap: canManage
                      ? (tabIndex == 0 ? onNewProject : onInvite)
                      : null,
                ),
              ],
            ),
          ),

          SizedBox(height: AppTokens.s20),
          Container(height: 1, color: AppTokens.border),
        ],
      ),
    );
  }

  static String _headerInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color surface;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s12,
          vertical: AppTokens.s12,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTokens.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(height: AppTokens.s8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            SizedBox(height: AppTokens.s4),
            Text(
              label,
              style: AppTokens.labelXs.copyWith(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Smooth pill-style tab strip — uses a single LayoutBuilder + Positioned
/// indicator so the sliding pill never causes a rebuild flicker.
class TabStrip extends StatefulWidget {
  final List<String> labels;
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onChanged;

  const TabStrip({
    super.key,
    required this.labels,
    required this.icons,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<TabStrip> createState() => _TabStripState();
}

class _TabStripState extends State<TabStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late Animation<double> _position;
  late Tween<double> _tween;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _tween = Tween(
      begin: widget.selected.toDouble(),
      end: widget.selected.toDouble(),
    );

    _position = _tween.animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant TabStrip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      final from = _position.value;
      final to = widget.selected.toDouble();

      _ctrl.stop();

      _tween = Tween(begin: from, end: to);

      _position = _tween.animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      );

      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SmoothTabStrip(
      labels: widget.labels,
      icons: widget.icons,
      selected: widget.selected,
      onChanged: widget.onChanged,
    );
  }
}

/// Stateful widget that owns the animation cleanly.
class _SmoothTabStrip extends StatefulWidget {
  final List<String> labels;
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onChanged;

  const _SmoothTabStrip({
    required this.labels,
    required this.icons,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_SmoothTabStrip> createState() => _SmoothTabStripState();
}

class _SmoothTabStripState extends State<_SmoothTabStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _pillAnim;
  int _prevSelected = 0;

  @override
  void initState() {
    super.initState();
    _prevSelected = widget.selected;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _pillAnim = AlwaysStoppedAnimation(widget.selected.toDouble());
  }

  @override
  void didUpdateWidget(_SmoothTabStrip old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      final from = _pillAnim.value;
      final to = widget.selected.toDouble();
      _pillAnim = _ctrl.drive(
        Tween<double>(
          begin: from,
          end: to,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      );
      _ctrl
        ..reset()
        ..forward();
      _prevSelected = old.selected;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const padding = 4.0;
    final count = widget.labels.length;

    return Container(
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTokens.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = (constraints.maxWidth - padding * 2) / count;

          return AnimatedBuilder(
            animation: _pillAnim,
            builder: (context, _) {
              final offset = _pillAnim.value * pillWidth;
              return Stack(
                children: [
                  // ── Sliding pill (no rebuilds of text/icons) ─────────────
                  Positioned(
                    left: offset,
                    top: 0,
                    bottom: 0,
                    width: pillWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTokens.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // ── Tab labels (static, no animation overhead) ────────────
                  Row(
                    children: List.generate(count, (i) {
                      final isSelected = widget.selected == i;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onChanged(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    widget.icons[i],
                                    key: ValueKey('${i}_${isSelected}'),
                                    size: 13,
                                    color: isSelected
                                        ? AppTokens.brand
                                        : AppTokens.textSecondary,
                                  ),
                                ),
                                SizedBox(width: AppTokens.s6),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppTokens.textPrimary
                                        : AppTokens.textSecondary,
                                  ),
                                  child: Text(widget.labels[i]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PrimaryBtn({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s10,
        ),
        decoration: BoxDecoration(
          color: enabled ? AppTokens.brand : AppTokens.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: enabled ? Colors.white : AppTokens.textHint,
            ),
            SizedBox(width: AppTokens.s6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : AppTokens.textHint,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProjectsTab extends StatelessWidget {
  final List<ProjectEntity> projects;
  final bool canManage;
  final VoidCallback onNewProject;
  final ValueChanged<ProjectEntity> onEdit;
  final ValueChanged<ProjectEntity> onDelete;

  const _ProjectsTab({
    required this.projects,
    required this.canManage,
    required this.onNewProject,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return AppEmptyState(
        icon: Icons.folder_open_rounded,
        iconColor: AppTokens.brand,
        iconSurface: AppTokens.brandSurface,
        title: 'No projects yet',
        subtitle: canManage
            ? 'Create the first project for this team'
            : 'No projects have been created yet',
        actionLabel: canManage ? 'Create project' : null,
        actionIcon: canManage ? Icons.add_rounded : null,
        onAction: canManage ? onNewProject : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s20,
        AppTokens.s16,
        AppTokens.s20,
        40,
      ),
      itemCount: projects.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.s10),
        child: _ProjectCard(
          project: projects[i],
          canManage: canManage,
          onEdit: () => onEdit(projects[i]),
          onDelete: () => onDelete(projects[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  String get _dateStr {
    try {
      final d = DateTime.parse(project.createdAt);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${m[d.month - 1]} ${d.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => NavigationHelper.instance.pushTasks(project.id),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTokens.border),
          ),
          padding: const EdgeInsets.all(AppTokens.s14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTokens.brandSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  size: 20,
                  color: AppTokens.brand,
                ),
              ),
              SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: AppTokens.titleMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppTokens.s4),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.check_circle_outline_rounded,
                          label: '${project.count?.tasks ?? 0} tasks',
                        ),
                        if (_dateStr.isNotEmpty) ...[
                          SizedBox(width: AppTokens.s8),
                          _MetaChip(
                            icon: Icons.today_outlined,
                            label: _dateStr,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (canManage) ...[
                SizedBox(width: AppTokens.s8),
                AppActionButton(
                  icon: Icons.edit_rounded,
                  color: AppTokens.brand,
                  onTap: onEdit,
                ),
                SizedBox(width: AppTokens.s6),
                AppActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: AppTokens.danger,
                  onTap: onDelete,
                ),
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTokens.textHint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final List<TeamMemberEntity> members;
  final bool canInvite;

  /// Returns true if the current user is allowed to remove [target].
  final bool Function(TeamMemberEntity target) canRemoveMember;

  final VoidCallback onInvite;
  final ValueChanged<String> onRemoveMember;

  const _MembersTab({
    required this.members,
    required this.canInvite,
    required this.canRemoveMember,
    required this.onInvite,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return AppEmptyState(
        icon: Icons.group_outlined,
        iconColor: AppTokens.success,
        iconSurface: AppTokens.successSurface,
        title: 'No members yet',
        subtitle: 'Invite people to collaborate on this team',
        actionLabel: canInvite ? 'Invite someone' : null,
        actionIcon: canInvite ? Icons.person_add_outlined : null,
        onAction: canInvite ? onInvite : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s20,
        AppTokens.s16,
        AppTokens.s20,
        40,
      ),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final member = members[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s10),
          child: _MemberCard(
            member: member,
            canRemove: canRemoveMember(member),
            onRemove: () => _confirmRemove(context, member),
          ),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, TeamMemberEntity member) {
    final name = member.user?.name ?? 'this member';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _RemoveMemberSheet(
        memberName: name,
        onConfirm: () => onRemoveMember(member.id),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final TeamMemberEntity member;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberCard({
    required this.member,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final name = member.user?.name ?? '';
    final email = member.user?.email ?? '';
    final role = member.role.name;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s14,
        vertical: AppTokens.s12,
      ),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, size: 40),
          SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTokens.titleMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty) ...[
                  SizedBox(height: AppTokens.s4),
                  Text(
                    email,
                    style: AppTokens.labelXs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppTokens.s8),
          _RoleBadge(role: role),
          if (canRemove) ...[
            SizedBox(width: AppTokens.s6),
            AppActionButton(
              icon: Icons.person_remove_outlined,
              color: AppTokens.danger,
              onTap: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Confirmation bottom sheet before removing a member.
class _RemoveMemberSheet extends StatelessWidget {
  final String memberName;
  final VoidCallback onConfirm;

  const _RemoveMemberSheet({required this.memberName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTokens.s16),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(AppTokens.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTokens.dangerSurface,
              borderRadius: BorderRadius.circular(AppTokens.r14),
            ),
            child: Icon(
              Icons.person_remove_outlined,
              color: AppTokens.danger,
              size: 22,
            ),
          ),
          SizedBox(height: AppTokens.s16),
          Text(
            'Remove member',
            style: AppTokens.displayLg.copyWith(fontSize: 18),
          ),
          SizedBox(height: AppTokens.s8),
          Text(
            'Remove $memberName from this team? They will lose access to all projects.',
            style: AppTokens.labelXs.copyWith(fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTokens.s24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTokens.s14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTokens.s12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTokens.s14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.danger,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Remove',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppTokens.s8,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  ({String label, Color color, Color surface}) get _style =>
      switch (role.toUpperCase()) {
        'OWNER' => (
          label: 'Owner',
          color: AppTokens.brand,
          surface: AppTokens.brandSurface,
        ),
        'ADMIN' => (
          label: 'Admin',
          color: AppTokens.warning,
          surface: AppTokens.warningSurface,
        ),
        'MEMBER' => (
          label: 'Member',
          color: AppTokens.success,
          surface: AppTokens.successSurface,
        ),
        _ => (
          label: 'Viewer',
          color: AppTokens.textSecondary,
          surface: AppTokens.surfaceAlt,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        s.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: s.color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppTokens.textHint),
        SizedBox(width: 4),
        Text(label, style: AppTokens.labelXs),
      ],
    );
  }
}
