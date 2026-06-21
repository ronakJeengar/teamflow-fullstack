import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/ui/app_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/ui/shared_widgets.dart'; // ← replaces all the private _T / widget classes
import '../providers/providers.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscure = useState(true);
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();

    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;

    void handleLogin() {
      FocusScope.of(context).unfocus();
      if (formKey.currentState?.validate() ?? false) {
        HapticFeedback.lightImpact();
        ref
            .read(loginControllerProvider.notifier)
            .login(emailCtrl.text.trim(), passwordCtrl.text.trim());
      }
    }

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              AppTokens.s24, AppTokens.s48, AppTokens.s24, AppTokens.s24 + bottom),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBrandMark(),
                SizedBox(height: AppTokens.s32),

                Text(
                  'Welcome back',
                  style: AppTokens.displayLg,
                ),
                SizedBox(height: AppTokens.s6),
                Text(
                  'Sign in to your workspace',
                  style: AppTokens.bodySm,
                ),

                SizedBox(height: AppTokens.s32),

                AppFieldLabel(label: 'Email address'),
                SizedBox(height: AppTokens.s8),
                AppInputField(
                  controller: emailCtrl,
                  focusNode: emailFocus,
                  hint: 'you@company.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: Validators.validateEmail,
                  enabled: !isLoading,
                ),

                SizedBox(height: AppTokens.s20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppFieldLabel(label: 'Password'),
                    GestureDetector(
                      onTap: () {/* Handle forgot password */},
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.brand,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTokens.s8),
                AppInputField(
                  controller: passwordCtrl,
                  focusNode: passwordFocus,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscure.value,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => handleLogin(),
                  validator: Validators.validatePassword,
                  enabled: !isLoading,
                  suffix: AppVisibilityToggle(
                    obscure: obscure.value,
                    onToggle: () => obscure.value = !obscure.value,
                  ),
                ),

                SizedBox(height: AppTokens.s32),

                AppPrimaryButton(
                  label: 'Sign in',
                  isLoading: isLoading,
                  onPressed: handleLogin,
                ),

                if (loginState.hasError) ...[
                  SizedBox(height: AppTokens.s16),
                  AppErrorBanner(
                    message: _friendlyError(loginState.error.toString()),
                  ),
                ],

                SizedBox(height: AppTokens.s32),
                AppOrDivider(),
                SizedBox(height: AppTokens.s24),

                AppAuthNavPrompt(
                  question: "Don't have an account?",
                  actionLabel: 'Create account',
                  onTap: nav.goToSignup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('credential') ||
        lower.contains('password') ||
        lower.contains('invalid')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Connection failed. Check your internet and retry.';
    }
    return 'Something went wrong. Please try again.';
  }
}