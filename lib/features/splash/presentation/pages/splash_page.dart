import 'package:flutter/material.dart';

import 'package:echo/app/animations/app_animations.dart';
import 'package:echo/app/animations/app_curves.dart';
import 'package:echo/app/animations/app_durations.dart';
import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:echo/features/splash/presentation/widgets/animated_background.dart';
import 'package:echo/features/splash/presentation/widgets/echo_logo.dart';
import 'package:echo/features/splash/presentation/widgets/pulse_indicator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _background;
  late final Animation<double> _logoIn;
  late final Animation<double> _taglineIn;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splashTotal,
    );

    _background = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.easeInOutCubic,
    );

    _logoIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.55, curve: AppCurves.fastOutSlowIn),
    );

    _taglineIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.72, curve: AppCurves.easeOutCubic),
    );

    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: AppCurves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const OnboardingPage(),
          ),
        );
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final logoSize = (maxW * 0.22).clamp(72.0, 112.0);

            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBackground(animation: _background),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.scaleIn(
                          animation: Tween<double>(begin: 0.92, end: 1)
                              .animate(_logoIn),
                          child: AppAnimations.fadeIn(
                            animation: _logoIn,
                            child: EchoLogo(size: logoSize),
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),

                        AppAnimations.fadeIn(
                          animation: _logoIn,
                          child: Text(
                            'Echo',
                            style: AppTypography.textTheme.displayLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.sm),

                        AppAnimations.fadeIn(
                          animation: _taglineIn,
                          child: Text(
                            'Music. Reimagined.',
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.lg),

                        PulseIndicator(animation: _pulse),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

