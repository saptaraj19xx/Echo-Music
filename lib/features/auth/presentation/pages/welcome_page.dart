import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/animations/app_durations.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

/// Welcome / Sign In choice page.
class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splashLogoIn,
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SignInPage(),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  void _handleGuestSignIn() async {
    // TEMP DIAGNOSTICS: confirm Guest button press
    // ignore: avoid_print
    print('[DIAG] WelcomePage: guest button pressed');
    await ref.read(authStateProvider.notifier).continueAsGuest();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo and branding
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.primary,
                    size: 72,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Echo',
                    style: AppTypography.textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Music. Reimagined.',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Buttons
                  AuthButton(
                    label: 'Continue with Email',
                    onPressed: _navigateToSignIn,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthButton(
                    label: 'Continue with Google',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Google Sign-In will be available after Firebase integration.',
                          ),
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      );
                    },
                    isOutlined: true,
                    icon: Icons.g_mobiledata_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthButton(
                    label: 'Continue as Guest',
                    onPressed: _handleGuestSignIn,
                    isOutlined: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToSignUp,
                        child: Text(
                          'Create Account',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}