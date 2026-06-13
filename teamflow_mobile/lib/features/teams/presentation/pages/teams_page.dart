import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/ui/app_tokens.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../auth/presentation/widgets/logout_modal.dart';
import '../../domain/entities/team_entity.dart';
import '../providers/teams_providers.dart';
import '../providers/teams_state_notifier.dart';
import '../widget/create_team_model.dart';
import '../widget/delete_team_model.dart';
import '../widget/edit_team_model.dart';

class TeamsPage extends HookConsumerWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsState = ref.watch(teamsStateNotifierProvider);
    final currentUserId = ref.watch(authStateNotifierProvider).user?.id ?? '';

    final editingTeam = useState<TeamEntity?>(null);
    final deletingTeam = useState<TeamEntity?>(null);
    final editNameCtrl = useTextEditingController();
    final editDescCtrl = useTextEditingController();
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final searchFocused = useState(false);

    useEffect(() {
      Future.microtask(
        () => ref.read(teamsStateNotifierProvider.notifier).loadTeams(),
      );
      void onSearch() => searchQuery.value = searchCtrl.text;
      searchCtrl.addListener(onSearch);
      return () => searchCtrl.removeListener(onSearch);
    }, []);

    for (final p in [
      createTeamControllerProvider,
      updateTeamControllerProvider,
      deleteTeamControllerProvider,
    ]) {
      ref.listen<AsyncValue<void>>(
        p,
        (_, next) => next.whenOrNull(
          error: (e, _) => showAppSnackBar(context, e.toString()),
        ),
      );
    }

    void showCreate() {
      HapticFeedback.lightImpact();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CreateTeamSheet(),
      );
    }

    Future<void> saveEdit() async {
      final team = editingTeam.value;
      if (team == null) return;
      await ref
          .read(updateTeamControllerProvider.notifier)
          .updateTeam(id: team.id, name: editNameCtrl.text.trim());
      editingTeam.value = null;
    }

    Future<void> confirmDelete() async {
      final team = deletingTeam.value;
      if (team == null) return;
      await ref.read(deleteTeamControllerProvider.notifier).deleteTeam(team.id);
      deletingTeam.value = null;
    }

    final allTeams = teamsState.teams;
    final filtered = searchQuery.value.isEmpty
        ? allTeams
        : allTeams
              .where(
                (t) => t.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: Stack(
        children: [
          _Body(
            teamsState: teamsState,
            allTeams: allTeams,
            filtered: filtered,
            searchCtrl: searchCtrl,
            searchQuery: searchQuery.value,
            searchFocused: searchFocused.value,
            currentUserId: currentUserId,
            onCreateTap: showCreate,
            onLogoutTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const LogoutSheet(),
            ),
            onEdit: (team) {
              editingTeam.value = team;
              editNameCtrl.text = team.name;
              editDescCtrl.text = team.description ?? '';
            },
            onDelete: (team) => deletingTeam.value = team,
            onRetry: () =>
                ref.read(teamsStateNotifierProvider.notifier).loadTeams(),
            onSearchFocusChanged: (v) => searchFocused.value = v,
          ),

          if (editingTeam.value != null)
            EditTeamModal(
              nameController: editNameCtrl,
              descController: editDescCtrl,
              onCancel: () => editingTeam.value = null,
              onSave: saveEdit,
            ),

          if (deletingTeam.value != null)
            DeleteTeamModal(
              teamName: deletingTeam.value!.name,
              onCancel: () => deletingTeam.value = null,
              onConfirm: confirmDelete,
            ),
        ],
      ),
      floatingActionButton: _Fab(onTap: showCreate),
    );
  }
}

class _Body extends StatelessWidget {
  final TeamsState teamsState;
  final List<TeamEntity> allTeams;
  final List<TeamEntity> filtered;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final bool searchFocused;
  final String currentUserId;
  final VoidCallback onCreateTap;
  final VoidCallback onLogoutTap;
  final ValueChanged<TeamEntity> onEdit;
  final ValueChanged<TeamEntity> onDelete;
  final VoidCallback onRetry;
  final ValueChanged<bool> onSearchFocusChanged;

  const _Body({
    required this.teamsState,
    required this.allTeams,
    required this.filtered,
    required this.searchCtrl,
    required this.searchQuery,
    required this.searchFocused,
    required this.currentUserId,
    required this.onCreateTap,
    required this.onLogoutTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRetry,
    required this.onSearchFocusChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (teamsState.status == TeamsStatus.unknown) {
      return const AppLoadingView(message: 'Loading teams…');
    }
    if (teamsState.status == TeamsStatus.error) {
      return AppErrorView(
        title: 'Failed to load teams',
        message: teamsState.errorMessage ?? 'Something went wrong.',
        onRetry: onRetry,
      );
    }

    final top = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: AppTokens.surface,
            padding: EdgeInsets.fromLTRB(
              AppTokens.s20,
              top + AppTokens.s16,
              AppTokens.s20,
              AppTokens.s20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Teams', style: AppTokens.displayLg),
                          const SizedBox(height: AppTokens.s4),
                          Text(
                            '${allTeams.length} workspace${allTeams.length == 1 ? '' : 's'} you belong to',
                            style: AppTokens.bodySm,
                          ),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.mail_outline_rounded,
                      onTap: () => NavigationHelper.instance.pushInvitations(),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    AppIconButton(
                      icon: Icons.logout_rounded,
                      onTap: onLogoutTap,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s20),
                _StatsOverviewCard(teams: allTeams),
                const SizedBox(height: AppTokens.s20),
                _SearchBar(
                  controller: searchCtrl,
                  onFocusChanged: onSearchFocusChanged,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(height: 1, color: const Color(0xFFF1F5F9)),
        ),

        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyState(
              icon: searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.groups_outlined,
              iconColor: searchQuery.isNotEmpty
                  ? AppTokens.textSecondary
                  : AppTokens.brand,
              iconSurface: searchQuery.isNotEmpty
                  ? AppTokens.surfaceAlt
                  : AppTokens.brandSurface,
              title: searchQuery.isNotEmpty
                  ? 'No results found'
                  : 'No teams yet',
              subtitle: searchQuery.isNotEmpty
                  ? 'Try a different keyword'
                  : 'Create your first team to start collaborating',
              actionLabel: searchQuery.isNotEmpty ? null : 'Create a team',
              actionIcon: searchQuery.isNotEmpty ? null : Icons.add_rounded,
              onAction: searchQuery.isNotEmpty ? null : onCreateTap,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s20,
              AppTokens.s16,
              AppTokens.s20,
              120,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.s10),
                  child: TeamCard(
                    team: filtered[i],
                    currentUserId: currentUserId,
                    onTap: () => NavigationHelper.instance.pushTeamDetails(
                      filtered[i].id,
                    ),
                    onEdit: () => onEdit(filtered[i]),
                    onDelete: () => onDelete(filtered[i]),
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsOverviewCard extends StatelessWidget {
  final List<TeamEntity> teams;

  const _StatsOverviewCard({required this.teams});

  @override
  Widget build(BuildContext context) {
    final memberCount = teams.fold<int>(0, (sum, t) => sum + t.members.length);
    final projectCount = teams.fold<int>(
      0,
      (sum, t) => sum + t.projects.length,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(value: teams.length.toString(), label: 'Teams'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _Metric(value: memberCount.toString(), label: 'Members'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _Metric(value: projectCount.toString(), label: 'Projects'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).dividerColor.withValues(alpha: .15),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<bool> onFocusChanged;

  const _SearchBar({required this.controller, required this.onFocusChanged});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _focus = FocusNode();
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _active = _focus.hasFocus);
      widget.onFocusChanged(_focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppTokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTokens.r14),
        border: Border.all(
          color: _active
              ? AppTokens.brand.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppTokens.s14),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: _active ? AppTokens.brand : AppTokens.textHint,
          ),
          const SizedBox(width: AppTokens.s10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTokens.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Search teams…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTokens.textHint,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: AppTokens.s14),
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => widget.controller.clear(),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s12),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppTokens.textHint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: AppTokens.s14),
        ],
      ),
    );
  }
}

class TeamCard extends StatefulWidget {
  final TeamEntity team;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamCard({
    super.key,
    required this.team,
    required this.currentUserId,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TeamCard> createState() => TeamCardState();
}

class TeamCardState extends State<TeamCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final isOwner = team.ownerId == widget.currentUserId;

    final memberLabel =
        '${team.members.length} member${team.members.length == 1 ? '' : 's'}';
    final projectLabel =
        '${team.projects.length} project${team.projects.length == 1 ? '' : 's'}';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.r16),
            border: Border.all(color: AppTokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppTokens.s14),
          child: Row(
            children: [
              AppAvatar(name: team.name, size: 46),

              const SizedBox(width: AppTokens.s12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: AppTokens.titleMd,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOwner)
                          Container(
                            margin: const EdgeInsets.only(left: AppTokens.s6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.s6,
                              vertical: AppTokens.s2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTokens.brandSurface,
                              borderRadius: BorderRadius.circular(AppTokens.r8),
                            ),
                            child: const Text(
                              'Owner',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTokens.brand,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s6),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.people_outline_rounded,
                          label: memberLabel,
                        ),
                        const SizedBox(width: AppTokens.s10),
                        _MetaChip(
                          icon: Icons.folder_outlined,
                          label: projectLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppTokens.s8),

              if (isOwner) ...[
                AppActionButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: AppTokens.s6),
                AppActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: AppTokens.danger,
                  onTap: widget.onDelete,
                ),
                const SizedBox(width: AppTokens.s6),
              ],
              const Icon(
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

class _Fab extends StatelessWidget {
  final VoidCallback onTap;

  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: AppTokens.brand,
      elevation: 0,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      label: const Text(
        'New Team',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

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
        const SizedBox(width: 3),
        Text(label, style: AppTokens.labelXs),
      ],
    );
  }
}
