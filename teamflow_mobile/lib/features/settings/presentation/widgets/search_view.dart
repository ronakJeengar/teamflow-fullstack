import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/widget/edit_task_sheet.dart';
import '../../../tasks/domain/entitties/task_entity.dart';
import 'package:teamflow_mobile/core/ui/shared_widgets.dart';

class SearchView extends HookConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final selectedPriority = useState<String?>(null);
    final selectedStatus = useState<String?>(null);
    final isLoading = useState(false);
    final results = useState<List<TaskEntity>>([]);

    Future<void> performSearch(String query) async {
      if (query.trim().isEmpty) {
        results.value = [];
        return;
      }

      isLoading.value = true;
      try {
        final api = sl<ApiService>();
        final params = <String, dynamic>{
          'q': query,
        };
        if (selectedPriority.value != null) params['priority'] = selectedPriority.value;
        if (selectedStatus.value != null) params['status'] = selectedStatus.value;

        // Perform GET request to search endpoint
        final response = await api.get(
          '/search',
          queryParameters: params,
          fromJson: (json) {
            if (json is Map<String, dynamic> && json['tasks'] != null) {
              final tasksJson = json['tasks'] as List;
              return tasksJson.map((e) => TaskModel.fromJson(e).toEntity()).toList();
            }
            return <TaskEntity>[];
          },
        );

        if (response.status && response.data != null) {
          results.value = response.data!;
        }
      } catch (e) {
        // Fail silently
      } finally {
        isLoading.value = false;
      }
    }

    // Trigger search when query or filters change (debounced at 300ms)
    useEffect(() {
      Timer? debounceTimer;
      final listener = () {
        if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 300), () {
          performSearch(searchCtrl.text);
        });
      };
      searchCtrl.addListener(listener);
      return () {
        searchCtrl.removeListener(listener);
        debounceTimer?.cancel();
      };
    }, [selectedPriority.value, selectedStatus.value]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        TextField(
          controller: searchCtrl,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search tasks, tags, descriptions...',
            prefixIcon: const Icon(Icons.search, color: AppColors.muted),
            suffixIcon: searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.muted),
                    onPressed: () {
                      searchCtrl.clear();
                      results.value = [];
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
          onSubmitted: performSearch,
        ),
        const SizedBox(height: 12),

        // Priority filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                'Priority: ',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              ...['LOW', 'MEDIUM', 'HIGH', 'URGENT'].map((p) {
                final isSel = selectedPriority.value == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(p, style: GoogleFonts.inter(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onSelected: (selected) {
                      selectedPriority.value = selected ? p : null;
                      performSearch(searchCtrl.text);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Status filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                'Status:   ',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              ...['TODO', 'IN_PROGRESS', 'REVIEW', 'BLOCKED', 'DONE'].map((s) {
                final isSel = selectedStatus.value == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(s.replaceAll('_', ' '), style: GoogleFonts.inter(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onSelected: (selected) {
                      selectedStatus.value = selected ? s : null;
                      performSearch(searchCtrl.text);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search Results List
        if (isLoading.value)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: TeamFlowLoader(size: 40),
            ),
          )
        else if (results.value.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                searchCtrl.text.trim().isEmpty
                    ? 'Start typing to search tasks...'
                    : 'No matching tasks found',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.value.length,
            itemBuilder: (context, idx) {
              final task = results.value[idx];
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    'Priority: ${task.priority ?? "Medium"} • Status: ${task.status.name}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => EditTaskSheet(
                        task: task,
                        projectId: task.projectId,
                        teamId: '',
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
