import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/teams_providers.dart';
import 'model_scaffold.dart';

class CreateTeamModal extends HookConsumerWidget {
  final VoidCallback onClose;

  const CreateTeamModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final controllerState = ref.watch(createTeamControllerProvider);
    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      if (nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Team name is required')));
        return;
      }
      await ref
          .read(createTeamControllerProvider.notifier)
          .createTeam(nameCtrl.text.trim());

      // Only close if no error occurred
      if (ref.read(createTeamControllerProvider) is! AsyncError) {
        onClose();
      }
    }

    return ModalScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Team',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Team name',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onSubmitted: (_) => submit(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onClose, child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
