import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../projects/domain/entitties/project_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/team_member_entity.dart';
import '../providers/team_detail_state_notifier.dart';
import '../providers/team_details_providers.dart';

// ─── Inline theme constants ───────────────────────────────────────────────────

abstract class _C {
  static const primary = Color(0xFF4F6EF7);
  static const primaryLight = Color(0xFFEEF1FE);
  static const surface = Color(0xFFF8F9FC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8EAF0);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEE2E2);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFF0FDF4);
  static const purple = Color(0xFF9333EA);
  static const purpleLight = Color(0xFFFAF5FF);
}

abstract class _S {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

// ─── Provider is declared in team_detail_providers.dart ─────────────────────

// ─── Tab enum ─────────────────────────────────────────────────────────────────

enum _Tab { overview, projects, members }

// ─── Page ─────────────────────────────────────────────────────────────────────

class TeamDetailPage extends ConsumerStatefulWidget {
  final String teamId;

  const TeamDetailPage({super.key, required this.teamId});

  @override
  ConsumerState<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends ConsumerState<TeamDetailPage> {
  _Tab _activeTab = _Tab.overview;
  bool _showInvite = false;
  bool _showNewProject = false;
  ProjectEntity? _editingProject;
  ProjectEntity? _deletingProject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(teamDetailStateNotifierProvider.notifier)
          .loadTeamDetail(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamDetailStateNotifierProvider);

    return Scaffold(
      backgroundColor: _C.surface,
      body: switch (state.status) {
        TeamDetailStatus.unknown => const Center(
          child: CircularProgressIndicator(),
        ),
        TeamDetailStatus.error => _ErrorView(
          message: state.errorMessage ?? 'Something went wrong',
        ),
        TeamDetailStatus.loaded => _buildLoaded(state),
      },
    );
  }

  Widget _buildLoaded(TeamDetailState state) {
    final team = state.team!;
    final projects = state.projects;
    final members = state.members;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(_S.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      teamName: team.name,
                      onBack: () => Navigator.of(context).pop(),
                      onInvite: () => setState(() => _showInvite = true),
                    ),
                    const SizedBox(height: _S.xxl),
                    _StatCards(
                      projectCount: projects.length,
                      memberCount: members.length,
                      totalTasks: projects.fold(
                        0,
                        (s, p) => s + (p.count?.tasks ?? 0),
                      ),
                    ),
                    const SizedBox(height: _S.xxl),
                    _TabBar(
                      active: _activeTab,
                      projectCount: projects.length,
                      memberCount: members.length,
                      onChanged: (t) => setState(() => _activeTab = t),
                    ),
                    const SizedBox(height: _S.xxl),
                    _TabBody(
                      tab: _activeTab,
                      team: team,
                      projects: projects,
                      members: members,
                      onNewProject: () =>
                          setState(() => _showNewProject = true),
                      onEditProject: (p) => setState(() => _editingProject = p),
                      onDeleteProject: (p) =>
                          setState(() => _deletingProject = p),
                      onInvite: () => setState(() => _showInvite = true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Modals ──────────────────────────────────────────────────────────
        if (_showInvite)
          _InviteMemberModal(
            onClose: () => setState(() => _showInvite = false),
            onInvited: (member) {
              ref
                  .read(teamDetailStateNotifierProvider.notifier)
                  .addMember(member);
              setState(() => _showInvite = false);
            },
          ),

        if (_showNewProject)
          _NewProjectModal(
            onClose: () => setState(() => _showNewProject = false),
            onCreated: (project) {
              ref
                  .read(teamDetailStateNotifierProvider.notifier)
                  .addProject(project);
              setState(() => _showNewProject = false);
            },
          ),

        if (_editingProject != null)
          _EditProjectModal(
            project: _editingProject!,
            onClose: () => setState(() => _editingProject = null),
            onSaved: (updated) {
              ref
                  .read(teamDetailStateNotifierProvider.notifier)
                  .replaceProject(updated);
              setState(() => _editingProject = null);
            },
          ),

        if (_deletingProject != null)
          _DeleteProjectModal(
            project: _deletingProject!,
            onClose: () => setState(() => _deletingProject = null),
            onConfirmed: () {
              ref
                  .read(teamDetailStateNotifierProvider.notifier)
                  .removeProject(_deletingProject!.id);
              setState(() => _deletingProject = null);
            },
          ),
      ],
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(_S.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _C.dangerLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 26,
              color: _C.danger,
            ),
          ),
          const SizedBox(height: _S.lg),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: _S.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
        ],
      ),
    ),
  );
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String teamName;
  final VoidCallback onBack;
  final VoidCallback onInvite;

  const _TopBar({
    required this.teamName,
    required this.onBack,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _C.textSecondary,
          ),
        ),
      ),
      const SizedBox(width: _S.md),
      Expanded(
        child: Text(
          teamName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _C.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      ElevatedButton.icon(
        onPressed: onInvite,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _S.lg,
            vertical: _S.md,
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.person_add_outlined, size: 16),
        label: const Text(
          'Invite Members',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    ],
  );
}

// ─── Stat cards ───────────────────────────────────────────────────────────────

class _StatCards extends StatelessWidget {
  final int projectCount;
  final int memberCount;
  final int totalTasks;

  const _StatCards({
    required this.projectCount,
    required this.memberCount,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 360;
      final cards = [
        _StatCard(
          icon: Icons.folder_outlined,
          iconColor: _C.primary,
          iconBg: _C.primaryLight,
          value: '$projectCount',
          label: 'Projects',
        ),
        _StatCard(
          icon: Icons.groups_outlined,
          iconColor: _C.green,
          iconBg: _C.greenLight,
          value: '$memberCount',
          label: 'Members',
        ),
        _StatCard(
          icon: Icons.task_alt_outlined,
          iconColor: _C.purple,
          iconBg: _C.purpleLight,
          value: '$totalTasks',
          label: 'Total Tasks',
        ),
      ];
      if (narrow) {
        return Column(
          children: cards
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: _S.md),
                  child: c,
                ),
              )
              .toList(),
        );
      }
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: _S.sm),
          Expanded(child: cards[1]),
          const SizedBox(width: _S.sm),
          Expanded(child: cards[2]),
        ],
      );
    },
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(_S.lg),
    decoration: BoxDecoration(
      color: iconBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: iconColor.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: _S.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: iconColor.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Tab bar ──────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final _Tab active;
  final int projectCount;
  final int memberCount;
  final ValueChanged<_Tab> onChanged;

  const _TabBar({
    required this.active,
    required this.projectCount,
    required this.memberCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.border),
    ),
    child: Row(
      children: [
        _TabItem(
          icon: Icons.bar_chart_rounded,
          label: 'Overview',
          isActive: active == _Tab.overview,
          onTap: () => onChanged(_Tab.overview),
        ),
        _TabItem(
          icon: Icons.folder_outlined,
          label: 'Projects ($projectCount)',
          isActive: active == _Tab.projects,
          onTap: () => onChanged(_Tab.projects),
        ),
        _TabItem(
          icon: Icons.people_outline_rounded,
          label: 'Members ($memberCount)',
          isActive: active == _Tab.members,
          onTap: () => onChanged(_Tab.members),
        ),
      ],
    ),
  );
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? _C.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? const Border(bottom: BorderSide(color: _C.primary, width: 2))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? _C.primary : _C.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? _C.primary : _C.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Tab body dispatcher ──────────────────────────────────────────────────────

class _TabBody extends StatelessWidget {
  final _Tab tab;
  final TeamEntity team;
  final List<ProjectEntity> projects;
  final List<TeamMemberEntity> members;
  final VoidCallback onNewProject;
  final ValueChanged<ProjectEntity> onEditProject;
  final ValueChanged<ProjectEntity> onDeleteProject;
  final VoidCallback onInvite;

  const _TabBody({
    required this.tab,
    required this.team,
    required this.projects,
    required this.members,
    required this.onNewProject,
    required this.onEditProject,
    required this.onDeleteProject,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) => switch (tab) {
    _Tab.overview => _OverviewTab(
      team: team,
      projects: projects,
      members: members,
      onNewProject: onNewProject,
      onInvite: onInvite,
    ),
    _Tab.projects => _ProjectsTab(
      projects: projects,
      onNewProject: onNewProject,
      onEdit: onEditProject,
      onDelete: onDeleteProject,
    ),
    _Tab.members => _MembersTab(members: members, onInvite: onInvite),
  };
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final TeamEntity team;
  final List<ProjectEntity> projects;
  final List<TeamMemberEntity> members;
  final VoidCallback onNewProject;
  final VoidCallback onInvite;

  const _OverviewTab({
    required this.team,
    required this.projects,
    required this.members,
    required this.onNewProject,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final recentProjects = projects.take(3).toList();
    final recentMembers = members.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(_S.xxl),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: _S.sm),
          Text(
            "Welcome to ${team.name}! Here's a quick overview of your team's activity.",
            style: const TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
          const SizedBox(height: _S.xxl),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 600;
              final panels = [
                _OverviewPanel(
                  icon: Icons.folder_outlined,
                  iconColor: _C.primary,
                  title: 'Recent Projects',
                  isEmpty: recentProjects.isEmpty,
                  emptyLabel: 'No projects yet',
                  onEmptyAction: onNewProject,
                  child: Column(
                    children: recentProjects
                        .map((p) => _ProjectOverviewRow(project: p))
                        .toList(),
                  ),
                ),
                _OverviewPanel(
                  icon: Icons.people_outline_rounded,
                  iconColor: _C.green,
                  title: 'Team Members',
                  isEmpty: recentMembers.isEmpty,
                  emptyLabel: 'No members yet',
                  onEmptyAction: onInvite,
                  child: Column(
                    children: recentMembers
                        .map((m) => _MemberOverviewRow(member: m))
                        .toList(),
                  ),
                ),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: panels[0]),
                    const SizedBox(width: _S.lg),
                    Expanded(child: panels[1]),
                  ],
                );
              }
              return Column(
                children: [
                  panels[0],
                  const SizedBox(height: _S.lg),
                  panels[1],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isEmpty;
  final String emptyLabel;
  final VoidCallback onEmptyAction;
  final Widget child;

  const _OverviewPanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isEmpty,
    required this.emptyLabel,
    required this.onEmptyAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(_S.lg),
    decoration: BoxDecoration(
      color: _C.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: _S.sm),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _S.lg),
        if (isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                emptyLabel,
                style: const TextStyle(fontSize: 14, color: _C.textSecondary),
              ),
            ),
          )
        else
          child,
      ],
    ),
  );
}

class _ProjectOverviewRow extends StatelessWidget {
  final ProjectEntity project;

  const _ProjectOverviewRow({required this.project});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            project.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
        ),
        Text(
          '${project.count?.tasks ?? 0} tasks',
          style: const TextStyle(fontSize: 12, color: _C.textSecondary),
        ),
      ],
    ),
  );
}

class _MemberOverviewRow extends StatelessWidget {
  final TeamMemberEntity member;

  const _MemberOverviewRow({required this.member});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        _Avatar(name: member.user!.name, size: 32),
        const SizedBox(width: _S.md),
        Expanded(
          child: Text(
            member.user!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: _S.xs),
        _RoleBadge(role: member.role.toString()),
      ],
    ),
  );
}

// ─── Projects tab ─────────────────────────────────────────────────────────────

class _ProjectsTab extends StatelessWidget {
  final List<ProjectEntity> projects;
  final VoidCallback onNewProject;
  final ValueChanged<ProjectEntity> onEdit;
  final ValueChanged<ProjectEntity> onDelete;

  const _ProjectsTab({
    required this.projects,
    required this.onNewProject,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(_S.xxl),
    decoration: BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Team Projects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onNewProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: _S.lg,
                  vertical: _S.md,
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'New Project',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: _S.xxl),
        if (projects.isEmpty)
          _EmptyProjects(onNewProject: onNewProject)
        else
          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final cols = w > 700
                  ? 3
                  : w > 400
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: _S.md,
                  mainAxisSpacing: _S.md,
                  childAspectRatio: cols == 1 ? 2.2 : 1.5,
                ),
                itemCount: projects.length,
                itemBuilder: (_, i) => _ProjectCard(
                  project: projects[i],
                  onEdit: () => onEdit(projects[i]),
                  onDelete: () => onDelete(projects[i]),
                ),
              );
            },
          ),
      ],
    ),
  );
}

class _ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.project.createdAt;
    final createdDate = DateTime.parse(createdAt);

    final dateStr =
        '${createdDate.month.toString().padLeft(2, '0')}/'
        '${createdDate.day.toString().padLeft(2, '0')}/'
        '${createdDate.year}';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(_S.lg),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? _C.primary.withOpacity(0.4) : _C.border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _C.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: _C.primary,
                  ),
                ),
                const Spacer(),
                _ActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit project',
                  color: _C.primary,
                  bgColor: _C.primaryLight,
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: _S.xs),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Delete project',
                  color: _C.danger,
                  bgColor: _C.dangerLight,
                  onTap: widget.onDelete,
                ),
              ],
            ),
            const Spacer(),
            Text(
              widget.project.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: _S.sm),
            Row(
              children: [
                const Icon(
                  Icons.task_outlined,
                  size: 12,
                  color: _C.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.project.count?.tasks ?? 0} tasks',
                  style: const TextStyle(fontSize: 12, color: _C.textSecondary),
                ),
                const Spacer(),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _C.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  final VoidCallback onNewProject;

  const _EmptyProjects({required this.onNewProject});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _C.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.folder_outlined,
              size: 26,
              color: _C.primary,
            ),
          ),
          const SizedBox(height: _S.lg),
          const Text(
            'No projects yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: _S.sm),
          const Text(
            'Create the first project for this team',
            style: TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
          const SizedBox(height: _S.xxl),
          ElevatedButton.icon(
            onPressed: onNewProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: _S.lg,
                vertical: _S.md,
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text(
              'New Project',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Members tab ──────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final List<TeamMemberEntity> members;
  final VoidCallback onInvite;

  const _MembersTab({required this.members, required this.onInvite});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(_S.xxl),
    decoration: BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: _S.lg,
                  vertical: _S.md,
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.person_add_outlined, size: 16),
              label: const Text(
                'Invite Member',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: _S.xxl),
        if (members.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _C.greenLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded,
                      size: 26,
                      color: _C.green,
                    ),
                  ),
                  const SizedBox(height: _S.lg),
                  const Text(
                    'No members yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: _S.sm),
                  const Text(
                    'Invite people to join this team',
                    style: TextStyle(fontSize: 14, color: _C.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final cols = w > 700
                  ? 3
                  : w > 400
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: _S.md,
                  mainAxisSpacing: _S.md,
                  childAspectRatio: cols == 1 ? 3.5 : 2.2,
                ),
                itemCount: members.length,
                itemBuilder: (_, i) => _MemberCard(member: members[i]),
              );
            },
          ),
      ],
    ),
  );
}

class _MemberCard extends StatelessWidget {
  final TeamMemberEntity member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(_S.lg),
    decoration: BoxDecoration(
      color: _C.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.border),
    ),
    child: Row(
      children: [
        _Avatar(name: member.user!.name, size: 44),
        const SizedBox(width: _S.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                member.user!.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (member.user?.email.isNotEmpty ?? false)
                Text(
                  member.user!.email,
                  style: const TextStyle(fontSize: 12, color: _C.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              _RoleBadge(role: member.role.toString()),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, required this.size});

  Color get _bg {
    const colors = [
      Color(0xFF4F6EF7),
      Color(0xFF7C3AED),
      Color(0xFF0D9488),
      Color(0xFFD97706),
      Color(0xFFDB2777),
    ];
    final idx = name.codeUnits.fold<int>(0, (s, c) => s + c) % colors.length;
    return colors[idx];
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(size / 2.8),
    ),
    child: Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isOwner = role.toLowerCase() == 'owner';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOwner ? _C.purpleLight : _C.primaryLight,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isOwner
              ? _C.purple.withOpacity(0.3)
              : _C.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOwner ? _C.purple : _C.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    ),
  );
}

// ─── Modals ───────────────────────────────────────────────────────────────────
//
// Wire onInvited / onCreated / onSaved / onConfirmed to your actual use-cases.
// The notifier mutation (addMember, addProject, etc.) is done in _TeamDetailPageState.

class _InviteMemberModal extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<TeamMemberEntity> onInvited;

  const _InviteMemberModal({required this.onClose, required this.onInvited});

  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Invite Member',
    icon: Icons.person_add_outlined,
    onClose: onClose,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: _S.sm),
        TextField(
          decoration: InputDecoration(
            hintText: 'colleague@company.com',
            hintStyle: const TextStyle(color: _C.textTertiary, fontSize: 14),
            filled: true,
            fillColor: _C.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _S.md,
              vertical: _S.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
          ),
        ),
        const SizedBox(height: _S.xxl),
        // TODO: call your InviteMemberUseCase here; pass result to onInvited.
        _ModalActions(
          confirmLabel: 'Send Invite',
          onCancel: onClose,
          onConfirm: onClose, // replace with actual submit
          confirmColor: _C.primary,
        ),
      ],
    ),
  );
}

class _NewProjectModal extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<ProjectEntity> onCreated;

  const _NewProjectModal({required this.onClose, required this.onCreated});

  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'New Project',
    icon: Icons.folder_outlined,
    onClose: onClose,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: _S.sm),
        TextField(
          decoration: InputDecoration(
            hintText: 'e.g. Mobile Redesign',
            hintStyle: const TextStyle(color: _C.textTertiary, fontSize: 14),
            filled: true,
            fillColor: _C.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _S.md,
              vertical: _S.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
          ),
        ),
        const SizedBox(height: _S.xxl),
        // TODO: call your CreateProjectUseCase here; pass result to onCreated.
        _ModalActions(
          confirmLabel: 'Create Project',
          onCancel: onClose,
          onConfirm: onClose, // replace with actual submit
          confirmColor: _C.primary,
        ),
      ],
    ),
  );
}

class _EditProjectModal extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onClose;
  final ValueChanged<ProjectEntity> onSaved;

  const _EditProjectModal({
    required this.project,
    required this.onClose,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Edit Project',
    icon: Icons.edit_outlined,
    onClose: onClose,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: _S.sm),
        TextField(
          controller: TextEditingController(text: project.name),
          decoration: InputDecoration(
            filled: true,
            fillColor: _C.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _S.md,
              vertical: _S.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
          ),
        ),
        const SizedBox(height: _S.xxl),
        // TODO: call your UpdateProjectUseCase here; pass result to onSaved.
        _ModalActions(
          confirmLabel: 'Save Changes',
          onCancel: onClose,
          onConfirm: onClose, // replace with actual submit
          confirmColor: _C.primary,
        ),
      ],
    ),
  );
}

class _DeleteProjectModal extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onClose;
  final VoidCallback onConfirmed;

  const _DeleteProjectModal({
    required this.project,
    required this.onClose,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Delete Project',
    icon: Icons.delete_outline_rounded,
    iconColor: _C.danger,
    onClose: onClose,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(_S.lg),
          decoration: BoxDecoration(
            color: _C.dangerLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: _C.danger,
                size: 20,
              ),
              const SizedBox(width: _S.md),
              Expanded(
                child: Text(
                  'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
                  style: const TextStyle(fontSize: 13, color: _C.danger),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _S.xxl),
        _ModalActions(
          confirmLabel: 'Delete Project',
          onCancel: onClose,
          onConfirm: onConfirmed,
          confirmColor: _C.danger,
        ),
      ],
    ),
  );
}

// ─── Modal shell ──────────────────────────────────────────────────────────────

class _ModalShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onClose;
  final Widget child;

  const _ModalShell({
    required this.title,
    required this.icon,
    this.iconColor = _C.primary,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onClose,
    child: Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(_S.xxl),
            padding: const EdgeInsets.all(_S.xxl),
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: iconColor),
                    ),
                    const SizedBox(width: _S.md),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: _C.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _S.xxl),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ModalActions extends StatelessWidget {
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const _ModalActions({
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: _C.textSecondary,
            side: const BorderSide(color: _C.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ),
      const SizedBox(width: _S.md),
      Expanded(
        child: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            elevation: 0,
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ),
    ],
  );
}
