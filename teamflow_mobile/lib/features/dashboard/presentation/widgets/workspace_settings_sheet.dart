import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../../data/models/workspace_model.dart';
import '../providers/workspace_controller.dart';
import '../providers/workspaces_providers.dart';

class WorkspaceSettingsSheet extends HookConsumerWidget {
  final WorkspaceModel workspace;

  const WorkspaceSettingsSheet({
    super.key,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController(text: workspace.name);
    final selectedColor = useState(workspace.color ?? '#7C5CFF');
    final activeTab = useState(0); // 0 = General, 1 = Members
    final inviteEmailCtrl = useTextEditingController();
    final inviteRole = useState('MEMBER');

    final controllerState = ref.watch(workspaceControllerProvider);
    final membersAsync = ref.watch(workspaceMembersProvider(workspace.id));
    final currentUser = ref.watch(authStateNotifierProvider).user;
    final currentUserId = currentUser?.id;
    final isOwner = workspace.ownerId == currentUserId;

    final colors = [
      '#7C5CFF',
      '#EF4444',
      '#10B981',
      '#F59E0B',
      '#3B82F6',
      '#EC4899',
    ];

    void handleSaveGeneral() async {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        showAppSnackBar(context, 'Workspace name cannot be empty');
        return;
      }

      // Check duplication excluding this workspace
      final workspacesList = ref.read(workspacesListProvider).value ?? [];
      final isDuplicate = workspacesList.any(
        (w) => w.id != workspace.id && w.name.toLowerCase() == name.toLowerCase(),
      );

      if (isDuplicate) {
        showAppSnackBar(context, 'Workspace name already exists');
        return;
      }

      final success = await ref
          .read(workspaceControllerProvider.notifier)
          .updateWorkspace(workspace.id, name, selectedColor.value);

      if (success && context.mounted) {
        showAppSnackBar(context, 'Workspace updated successfully');
        Navigator.of(context).pop(); // Close settings sheet
      }
    }

    void handleDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Delete Workspace',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete "${workspace.name}"? This action cannot be undone and will delete all associated teams, projects, and tasks.',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final success = await ref
            .read(workspaceControllerProvider.notifier)
            .deleteWorkspace(workspace.id);

        if (success && context.mounted) {
          showAppSnackBar(context, 'Workspace deleted successfully');
          Navigator.pop(context); // Close settings sheet
        }
      }
    }

    void handleAddMember() async {
      final email = inviteEmailCtrl.text.trim();
      if (email.isEmpty) {
        showAppSnackBar(context, 'Please enter an email address');
        return;
      }

      final success = await ref
          .read(workspaceControllerProvider.notifier)
          .addMember(workspace.id, email, inviteRole.value);

      if (success && context.mounted) {
        showAppSnackBar(context, 'Member added successfully');
        inviteEmailCtrl.clear();
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workspace.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Custom Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton('General', 0, activeTab),
                  const SizedBox(width: 16),
                  _buildTabButton('Members', 1, activeTab),
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: activeTab.value == 0
                    ? _buildGeneralTab(context, nameCtrl, selectedColor, colors, handleSaveGeneral, handleDelete, isOwner)
                    : _buildMembersTab(context, ref, membersAsync, inviteEmailCtrl, inviteRole, handleAddMember, isOwner, currentUserId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, ValueNotifier<int> activeTab) {
    final isSelected = activeTab.value == index;
    return GestureDetector(
      onTap: () => activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2))
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab(
    BuildContext context,
    TextEditingController nameCtrl,
    ValueNotifier<String> selectedColor,
    List<String> colors,
    VoidCallback onSave,
    VoidCallback onDelete,
    bool isOwner,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'WORKSPACE NAME',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameCtrl,
          enabled: isOwner,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'THEME COLOR',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: colors.map((colorHex) {
            final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
            final isSelected = selectedColor.value == colorHex;

            return GestureDetector(
              onTap: isOwner ? () => selectedColor.value = colorHex : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: AppColors.textPrimary, width: 2)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        if (isOwner) ...[
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save Changes', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete Workspace', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ] else
          Text(
            'Only the workspace owner can edit general settings.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Widget _buildMembersTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue membersAsync,
    TextEditingController emailCtrl,
    ValueNotifier<String> roleState,
    VoidCallback onAdd,
    bool isOwner,
    String? currentUserId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOwner) ...[
          Text(
            'INVITE MEMBER',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: emailCtrl,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'user@example.com',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: roleState.value,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['ADMIN', 'MEMBER', 'VIEWER'].map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) roleState.value = val;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Invite Member', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
        ],
        Text(
          'MEMBERS LIST',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted),
        ),
        const SizedBox(height: 8),
        membersAsync.when(
          data: (members) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
              itemBuilder: (ctx, idx) {
                final member = members[idx];
                final user = member.user;
                final email = user?.email ?? 'Unknown Email';
                final name = user?.name ?? 'Unknown Member';
                final memberIsOwner = member.role == 'OWNER';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'M',
                            style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(email, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (isOwner && !memberIsOwner) ...[
                        DropdownButton<String>(
                          value: member.role,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                          underline: const SizedBox.shrink(),
                          items: ['ADMIN', 'MEMBER', 'VIEWER'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (newRole) async {
                            if (newRole != null) {
                              final success = await ref
                                  .read(workspaceControllerProvider.notifier)
                                  .updateMemberRole(workspace.id, member.id, newRole);
                              if (success && context.mounted) {
                                showAppSnackBar(context, 'Role updated to $newRole');
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 18),
                          onPressed: () async {
                            final success = await ref
                                .read(workspaceControllerProvider.notifier)
                                .removeMember(workspace.id, member.id);
                            if (success && context.mounted) {
                              showAppSnackBar(context, 'Member removed successfully');
                            }
                          },
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: memberIsOwner ? AppColors.primary.withOpacity(0.1) : AppColors.muted.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            member.role,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: memberIsOwner ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: TeamFlowLoader(size: 32))),
          error: (err, stack) => Text('Error loading members: $err', style: GoogleFonts.inter(color: AppColors.danger)),
        ),
      ],
    );
  }
}
