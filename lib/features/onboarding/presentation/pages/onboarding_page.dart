import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/animations/app_durations.dart';
import '../../../../features/auth/presentation/pages/auth_gate.dart';
import '../../domain/entities/onboarding_item.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;

  late final List<OnboardingItem> _items;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    _items = const [
      OnboardingItem(
        title: 'Welcome to Echo',
        subtitle: 'Music without limits.',
        illustrationAsset: 'assets/images/onboarding/echo-1.png',
      ),
      OnboardingItem(
        title: 'Discover Everything',
        subtitle: 'Millions of songs.\nEvery genre.\nEvery mood.',
        illustrationAsset: 'assets/images/onboarding/echo-2.png',
      ),
      OnboardingItem(
        title: 'Built Around You',
        subtitle:
            'AI recommendations.\nSmart playlists.\nPersonalized listening.',
        illustrationAsset: 'assets/images/onboarding/echo-3.png',
      ),
      OnboardingItem(
        title: "Let's Get Started",
        subtitle: 'Your music journey begins here.',
        illustrationAsset: 'assets/images/onboarding/echo-4.png',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const AuthGate(),
      ),
    );
  }

  void _onSkip() => _goToAuth();

  void _onNext() {
    final isLast = _currentIndex == _items.length - 1;
    if (isLast) {
      _goToAuth();
      return;
    }

    _pageController.nextPage(
      duration: AppDurations.splashPulse,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Skip',
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OnboardingIndicator(
                    count: _items.length,
                    currentIndex: _currentIndex,
                  ),
                ],
              ),
            ),
            Expanded(
              child: OnboardingPageView(
                items: _items,
                controller: _pageController,
                currentIndex: _currentIndex,
                onPageChanged: (i) {
                  setState(() => _currentIndex = i);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OnboardingButton(
                    label: isLast ? 'Continue' : 'Next',
                    onPressed: _onNext,
                    variantPrimary: true,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    isLast ? 'Continue' : 'Swipe to explore',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}