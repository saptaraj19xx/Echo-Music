import 'package:flutter/material.dart';

import '../../../../app/animations/app_curves.dart';
import '../../../../app/animations/app_durations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/onboarding_item.dart';
import 'onboarding_card.dart';

class OnboardingPageView extends StatefulWidget {
  final List<OnboardingItem> items;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const OnboardingPageView({
    required this.items,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    super.key,
  });

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.splashPulse,

    );

    _fade = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppCurves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentIndex != _lastIndex) {
      _lastIndex = widget.currentIndex;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.items.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        final isActive = index == widget.currentIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Opacity(
                  opacity: isActive ? 1 : 0.001,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: OnboardingCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        illustration: _Illustration(assetPath: item.illustrationAsset),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Illustration extends StatelessWidget {
  final String assetPath;

  const _Illustration({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    // Using Image.asset keeps the UI premium; assets may be updated later.
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.surfaceVariant,
              alignment: Alignment.center,
              child: Text(
                'Echo',
                style: AppTypography.textTheme.displayLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

