import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/teamflow_shell.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../auth/presentation/providers/providers.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings & Profile',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Update your profile information and account credentials.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar preview
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
              const SizedBox(height: 32),

              // Name Field
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
              const SizedBox(height: 20),

              // Bio Field
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
              const SizedBox(height: 20),

              // Password Field
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
              const SizedBox(height: 32),

              // Save Button
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
      );
    }

    return TeamFlowShell(
      activeTab: 'Settings',
      child: SingleChildScrollView(
        child: buildMainContent(),
      ),
    );
  }
}
