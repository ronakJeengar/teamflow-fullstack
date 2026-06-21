import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../providers/teams_providers.dart';

class CreateTeamSheet extends HookConsumerWidget {
  const CreateTeamSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();
    final nameError = useState<String?>(null);
    final controllerState = ref.watch(createTeamControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        nameError.value = 'Team name is required';
        return;
      }
      nameError.value = null;

      final description = descCtrl.text.trim();
      await ref
          .read(createTeamControllerProvider.notifier)
          .createTeam(
            name,
            description: description.isEmpty ? null : description,
          );

      if (ref.read(createTeamControllerProvider) is! AsyncError) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return AppSheetShell(
      title: 'New team',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetLabel('Team name'),
          AppSheetInput(
            controller: nameCtrl,
            hint: 'e.g. Engineering, Design',
            errorText: nameError.value,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => nameError.value = null,
            onSubmitted: (_) => submit(),
          ),

          SizedBox(height: AppSpacing.lg),
          const AppSheetLabel('Description (optional)'),
          AppSheetInput(
            controller: descCtrl,
            hint: 'What does this team work on?',
            maxLines: 3,
            textInputAction: TextInputAction.done,
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
