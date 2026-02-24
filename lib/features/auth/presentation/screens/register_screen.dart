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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(authNotifierProvider.notifier).registerWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
              _nameController.text.trim(),
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
                const SizedBox(height: 20),
                // Back button
                Tappable(
                  onTap: () => context.go('/login'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: AppTypography.displayMedium(),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Start your speaking journey today',
                  style: AppTypography.bodyLarge(
                    color: context.textSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 32),

                // Name
                AppTextField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.name,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 16),

                // Email
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                const SizedBox(height: 16),

                // Password
                AppTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 16),

                // Confirm password
                AppTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _handleRegister,
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                const SizedBox(height: 32),

                // Register button
                AppButton(
                  label: 'Create Account',
                  onPressed: _handleRegister,
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
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.bodyMedium(),
                    ),
                    Tappable(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: AppTypography.titleMedium(
                            color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
