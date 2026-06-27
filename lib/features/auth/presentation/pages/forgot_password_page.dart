import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Forgot Password page.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  bool _isSent = false;
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    final formState = ref.read(authFormProvider);
    if (!formState.isForgotPasswordValid) return;

    setState(() => _isLoading = true);

    final authNotifier = ref.read(authStateProvider.notifier);
    final error = await authNotifier.forgotPassword(email: formState.email);

    setState(() => _isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() => _isSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSent ? _buildSuccessView() : _buildFormView(formNotifier, formState),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthFormNotifier formNotifier, AuthFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('form'),
      children: [
        Text(
          'Forgot Password',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Enter your email address and we'll send you a link to reset your password.",
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AuthTextField(
          label: 'Email',
          hint: 'your@email.com',
          onChanged: formNotifier.setEmail,
          keyboardType: TextInputType.emailAddress,
          errorText: formState.emailValidation.errorMessage,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AuthButton(
          label: 'Send Reset Link',
          isLoading: _isLoading,
          onPressed: formState.isForgotPasswordValid
              ? _handleForgotPassword
              : null,
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.xxl * 2),
        Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.success,
          size: 72,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Check Your Email',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'If an account exists with that email, we\'ve sent a password reset link.',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AuthButton(
          label: 'Back to Sign In',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}