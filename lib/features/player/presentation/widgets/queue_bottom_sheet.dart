import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';

/// Bottom sheet that displays the playback queue.
class QueueBottomSheet extends StatelessWidget {
  final List<QueueItem> queue;
  final int currentIndex;

  const QueueBottomSheet({
    super.key,
    required this.queue,
    required this.currentIndex,
  });

  static void show(BuildContext context, {
    required List<QueueItem> queue,
    required int currentIndex,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) => QueueBottomSheet(
        queue: queue,
        currentIndex: currentIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Header
            Text(
              'Playing Queue',
              style: AppTypography.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            // Queue list
            if (queue.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'Queue is empty',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: queue.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) {
                    final item = queue[index];
                    final isCurrent = index == currentIndex;
                    return _QueueTile(
                      item: item,
                      isCurrent: isCurrent,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final QueueItem item;
  final bool isCurrent;

  const _QueueTile({
    required this.item,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Icon(
                Icons.music_note_rounded,
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.textHint,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Song info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCurrent
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.song.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Current indicator
          if (isCurrent)
            Icon(
              Icons.equalizer_rounded,
              color: AppColors.primary,
              size: 20,
            ),
        ],
      ),
    );
  }
}