import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../domain/repositories/workspaces_repository.dart';
import 'workspaces_providers.dart';
import 'stats_providers.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../teams/presentation/providers/teams_providers.dart';

class WorkspaceController extends StateNotifier<AsyncValue<void>> {
  final WorkspacesRepository repository;
  final Ref ref;

  WorkspaceController({
    required this.repository,
    required this.ref,
  }) : super(const AsyncData(null));

  Future<bool> switchWorkspace(String workspaceId) async {
    state = const AsyncLoading();
    final oldWorkspace = ref.read(authStateNotifierProvider).user?.activeWorkspaceId;
    final result = await repository.switchWorkspace(workspaceId);
    
    return await result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) async {
        state = const AsyncData(null);
        
        // Refresh session (which fetches current user and their memberships)
        await ref.read(authStateNotifierProvider.notifier).refreshUserSession();
        
        // Invalidate workspaces list and details
        ref.invalidate(workspacesListProvider);
        ref.invalidate(dashboardStatsProvider);
        
        // Invalidate my tasks
        ref.invalidate(myTasksProvider);
        
        // Invalidate notifications
        ref.invalidate(unreadNotificationsCountProvider);
        ref.invalidate(notificationsListProvider);
        
        // Invalidate task state
        ref.invalidate(taskStateNotifierProvider);
        
        // Reload teams (which automatically updates projects list)
        await ref.read(teamsStateNotifierProvider.notifier).loadTeams();
        
        return true;
      },
    );
  }

  Future<bool> createWorkspace(String name, String color) async {
    state = const AsyncLoading();
    final result = await repository.createWorkspace(name: name, color: color);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (workspace) {
        state = const AsyncData(null);
        ref.invalidate(workspacesListProvider);
        return true;
      },
    );
  }

  Future<bool> updateWorkspace(String id, String name, String color) async {
    state = const AsyncLoading();
    final result = await repository.updateWorkspace(id: id, name: name, color: color);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (workspace) {
        state = const AsyncData(null);
        ref.invalidate(workspacesListProvider);
        return true;
      },
    );
  }

  Future<bool> deleteWorkspace(String id) async {
    state = const AsyncLoading();
    final result = await repository.deleteWorkspace(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(workspacesListProvider);
        return true;
      },
    );
  }

  Future<bool> addMember(String workspaceId, String email, String role) async {
    state = const AsyncLoading();
    final result = await repository.addWorkspaceMember(workspaceId, email: email, role: role);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (member) {
        state = const AsyncData(null);
        ref.invalidate(workspaceMembersProvider(workspaceId));
        return true;
      },
    );
  }

  Future<bool> updateMemberRole(String workspaceId, String memberId, String role) async {
    state = const AsyncLoading();
    final result = await repository.updateWorkspaceMemberRole(workspaceId, memberId: memberId, role: role);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (member) {
        state = const AsyncData(null);
        ref.invalidate(workspaceMembersProvider(workspaceId));
        return true;
      },
    );
  }

  Future<bool> removeMember(String workspaceId, String memberId) async {
    state = const AsyncLoading();
    final result = await repository.removeWorkspaceMember(workspaceId, memberId);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(workspaceMembersProvider(workspaceId));
        return true;
      },
    );
  }
}

final workspaceControllerProvider = StateNotifierProvider<WorkspaceController, AsyncValue<void>>((ref) {
  return WorkspaceController(
    repository: ref.watch(workspacesRepositoryProvider),
    ref: ref,
  );
});
