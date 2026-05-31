import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/model_scaffold.dart';
import '../providers/teams_providers.dart';

class CreateTeamModal extends HookConsumerWidget {
  final VoidCallback onClose;

  const CreateTeamModal({super.key, required this.onClose});

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

      await ref
          .read(createTeamControllerProvider.notifier)
          .createTeam(name);

      if (ref.read(createTeamControllerProvider) is! AsyncError) {
        onClose();
      }
    }

    return ModalScaffold(
      onDismiss: isLoading ? null : onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.group_add_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Create Team', style: AppTextStyles.heading2),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Name field ─────────────────────────────────────────────────
          const ModalLabel('Team Name'),
          TextField(
            controller: nameCtrl,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => nameError.value = null,
            onSubmitted: (_) => submit(),
            decoration: InputDecoration(
              hintText: 'e.g. Engineering, Design…',
              errorText: nameError.value,
              prefixIcon: const Icon(
                Icons.group_outlined,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Description field ──────────────────────────────────────────
          const ModalLabel('Description (optional)'),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            decoration: const InputDecoration(
              hintText: 'What does this team work on?',
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Actions ────────────────────────────────────────────────────
          ModalActions(
            onCancel: onClose,
            onConfirm: submit,
            confirmLabel: 'Create Team',
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}