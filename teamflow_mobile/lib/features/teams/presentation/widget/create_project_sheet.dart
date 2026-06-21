import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../../../projects/domain/entitties/project_entity.dart';
import '../providers/team_details_providers.dart';

class CreateProjectSheet extends HookConsumerWidget {
  final String teamId;

  const CreateProjectSheet({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final nameError = useState<String?>(null);

    final controllerState = ref.watch(createProjectControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final name = nameCtrl.text.trim();

      if (name.isEmpty) {
        nameError.value = 'Project name is required';
        return;
      }

      nameError.value = null;

      await ref
          .read(createProjectControllerProvider.notifier)
          .createProject(teamId: teamId, name: name);

      if (ref.read(createProjectControllerProvider) is! AsyncError) {
        Navigator.of(context).pop();
      }
    }

    return AppSheetShell(
      title: 'New project',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetLabel('Project name'),

          AppSheetInput(
            controller: nameCtrl,
            hint: 'e.g. Mobile Redesign',
            errorText: nameError.value,
            autofocus: true,
            onChanged: (_) => nameError.value = null,
            onSubmitted: (_) => submit(),
          ),

          SizedBox(height: 16),

          AppSheetActions(
            confirmLabel: 'Create',
            isLoading: isLoading,
            onCancel: isLoading ? null : () => Navigator.of(context).pop(),
            onConfirm: submit,
          ),
        ],
      ),
    );
  }
}
