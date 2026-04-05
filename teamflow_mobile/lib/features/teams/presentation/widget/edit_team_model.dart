import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/teams_providers.dart';
import 'model_scaffold.dart';

class EditTeamModal extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditTeamModal({
    super.key,
    required this.nameController,
    required this.descController,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
    ref.watch(updateTeamControllerProvider) is AsyncLoading;

    return ModalScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit Team',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Team Name',
              border: OutlineInputBorder(),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Description',
              border: OutlineInputBorder(),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : onSave,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB)),
                child: isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Save',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}