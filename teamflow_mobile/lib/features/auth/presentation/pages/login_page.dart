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

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);

    final loginState = ref.watch(loginControllerProvider);

    void handleLogin() {
      FocusScope.of(context).unfocus();

      if (formKey.currentState?.validate() ?? false) {
        ref
            .read(loginControllerProvider.notifier)
            .login(emailController.text.trim(), passwordController.text.trim());
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
                    icon: Icons.lock_outline,
                    title: 'Welcome Back',
                    subtitle: 'Sign in to continue',
                  ),
                  const SizedBox(height: 48),

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
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: obscurePassword.value,
                    validator: Validators.validatePassword,
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
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  AuthButton(
                    onPressed: handleLogin,
                    isLoading: loginState.isLoading,
                    text: 'Login',
                  ),
                  const SizedBox(height: 16),

                  if (loginState.hasError)
                    ErrorMessage(message: loginState.error.toString()),

                  const SizedBox(height: 24),
                  const AuthDivider(),
                  const SizedBox(height: 24),

                  AuthNavigationText(
                    question: "Don't have an account? ",
                    actionText: 'Sign Up',
                    onTap: nav.goToSignup,
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
