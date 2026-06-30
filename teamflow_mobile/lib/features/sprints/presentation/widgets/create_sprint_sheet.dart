import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../providers/sprint_controller.dart';
import '../providers/sprints_providers.dart';

class CreateSprintSheet extends HookConsumerWidget {
  final String projectId;

  const CreateSprintSheet({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final goalCtrl = useTextEditingController();
    final startDate = useState<DateTime>(DateTime.now());
    final endDate = useState<DateTime>(DateTime.now().add(const Duration(days: 14)));
    final controllerState = ref.watch(sprintControllerProvider);

    Future<void> selectDate(BuildContext context, ValueNotifier<DateTime> dateNotifier) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: dateNotifier.value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        dateNotifier.value = picked;
      }
    }

    void handleCreate() async {
      final name = nameCtrl.text.trim();
      final goal = goalCtrl.text.trim();

      if (name.isEmpty) {
        showAppSnackBar(context, 'Sprint name cannot be empty');
        return;
      }

      if (endDate.value.isBefore(startDate.value)) {
        showAppSnackBar(context, 'End date must be after start date');
        return;
      }

      // Check duplication
      final sprints = ref.read(sprintsListProvider(projectId)).value ?? [];
      final isDuplicate = sprints.any((s) => s.name.toLowerCase() == name.toLowerCase());
      if (isDuplicate) {
        showAppSnackBar(context, 'Sprint name already exists in this project');
        return;
      }

      final success = await ref.read(sprintControllerProvider.notifier).createSprint(
            projectId,
            name: name,
            goal: goal.isEmpty ? null : goal,
            startDate: startDate.value,
            endDate: endDate.value,
          );

      if (success && context.mounted) {
        showAppSnackBar(context, 'Sprint "$name" planned successfully');
        Navigator.pop(context);
      } else if (context.mounted && controllerState.hasError) {
        showAppSnackBar(context, controllerState.error.toString());
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
                  'Plan New Sprint',
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
              'SPRINT NAME',
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
                hintText: 'e.g. Sprint 1',
                hintStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SPRINT GOAL',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: goalCtrl,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Implement user core feedback',
                hintStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'START DATE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => selectDate(context, startDate),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(startDate.value),
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.muted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'END DATE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => selectDate(context, endDate),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(endDate.value),
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.muted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                      'Plan Sprint',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
