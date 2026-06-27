import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

class OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool variantPrimary;

  const OnboardingButton({
    required this.label,
    required this.onPressed,
    this.variantPrimary = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bg = variantPrimary ? AppColors.primary : AppColors.surfaceVariant;
    final fg = variantPrimary ? Colors.white : AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

