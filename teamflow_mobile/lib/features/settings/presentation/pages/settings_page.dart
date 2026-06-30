import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/teamflow_shell.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../widgets/calendar_view.dart';
import '../widgets/search_view.dart';
import '../widgets/activity_feed_view.dart';
import '../widgets/diagnostics_view.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.user;

    final nameController = useTextEditingController(text: user?.name ?? '');
    final bioController = useTextEditingController(text: user?.bio ?? '');
    final passwordController = useTextEditingController();
    
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final activeMenuTab = useState('Calendar'); // 'Calendar' | 'Search' | 'Activities' | 'Profile'

    // Keep controller texts in sync when user loaded/updated
    useEffect(() {
      if (user != null) {
        nameController.text = user.name;
        bioController.text = user.bio ?? '';
      }
      return null;
    }, [user]);

    Future<void> saveProfile() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      final notifier = ref.read(authStateNotifierProvider.notifier);

      final result = await notifier.updateProfile(
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
      );

      isLoading.value = false;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${failure.message}'),
              backgroundColor: AppColors.danger,
            ),
          );
        },
        (_) {
          passwordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    }

    Widget buildTab(String title, String value, IconData icon) {
      final isSel = activeMenuTab.value == value;
      return GestureDetector(
        onTap: () => activeMenuTab.value = value,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSel ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSel ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildMainContent() {
      if (user == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No user session found. Please log in.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Workspace Hub',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Access calendar, search tasks, track activities, or update profile.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Selection Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildTab('Calendar', 'Calendar', Icons.calendar_today_rounded),
                  buildTab('Search', 'Search', Icons.search_rounded),
                  buildTab('Timeline', 'Activities', Icons.history_rounded),
                  buildTab('Health', 'Diagnostics', Icons.health_and_safety_rounded),
                  buildTab('Profile', 'Profile', Icons.person_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Render sub-views conditionally
            if (activeMenuTab.value == 'Calendar')
              const CalendarView()
            else if (activeMenuTab.value == 'Search')
              const SearchView()
            else if (activeMenuTab.value == 'Activities')
              const ActivityFeedView()
            else if (activeMenuTab.value == 'Diagnostics')
              const DiagnosticsView()
            else
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          AppAvatar(
                            name: user.name,
                            size: 72,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.email,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Full Name',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Biography / Description',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: bioController,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Tell us about yourself...',
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'New Password (Optional)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Leave blank to keep current password',
                      ),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && val.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading.value ? null : saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return TeamFlowShell(
      activeTab: 'More',
      child: SingleChildScrollView(
        child: buildMainContent(),
      ),
    );
  }
}
