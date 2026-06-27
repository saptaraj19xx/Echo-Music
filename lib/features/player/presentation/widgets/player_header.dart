import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';

/// Header bar for the full-screen player with a drag handle and dismiss button.
class PlayerHeader extends StatelessWidget {
  final VoidCallback? onDismiss;
  final String? title;

  const PlayerHeader({
    super.key,
    this.onDismiss,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Dismiss button
          IconButton(
            onPressed: onDismiss ?? () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary,
            ),
            iconSize: 32,
          ),
          const Spacer(),
          // Title (e.g. "Now Playing")
          if (title != null)
            Text(
              title!,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          const Spacer(),
          // Placeholder to center the title
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}