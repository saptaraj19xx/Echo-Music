import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'sign_in_page.dart';

/// Sign Up page for creating a new account.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authNotifier = ref.read(authStateProvider.notifier);

    // Listen for errors
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign up to start your music journey.',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Email
              AuthTextField(
                label: 'Email',
                hint: 'your@email.com',
                onChanged: formNotifier.setEmail,
                keyboardType: TextInputType.emailAddress,
                errorText: formState.emailValidation.errorMessage,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Password
              AuthTextField(
                label: 'Password',
                hint: 'At least 8 characters',
                obscureText: !formState.isPasswordVisible,
                onChanged: formNotifier.setPassword,
                errorText: formState.passwordValidation.errorMessage,
                suffixIcon: IconButton(
                  icon: Icon(
                    formState.isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textHint,
                  ),
                  onPressed: formNotifier.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Password strength indicator
              _PasswordStrengthIndicator(password: formState.password),
              const SizedBox(height: AppSpacing.lg),
              // Confirm password
              AuthTextField(
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                obscureText: !formState.isConfirmPasswordVisible,
                onChanged: formNotifier.setConfirmPassword,
                errorText: formState.confirmPasswordValidation.errorMessage,
                suffixIcon: IconButton(
                  icon: Icon(
                    formState.isConfirmPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textHint,
                  ),
                  onPressed: formNotifier.toggleConfirmPasswordVisibility,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Sign Up button
              AuthButton(
                label: 'Create Account',
                isLoading: authState is AuthStateLoading,
                onPressed: formState.isSignUpValid
                    ? () {
                        authNotifier.signUp(
                          email: formState.email,
                          password: formState.password,
                        );
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignInPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Password strength indicator widget.
class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength(password);
    final (label, color, value) = switch (strength) {
      PasswordStrength.weak => ('Weak', AppColors.error, 0.25),
      PasswordStrength.fair => ('Fair', AppColors.warning, 0.5),
      PasswordStrength.strong => ('Strong', AppColors.success, 0.75),
      PasswordStrength.veryStrong => ('Very Strong', AppColors.success, 1.0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  PasswordStrength _calculateStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    if (score <= 4) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}

enum PasswordStrength { weak, fair, strong, veryStrong }