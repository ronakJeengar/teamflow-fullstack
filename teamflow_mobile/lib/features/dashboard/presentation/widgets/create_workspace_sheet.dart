import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../providers/workspace_controller.dart';
import '../providers/workspaces_providers.dart';

class CreateWorkspaceSheet extends HookConsumerWidget {
  const CreateWorkspaceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final selectedColor = useState('#7C5CFF');
    final controllerState = ref.watch(workspaceControllerProvider);

    final colors = [
      '#7C5CFF', // Purple
      '#EF4444', // Red
      '#10B981', // Green
      '#F59E0B', // Amber
      '#3B82F6', // Blue
      '#EC4899', // Pink
    ];

    void handleCreate() async {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        showAppSnackBar(context, 'Workspace name cannot be empty');
        return;
      }

      // Check duplication
      final workspacesList = ref.read(workspacesListProvider).value ?? [];
      final isDuplicate = workspacesList.any(
        (w) => w.name.toLowerCase() == name.toLowerCase(),
      );

      if (isDuplicate) {
        showAppSnackBar(context, 'Workspace name already exists');
        return;
      }

      final success = await ref
          .read(workspaceControllerProvider.notifier)
          .createWorkspace(name, selectedColor.value);

      if (success && context.mounted) {
        showAppSnackBar(context, 'Workspace "$name" created successfully');
        Navigator.pop(context);
      } else if (context.mounted) {
        final latestState = ref.read(workspaceControllerProvider);
        final errorMsg = latestState.maybeWhen(
          error: (err, _) => err.toString(),
          orElse: () => 'Failed to create workspace',
        );
        showAppSnackBar(context, errorMsg);
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Workspace',
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
            const SizedBox(height: 16),
            Text(
              'NAME',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Acme Corp',
                hintStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'THEME COLOR',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: colors.map((colorHex) {
                final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                final isSelected = selectedColor.value == colorHex;

                return GestureDetector(
                  onTap: () => selectedColor.value = colorHex,
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : handleCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controllerState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Create Workspace',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
