import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/teams_providers.dart';
import '../providers/teams_state_notifier.dart';
import '../widget/create_team_model.dart';
import '../widget/delete_team_model.dart';
import '../widget/edit_team_model.dart';
import '../widget/team_card.dart';

class TeamsPage extends HookConsumerWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsState = ref.watch(teamsStateNotifierProvider);
    final showCreate = useState(false);
    final editingTeam = useState<TeamEntity?>(null);
    final deletingTeam = useState<TeamEntity?>(null);
    final editNameCtrl = useTextEditingController();
    final editDescCtrl = useTextEditingController();
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      searchCtrl.addListener(() => searchQuery.value = searchCtrl.text);
      return null;
    }, []);

    // ── Error snackbars ────────────────────────────────────────────────────
    void showError(Object e) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    ref.listen<AsyncValue<void>>(
      createTeamControllerProvider,
      (_, next) => next.whenOrNull(error: (e, _) => showError(e)),
    );
    ref.listen<AsyncValue<void>>(
      updateTeamControllerProvider,
      (_, next) => next.whenOrNull(error: (e, _) => showError(e)),
    );
    ref.listen<AsyncValue<void>>(
      deleteTeamControllerProvider,
      (_, next) => next.whenOrNull(error: (e, _) => showError(e)),
    );

    // ── Handlers ───────────────────────────────────────────────────────────
    Future<void> saveTeam() async {
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

    // ── Filtered list ──────────────────────────────────────────────────────
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

    // ── Body ───────────────────────────────────────────────────────────────
    Widget body() {
      if (teamsState.status == TeamsStatus.unknown) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.lg),
              Text('Loading teams…', style: AppTextStyles.bodyMd),
            ],
          ),
        );
      }

      if (teamsState.status == TeamsStatus.error) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xxxl),
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.danger,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Failed to load teams',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  teamsState.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(teamsStateNotifierProvider.notifier).loadTeams(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      }

      return CustomScrollView(
        slivers: [
          // ── Page header + search + stats ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxxl,
                AppSpacing.xxxl,
                AppSpacing.xxxl,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PageHeader(
                    teamCount: allTeams.length,
                    onCreateTap: () => showCreate.value = true,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SearchBar(controller: searchCtrl),
                  const SizedBox(height: AppSpacing.lg),
                  _StatsRow(teams: allTeams),
                  const SizedBox(height: AppSpacing.xxl),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // ── Empty state ──────────────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                hasSearch: searchQuery.value.isNotEmpty,
                onCreateTap: () => showCreate.value = true,
              ),
            )
          // ── Teams grid ───────────────────────────────────────────────
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxxl,
                0,
                AppSpacing.xxxl,
                AppSpacing.xxxl,
              ),
              sliver: SliverLayoutBuilder(
                builder: (ctx, constraints) {
                  final cols = constraints.crossAxisExtent > 900
                      ? 3
                      : constraints.crossAxisExtent > 600
                      ? 2
                      : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: AppSpacing.lg,
                      mainAxisSpacing: AppSpacing.lg,
                      childAspectRatio: cols == 1 ? 2.2 : 1.9,
                    ),
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final team = filtered[i];
                      return TeamCard(
                        team: team,
                        onTap: () {
                          // context.go('/teams/${team.id}');
                          NavigationHelper.instance.pushTeamDetails(team.id);
                        },
                        onEdit: () {
                          editingTeam.value = team;
                          editNameCtrl.text = team.name;
                          editDescCtrl.text = team.description ?? '';
                        },
                        onDelete: () => deletingTeam.value = team,
                      );
                    }, childCount: filtered.length),
                  );
                },
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          body(),

          if (showCreate.value)
            CreateTeamModal(onClose: () => showCreate.value = false),

          if (editingTeam.value != null)
            EditTeamModal(
              nameController: editNameCtrl,
              descController: editDescCtrl,
              onCancel: () => editingTeam.value = null,
              onSave: saveTeam,
            ),

          if (deletingTeam.value != null)
            DeleteTeamModal(
              teamName: deletingTeam.value!.name,
              onCancel: () => deletingTeam.value = null,
              onConfirm: confirmDelete,
            ),
        ],
      ),
    );
  }
}

// ─── Local widgets ─────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final int teamCount;
  final VoidCallback onCreateTap;

  const _PageHeader({required this.teamCount, required this.onCreateTap});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtle accent mark
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('Teams', style: AppTextStyles.heading1),
            const SizedBox(height: 4),
            const Text(
              'Manage your teams and members',
              style: AppTextStyles.bodyMd,
            ),
          ],
        ),
      ),
      ElevatedButton.icon(
        onPressed: onCreateTap,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Create Team'),
      ),
    ],
  );
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: 'Search teams…',
      prefixIcon: const Icon(
        Icons.search_rounded,
        size: 18,
        color: AppColors.textTertiary,
      ),
      suffixIcon: ValueListenableBuilder(
        valueListenable: controller,
        builder: (_, val, __) => val.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                onPressed: controller.clear,
              )
            : const SizedBox.shrink(),
      ),
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final List<TeamEntity> teams;

  const _StatsRow({required this.teams});

  @override
  Widget build(BuildContext context) {
    final memberCount = teams.fold<int>(0, (s, t) => s + t.members.length);
    final projectCount = teams.fold<int>(0, (s, t) => s + t.projects.length);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatPill(
          icon: Icons.groups_outlined,
          label: '${teams.length} team${teams.length == 1 ? '' : 's'}',
        ),
        _StatPill(
          icon: Icons.people_outline,
          label: '$memberCount member${memberCount == 1 ? '' : 's'}',
        ),
        _StatPill(
          icon: Icons.folder_outlined,
          label: '$projectCount project${projectCount == 1 ? '' : 's'}',
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySm),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onCreateTap;

  const _EmptyState({required this.hasSearch, required this.onCreateTap});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hasSearch ? 'No teams match your search' : 'No teams yet',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasSearch
                ? 'Try a different keyword'
                : 'Create your first team to get started',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
          if (!hasSearch) ...[
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Create Your First Team'),
            ),
          ],
        ],
      ),
    ),
  );
}
