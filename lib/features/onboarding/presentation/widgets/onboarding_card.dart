import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class OnboardingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget illustration;

  const OnboardingCard({
    required this.title,
    required this.subtitle,
    required this.illustration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;

          // Fixed vertical spacings: lg(24) + sm(8) = 32
          const fixedSpacing = AppSpacing.lg + AppSpacing.sm;

          // Allocate 55% of remaining space to illustration, 45% to text
          final usableHeight = (availableHeight - fixedSpacing).clamp(160.0, double.infinity);
          final illustrationHeight = usableHeight * 0.55;
          final textAreaHeight = usableHeight * 0.45;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration area – constrained height, fills available width
              SizedBox(
                height: illustrationHeight.clamp(80.0, double.infinity),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Container(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.35),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: illustration,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Title + subtitle area – constrained height
              SizedBox(
                height: textAreaHeight.clamp(60.0, double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}