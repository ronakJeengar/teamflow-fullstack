import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/teams_providers.dart';
import 'model_scaffold.dart';

class DeleteTeamModal extends ConsumerWidget {
  final String teamName;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const DeleteTeamModal({
    super.key,
    required this.teamName,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
    ref.watch(deleteTeamControllerProvider) is AsyncLoading;

    return ModalScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delete Team?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626))),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                const TextSpan(text: 'This will permanently delete '),
                TextSpan(
                  text: teamName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' and all its projects.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626)),
                child: isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Delete',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}