import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/shared/music/domain/genre.dart';

/// A colored chip representing a music [Genre].
class GenreChip extends StatelessWidget {
  final Genre genre;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.genre,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Color(genre.colorValue).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: Color(genre.colorValue).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          genre.name,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}