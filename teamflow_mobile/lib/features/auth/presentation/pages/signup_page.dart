import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/ui/app_tokens.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../providers/providers.dart';

enum _PasswordStrength { empty, weak, fair, strong }

_PasswordStrength _evalStrength(String pw) {
  if (pw.isEmpty) return _PasswordStrength.empty;
  int score = 0;
  if (pw.length >= 8) score++;
  if (pw.contains(RegExp(r'[A-Z]'))) score++;
  if (pw.contains(RegExp(r'[0-9]'))) score++;
  if (pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
  if (score <= 1) return _PasswordStrength.weak;
  if (score == 2) return _PasswordStrength.fair;
  return _PasswordStrength.strong;
}

extension _StrengthX on _PasswordStrength {
  Color get color => const [
    Colors.transparent,
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF059669),
  ][index];

  String get label => const ['', 'Weak', 'Fair', 'Strong'][index];

  double get fill => const [0.0, 0.33, 0.66, 1.0][index];
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final confirmCtrl = useTextEditingController();

    final obscurePassword = useState(true);
    final obscureConfirm = useState(true);
    final passwordStrength = useState(_PasswordStrength.empty);

    final nameFocus = useFocusNode();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final confirmFocus = useFocusNode();

    final signUpState = ref.watch(signupControllerProvider);
    final isLoading = signUpState.isLoading;

    useEffect(() {
      void onPasswordChanged() {
        passwordStrength.value = _evalStrength(passwordCtrl.text);
      }

      passwordCtrl.addListener(onPasswordChanged);
      return () => passwordCtrl.removeListener(onPasswordChanged);
    }, []);

    void handleSignUp() {
      FocusScope.of(context).unfocus();
      if (formKey.currentState?.validate() ?? false) {
        HapticFeedback.lightImpact();
        ref.read(signupControllerProvider.notifier).signup(
          nameCtrl.text.trim(),
          emailCtrl.text.trim(),
          passwordCtrl.text.trim(),
        );
      }
    }

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              AppTokens.s24, AppTokens.s40, AppTokens.s24, AppTokens.s24 + bottom),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBrandMark(),
                const SizedBox(height: AppTokens.s32),

                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTokens.textPrimary,
                    letterSpacing: -1.0,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: AppTokens.s6),
                const Text(
                  'Join your team in seconds',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTokens.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: AppTokens.s32),

                const _StepIndicator(totalFields: 4),
                const SizedBox(height: AppTokens.s24),

                // ── Full name ────────────────────────────────────────────────
                const AppFieldLabel(label: 'Full name'),
                const SizedBox(height: AppTokens.s8),
                AppInputField(
                  controller: nameCtrl,
                  focusNode: nameFocus,
                  hint: 'Jane Doe',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => emailFocus.requestFocus(),
                  validator: Validators.validateName,
                  enabled: !isLoading,
                ),

                const SizedBox(height: AppTokens.s20),

                // ── Email ────────────────────────────────────────────────────
                const AppFieldLabel(label: 'Work email'),
                const SizedBox(height: AppTokens.s8),
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

                const SizedBox(height: AppTokens.s20),

                // ── Password ─────────────────────────────────────────────────
                const AppFieldLabel(label: 'Password'),
                const SizedBox(height: AppTokens.s8),
                AppInputField(
                  controller: passwordCtrl,
                  focusNode: passwordFocus,
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword.value,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => confirmFocus.requestFocus(),
                  validator: Validators.validateStrongPassword,
                  enabled: !isLoading,
                  suffix: AppVisibilityToggle(
                    obscure: obscurePassword.value,
                    onToggle: () =>
                    obscurePassword.value = !obscurePassword.value,
                  ),
                ),

                if (passwordStrength.value != _PasswordStrength.empty) ...[
                  const SizedBox(height: AppTokens.s10),
                  _StrengthMeter(strength: passwordStrength.value),
                ],

                const SizedBox(height: AppTokens.s20),

                // ── Confirm password ─────────────────────────────────────────
                const AppFieldLabel(label: 'Confirm password'),
                const SizedBox(height: AppTokens.s8),
                AppInputField(
                  controller: confirmCtrl,
                  focusNode: confirmFocus,
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscureConfirm.value,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => handleSignUp(),
                  validator: (v) => Validators.validateConfirmPassword(
                    v,
                    passwordCtrl.text,
                  ),
                  enabled: !isLoading,
                  suffix: AppVisibilityToggle(
                    obscure: obscureConfirm.value,
                    onToggle: () =>
                    obscureConfirm.value = !obscureConfirm.value,
                  ),
                ),

                const SizedBox(height: AppTokens.s32),

                AppPrimaryButton(
                  label: 'Create account',
                  isLoading: isLoading,
                  onPressed: handleSignUp,
                ),

                if (signUpState.hasError) ...[
                  const SizedBox(height: AppTokens.s16),
                  AppErrorBanner(
                    message: _friendlyError(signUpState.error.toString()),
                  ),
                ],

                const SizedBox(height: AppTokens.s24),
                const _LegalNote(),
                const SizedBox(height: AppTokens.s24),
                const AppOrDivider(),
                const SizedBox(height: AppTokens.s24),

                AppAuthNavPrompt(
                  question: 'Already have an account?',
                  actionLabel: 'Sign in',
                  onTap: nav.goToLogin,
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
    if (lower.contains('email') && lower.contains('exist')) {
      return 'An account with this email already exists. Try signing in instead.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Connection failed. Check your internet and retry.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────
// Signup-specific — not worth generalising.

class _StepIndicator extends StatelessWidget {
  final int totalFields;

  const _StepIndicator({required this.totalFields});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s10, vertical: AppTokens.s4),
          decoration: BoxDecoration(
            color: AppTokens.brandSurface,
            borderRadius: BorderRadius.circular(AppTokens.r10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTokens.brand,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTokens.s6),
              Text(
                'Quick setup · $totalFields fields',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.brand,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Password strength meter ──────────────────────────────────────────────────
// Signup-specific.

class _StrengthMeter extends StatelessWidget {
  final _PasswordStrength strength;

  const _StrengthMeter({required this.strength});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 4, color: const Color(0xFFE2E8F0)),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  widthFactor: strength.fill,
                  child: Container(height: 4, color: strength.color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppTokens.s10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            strength.label,
            key: ValueKey(strength),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: strength.color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Legal note ───────────────────────────────────────────────────────────────
// Signup-specific.

class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppTokens.textHint,
          height: 1.6,
        ),
        children: [
          TextSpan(text: 'By creating an account you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: AppTokens.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppTokens.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}