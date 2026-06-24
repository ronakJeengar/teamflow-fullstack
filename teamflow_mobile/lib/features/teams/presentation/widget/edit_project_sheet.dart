import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../../../projects/domain/entitties/project_entity.dart';
import '../providers/team_details_providers.dart';

class EditProjectSheet extends HookConsumerWidget {
  final String teamId;
  final ProjectEntity project;

  const EditProjectSheet({
    super.key,
    required this.project,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController(text: project.name);
    final nameError = useState<String?>(null);

    final controllerState = ref.watch(updateProjectControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final name = nameCtrl.text.trim();

      if (name.isEmpty) {
        nameError.value = 'Project name is required';
        return;
      }

      if (name == project.name) {
        Navigator.of(context).pop();
        return;
      }

      nameError.value = null;

      await ref
          .read(updateProjectControllerProvider.notifier)
          .updateProject(projectId: project.id, name: name, teamId: teamId);

      if (ref.read(updateProjectControllerProvider) is! AsyncError) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return AppSheetShell(
      title: 'Edit project',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetLabel('Project name'),

          AppSheetInput(
            controller: nameCtrl,
            hint: project.name,
            errorText: nameError.value,
            autofocus: true,
            onChanged: (_) => nameError.value = null,
            onSubmitted: (_) => submit(),
          ),

          SizedBox(height: 16),

          AppSheetActions(
            confirmLabel: 'Save changes',
            isLoading: isLoading,
            onCancel: isLoading ? null : () => Navigator.of(context).pop(),
            onConfirm: submit,
          ),
        ],
      ),
    );
  }
}
