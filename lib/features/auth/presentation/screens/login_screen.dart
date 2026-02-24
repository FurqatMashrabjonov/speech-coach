import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/core/utils/validators.dart';
import 'package:speech_coach/features/auth/presentation/providers/auth_provider.dart';
import 'package:speech_coach/features/auth/presentation/widgets/social_login_button.dart';
import 'package:speech_coach/shared/widgets/app_button.dart';
import 'package:speech_coach/shared/widgets/app_text_field.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success =
        await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleAppleLogin() async {
    final success =
        await ref.read(authNotifierProvider.notifier).signInWithApple();
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.error != null) {
        context.showSnackBar(next.error!, isError: true);
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome back',
                  style: AppTypography.displayMedium(),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue practicing',
                  style: AppTypography.bodyLarge(
                    color: context.textSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 40),

                // Email field
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 16),

                // Password field
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _handleLogin,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showResetPasswordDialog(),
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.bodyMedium(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                AppButton(
                  label: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: AppTypography.bodySmall(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Social logins
                SocialLoginButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: _handleGoogleLogin,
                  isLoading: authState.isLoading,
                ),
                if (Platform.isIOS) ...[
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple_rounded,
                    onPressed: _handleAppleLogin,
                    isLoading: authState.isLoading,
                  ),
                ],
                const SizedBox(height: 32),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.bodyMedium(),
                    ),
                    Tappable(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.titleMedium(
                            color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password'),
        content: AppTextField(
          hint: 'Enter your email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .resetPassword(emailController.text.trim());
                if (success && mounted) {
                  context.showSnackBar('Password reset email sent!');
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
