import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';

/// Temporary Full Player placeholder page.
///
/// Navigated to when the user taps the [MiniPlayer].
/// Will be replaced by the real music player in Sprint 7.
class FullPlayerPlaceholderPage extends StatelessWidget {
  const FullPlayerPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art placeholder
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.white38,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Full Player',
              style: AppTypography.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Coming in Sprint 7',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}