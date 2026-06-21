import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../../domain/entitties/task_entity.dart';
import '../providers/task_providers.dart';

class EditTaskSheet extends HookConsumerWidget {
  final String projectId;
  final TaskEntity task;

  const EditTaskSheet({super.key, required this.task, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleCtrl = useTextEditingController(text: task.title);
    final titleError = useState<String?>(null);

    final controllerState = ref.watch(updateTaskControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final title = titleCtrl.text.trim();

      if (title.isEmpty) {
        titleError.value = 'Task title is required';
        return;
      }

      if (title == task.title) {
        Navigator.of(context).pop();
        return;
      }

      titleError.value = null;

      await ref
          .read(updateTaskControllerProvider.notifier)
          .updateTask(taskId: task.id, title: title, projectId: projectId);

      if (ref.read(updateTaskControllerProvider) is! AsyncError) {
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
            controller: titleCtrl,
            hint: task.title,
            errorText: titleError.value,
            autofocus: true,
            onChanged: (_) => titleError.value = null,
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
