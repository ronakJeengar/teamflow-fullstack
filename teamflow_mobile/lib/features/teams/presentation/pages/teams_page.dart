import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';
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

    // ── Listen for mutation errors and show snackbars ──────────────────────
    ref.listen<AsyncValue<void>>(createTeamControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

    ref.listen<AsyncValue<void>>(updateTeamControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

    ref.listen<AsyncValue<void>>(deleteTeamControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()))),
      );
    });

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

    // ── Build ──────────────────────────────────────────────────────────────
    Widget body() {
      // unknown = initial load in progress
      if (teamsState.status == TeamsStatus.unknown) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF2563EB)),
              SizedBox(height: 16),
              Text('Loading teams...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      if (teamsState.status == TeamsStatus.error) {
        return Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Teams',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    teamsState.errorMessage ?? 'Something went wrong.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(teamsStateNotifierProvider.notifier)
                        .loadTeams(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final teams = teamsState.teams;

      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teams',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your teams and members',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => showCreate.value = true,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create Team',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Empty state ──────────────────────────────────────────────
            if (teams.isEmpty)
              Expanded(
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No teams yet',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => showCreate.value = true,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                            ),
                            child: const Text(
                              'Create Your First Team',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            // ── Teams grid ───────────────────────────────────────────────
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth > 1024 ? 3 : 2;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: teams.length,
                      itemBuilder: (_, i) {
                        final team = teams[i];
                        return TeamCard(
                          team: team,
                          onTap: () => context.go('/teams/${team.id}'),
                          onEdit: () {
                            editingTeam.value = team;
                            editNameCtrl.text = team.name;
                            editDescCtrl.text = team.description ?? '';
                          },
                          onDelete: () => deletingTeam.value = team,
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
