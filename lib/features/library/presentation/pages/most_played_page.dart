import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/library/domain/entities/most_played.dart';
import 'package:echo/features/library/providers/most_played_stream_provider.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:echo/features/player/providers/queue_provider.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';
import 'package:echo/features/player/presentation/widgets/album_art.dart';
import 'package:echo/shared/music/domain/song.dart';


/// Most Played page mirroring [RecentlyPlayedPage] architecture and UX.
///
/// NOTE:
/// - This page only reads from [mostPlayedStreamProvider] as its data source.
/// - Playback is controlled via existing queue/player providers.
class MostPlayedPage extends ConsumerWidget {
  const MostPlayedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostAsync = ref.watch(mostPlayedStreamProvider);

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
                  'Most Played',
                  style: AppTypography.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: mostAsync.maybeWhen(
                        data: (items) => Text(
                          '${items.length} items',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ),
                    IconButton(
                      onPressed: mostAsync.asData?.value.isEmpty ?? true
                          ? null
                          : () {
                              final items = mostAsync.asData?.value ?? const [];

                              final queued = items
                                  .map((e) => QueueItem.byId(e.songId))
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
                      onPressed: mostAsync.asData?.value?.isEmpty ?? true
                          ? null
                          : () {
                              final items = mostAsync.asData?.value ?? const [];
                              final shuffled = List<MostPlayed>.from(items)
                                ..shuffle();
                              final queued = shuffled
                                  .map((e) => QueueItem.byId(e.songId))
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
      body: mostAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load most played',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.refresh(mostPlayedStreamProvider),
        ),
        data: (items) {
          return items.isEmpty
              ? _MostPlayedEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _MostPlayedTile(
                      item: item,
                      onTap: () {
                        final queued = items
                            .map((e) => QueueItem.byId(e.songId))
                            .toList();
                        if (queued.isNotEmpty) {
                          // Load queue + select song. No seek/resume support
                          // because MostPlayed has only `lastPlayed` timestamp.
                          ref
                              .read(queueNotifierProvider.notifier)
                              .loadQueueFromQueueItems(
                                queued,
                                startIndex: index,
                              );
                        }
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}

class _MostPlayedTile extends ConsumerWidget {
  final MostPlayed item;
  final VoidCallback onTap;

  const _MostPlayedTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
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
                        _formatPlayCount(item.playCount),
                        style: AppTypography.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm / 2),
                      Text(
                        _timeAgo(item.lastPlayed),
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_MostPlayedAction>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                  tooltip: 'More actions',
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _MostPlayedAction.play,
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded),
                          SizedBox(width: 12),
                          Text('Play'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: _MostPlayedAction.playNext,
                      child: Row(
                        children: [
                          Icon(Icons.skip_next_rounded),
                          SizedBox(width: 12),
                          Text('Play Next'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: _MostPlayedAction.addToQueue,
                      child: Row(
                        children: [
                          Icon(Icons.playlist_add_rounded),
                          SizedBox(width: 12),
                          Text('Add to Queue'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (action) {
                    final song = Song(
                      id: item.songId,
                      title: item.title,
                      // Keeping mapping consistent with recently played usage.
                      artistId: item.songId,
                      artistName: item.artist,
                      albumArtUrl: item.artworkUrl,
                      duration: item.duration,
                    );

                    switch (action) {
                      case _MostPlayedAction.play:
                        onTap();
                        break;
                      case _MostPlayedAction.playNext:
                        ref
                            .read(queueNotifierProvider.notifier)
                            .playNext(song);
                        break;
                      case _MostPlayedAction.addToQueue:
                        ref
                            .read(queueNotifierProvider.notifier)
                            .addToQueue(song);
                        break;
                    }
                  },
                ),
              ],
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

  String _formatPlayCount(int count) {
    if (count == 1) return '1 play';
    return '$count plays';
  }
}

enum _MostPlayedAction { play, playNext, addToQueue }

class _MostPlayedEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mirror Recently Played empty state content.
    return _EmptyState(
      icon: Icons.bar_chart_rounded,
      title: 'No most played songs',
      subtitle: 'Your top tracks will appear here once you start listening.',
      actionLabel: 'Explore Music',
      onAction: () => Navigator.of(context).pop(),
    );
  }
}

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

