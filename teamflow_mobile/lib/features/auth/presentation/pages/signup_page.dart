import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:teamflow_mobile/core/navigation/app_navigation.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/utils/validators.dart';
import '../providers/providers.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/error_message.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_navigation_text.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);

    final signUpState = ref.watch(signupControllerProvider);

    void handleSignUp() {
      FocusScope.of(context).unfocus();

      if (formKey.currentState?.validate() ?? false) {
        ref
            .read(signupControllerProvider.notifier)
            .signup(
              nameController.text.trim(),
              emailController.text.trim(),
              passwordController.text.trim(),
            );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    icon: Icons.person_add_outlined,
                    title: 'Create Account',
                    subtitle: 'Sign up to get started',
                  ),
                  const SizedBox(height: 48),

                  AuthTextField(
                    controller: nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: obscurePassword.value,
                    validator: Validators.validateStrongPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          obscurePassword.value = !obscurePassword.value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: obscureConfirmPassword.value,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      passwordController.text,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => obscureConfirmPassword.value =
                          !obscureConfirmPassword.value,
                    ),
                  ),
                  const SizedBox(height: 24),

                  AuthButton(
                    onPressed: handleSignUp,
                    isLoading: signUpState.isLoading,
                    text: 'Sign Up',
                  ),
                  const SizedBox(height: 16),

                  if (signUpState.hasError)
                    ErrorMessage(message: signUpState.error.toString()),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const AuthDivider(),
                  const SizedBox(height: 24),

                  AuthNavigationText(
                    question: 'Already have an account? ',
                    actionText: 'Login',
                    onTap: nav.goToLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
