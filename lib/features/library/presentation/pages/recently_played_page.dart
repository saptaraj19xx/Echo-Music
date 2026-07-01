import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/library/presentation/providers/library_providers.dart';
import 'package:echo/features/library/providers/recently_played_stream_provider.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:echo/features/player/providers/queue_provider.dart';
import 'package:echo/features/player/presentation/widgets/album_art.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';

// NOTE: This page only controls playback via PlayerController methods and does not add providers.




import 'package:echo/features/player/presentation/widgets/album_art.dart';
import 'package:echo/shared/music/domain/song.dart';


class RecentlyPlayedPage extends ConsumerWidget {
  const RecentlyPlayedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentlyPlayedStreamProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          alignment: Alignment.bottomLeft,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Recently Played',
                  style: AppTypography.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: historyAsync.maybeWhen(
                        data: (history) => Text(
                          '${history.length} items',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ),
                    IconButton(
                      onPressed: historyAsync.asData?.value?.isEmpty ?? true
                          ? null
                          : () {
                              final history = historyAsync.asData?.value ?? const [];
                              final queued = history
                                  .map((item) => QueueItem.byId(item.songId))
                                  .toList();
                              if (queued.isNotEmpty) {
                                ref
                                    .read(queueNotifierProvider.notifier)
                                    .loadQueueFromQueueItems(queued);
                              }
                            },
                      icon: const Icon(Icons.play_arrow_rounded),
                      tooltip: 'Play all',
                    ),
                    IconButton(
                      onPressed: historyAsync.asData?.value?.isEmpty ?? true
                          ? null
                          : () {
                              final history = historyAsync.asData?.value ?? const [];
                              final shuffled = List<RecentlyPlayed>.from(history)..shuffle();
                              final queued = shuffled
                                  .map((item) => QueueItem.byId(item.songId))
                                  .toList();
                              if (queued.isNotEmpty) {
                                ref
                                    .read(queueNotifierProvider.notifier)
                                    .loadQueueFromQueueItems(queued);
                              }
                            },
                      icon: const Icon(Icons.shuffle_rounded),
                      tooltip: 'Shuffle',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load history',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.refresh(recentlyPlayedStreamProvider),
        ),
        data: (history) {
          return history.isEmpty
              ? _EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No listening history',
                  subtitle: 'Songs you play will appear here',
                  actionLabel: 'Explore Music',
                  onAction: () => Navigator.of(context).pop(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _HistoryTile(
                      item: item,
                      onTap: () {
                        final queued = history
                            .map((e) => QueueItem.byId(e.songId))
                            .toList();
                        if (queued.isNotEmpty) {
                          // Resume logic using RecentlyPlayed.lastPosition.
                          final clampedDuration = item.duration;
                          final stored = item.lastPosition;
                          final canResume = stored > Duration.zero && stored < clampedDuration;

                          // Load the selected song into the existing queue.
                          ref
                              .read(queueNotifierProvider.notifier)
                              .loadQueueFromQueueItems(
                                queued,
                                startIndex: index,
                              );

                          // Resume deterministically: wait until playback processing state is ready.
                          Future<void>(() async {
                            try {
                              if (!canResume) return;

                              // Load/playback state is driven by the existing playback layer.
                              // Wait until the player reports `ready` or at least non-buffering.
                              final stateStream = ref.read(playbackStateProvider.stream);
                              await stateStream.firstWhere((s) => !s.isBuffering);

                              // Seek via existing player controller.
                              final playerController = ref.read(playerControllerProvider);
                              playerController.seek(stored);

                            } catch (_) {
                              // If seeking fails or readiness wait fails, continue from the beginning.
                              try {
                                final playerController = ref.read(playerControllerProvider);
                                playerController.seek(Duration.zero);
                              } catch (_) {
                                // swallow
                              }
                            }
                          });
                        }
                      },
                      onRemove: () {
                        ref.read(recentProvider.notifier).remove(item.songId);
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  final RecentlyPlayed item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.songId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onRemove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from history')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glow.withValues(alpha: 0.15),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlbumArt(
                    size: 56,
                    imageUrl: item.artworkUrl,
                    title: item.title,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _formatDuration(item.duration),
                          style: AppTypography.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm / 2),
                        Text(
                          _timeAgo(item.playedAt),
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_HistoryAction>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: AppColors.textSecondary),
                    tooltip: 'More actions',
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _HistoryAction.play,
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow_rounded),
                            SizedBox(width: 12),
                            Text('Play'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: _HistoryAction.playNext,
                        child: Row(
                          children: [
                            Icon(Icons.skip_next_rounded),
                            SizedBox(width: 12),
                            Text('Play Next'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: _HistoryAction.addToQueue,
                        child: Row(
                          children: [
                            Icon(Icons.playlist_add_rounded),
                            SizedBox(width: 12),
                            Text('Add to Queue'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: _HistoryAction.remove,
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Remove from history'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (action) {
                      final song = Song(
                        id: item.songId,
                        title: item.title,
                        artistId: item.songId,
                        artistName: item.artist,
                        albumArtUrl: item.artworkUrl,
                        duration: item.duration,
                      );
                      switch (action) {
                        case _HistoryAction.play:
                          ref
                              .read(queueNotifierProvider.notifier)
                              .loadQueueFromQueueItems([QueueItem(song: song)]);
                          break;
                        case _HistoryAction.playNext:
                          ref
                              .read(queueNotifierProvider.notifier)
                              .playNext(song);
                          break;
                        case _HistoryAction.addToQueue:
                          ref
                              .read(queueNotifierProvider.notifier)
                              .addToQueue(song);
                          break;
                        case _HistoryAction.remove:
                          onRemove();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Removed from history')),
                          );
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final minutes = (totalSeconds ~/ 60);
    final seconds = (totalSeconds % 60);
    final mm = minutes.toString().padLeft(1, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

enum _HistoryAction { play, playNext, addToQueue, remove }


class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.explore_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

