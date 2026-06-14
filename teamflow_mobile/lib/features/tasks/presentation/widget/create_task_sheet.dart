import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/features/tasks/presentation/providers/task_providers.dart';

import '../../../../core/ui/app_ui.dart';
import '../../../projects/domain/entitties/project_entity.dart';

class CreateTaskSheet extends HookConsumerWidget {
  final String projectId;

  const CreateTaskSheet({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleCtrl = useTextEditingController();
    final titleError = useState<String?>(null);

    final controllerState = ref.watch(createTaskControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final title = titleCtrl.text.trim();

      if (title.isEmpty) {
        titleError.value = 'Task title is required';
        return;
      }

      titleError.value = null;

      await ref
          .read(createTaskControllerProvider.notifier)
          .createTask(projectId: projectId, title: title);

      if (ref.read(createTaskControllerProvider) is! AsyncError) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return AppSheetShell(
      title: 'New Task',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetLabel('Task Title'),

          AppSheetInput(
            controller: titleCtrl,
            hint: 'e.g. Mobile Redesign',
            errorText: titleError.value,
            autofocus: true,
            onChanged: (_) => titleError.value = null,
            onSubmitted: (_) => submit(),
          ),

          const SizedBox(height: 18),

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
