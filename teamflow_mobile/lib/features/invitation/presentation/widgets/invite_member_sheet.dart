import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_ui.dart';
import '../providers/invitations_providers.dart';

class InviteMemberSheet extends HookConsumerWidget {
  final String teamId;

  const InviteMemberSheet({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailCtrl = useTextEditingController();

    final emailError = useState<String?>(null);
    final selectedRole = useState<String>('MEMBER');

    final controllerState = ref.watch(sendInvitationControllerProvider);

    final isLoading = controllerState is AsyncLoading;

    Future<void> submit() async {
      final email = emailCtrl.text.trim();

      if (email.isEmpty) {
        emailError.value = 'Email is required';
        return;
      }

      emailError.value = null;

      await ref
          .read(sendInvitationControllerProvider.notifier)
          .sendInvitation(
            teamId: teamId,
            email: email,
            role: selectedRole.value,
          );

      if (ref.read(sendInvitationControllerProvider) is! AsyncError) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return AppSheetShell(
      title: 'Invite Member',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetLabel('Email'),

          AppSheetInput(
            controller: emailCtrl,
            hint: 'member@example.com',
            errorText: emailError.value,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => emailError.value = null,
            onSubmitted: (_) => submit(),
          ),

          SizedBox(height: 16),

          const AppSheetLabel('Role'),

          DropdownButtonFormField<String>(
            value: selectedRole.value,
            items: const [
              DropdownMenuItem(value: 'MEMBER', child: Text('Member')),
              DropdownMenuItem(value: 'VIEWER', child: Text('Viewer')),
              DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
            ],
            onChanged: (value) {
              if (value != null) {
                selectedRole.value = value;
              }
            },
          ),

          SizedBox(height: 24),

          AppSheetActions(
            confirmLabel: 'Send Invite',
            isLoading: isLoading,
            onCancel: isLoading ? null : () => Navigator.of(context).pop(),
            onConfirm: submit,
          ),
        ],
      ),
    );
  }
}
