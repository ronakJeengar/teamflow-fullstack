import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../providers/providers.dart';

class LogoutSheet extends ConsumerWidget {
  const LogoutSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutControllerProvider);
    final isLoading = logoutState is AsyncLoading;

    Future<void> submit() async {
      await ref.read(logoutControllerProvider.notifier).logout();

      final state = ref.read(logoutControllerProvider);

      if (state is AsyncError) {
        return;
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // close sheet
      }
    }

    return AppSheetShell(
      title: 'Logout',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Are you sure you want to logout? You will be sent back to the login screen.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          AppSheetActions(
            confirmLabel: 'Logout',
            isLoading: isLoading,
            confirmColor: AppColors.danger,
            onCancel: isLoading
                ? null
                : () => Navigator.of(context).pop(),
            onConfirm: submit,
          ),
        ],
      ),
    );
  }
}