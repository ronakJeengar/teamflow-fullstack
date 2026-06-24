import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/workspaces_repository.dart';
import '../../data/models/workspace_model.dart';

final workspacesRepositoryProvider = Provider<WorkspacesRepository>((ref) {
  return sl<WorkspacesRepository>();
});

final workspacesListProvider = FutureProvider<List<WorkspaceModel>>((ref) async {
  final repository = ref.watch(workspacesRepositoryProvider);
  final result = await repository.getWorkspaces();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (workspaces) => workspaces,
  );
});
