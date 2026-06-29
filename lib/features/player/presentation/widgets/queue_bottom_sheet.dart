import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:echo/features/player/providers/queue_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Premium bottom sheet that displays the playback queue with reorder support.
class QueueBottomSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueNotifierProvider);

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
            // Header with queue length
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playing Queue',
                  style: AppTypography.textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    color: AppColors.surfaceVariant,
                  ),
                  child: Text(
                    '${queueState.length} songs',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Queue list
            if (queueState.isEmpty)
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
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: queueState.items.length,
                  onReorder: (oldIndex, newIndex) {
                    ref.read(queueNotifierProvider.notifier).reorder(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = queueState.items[index];
                    final isCurrent = index == queueState.currentIndex;
                    return _QueueTile(
                      key: ValueKey(item.song.id),
                      item: item,
                      isCurrent: isCurrent,
                      onTap: () {
                        ref.read(queueNotifierProvider.notifier).playAt(index);
                        Navigator.of(context).pop();
                      },
                      onRemove: () {
                        ref.read(queueNotifierProvider.notifier).removeAt(index);
                      },
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
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _QueueTile({
    required this.item,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
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
        title: Text(
          item.song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          item.song.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent)
              Icon(
                Icons.equalizer_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              splashRadius: 18,
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }
}