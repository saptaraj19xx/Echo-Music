import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/library/domain/entities/favorite_song.dart';
import 'package:echo/features/library/presentation/providers/library_providers.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:echo/features/player/providers/queue_provider.dart';

class LikedSongsPage extends ConsumerWidget {
  const LikedSongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongs = ref.watch(libraryRepositoryProvider).getFavoriteSongs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Songs'),
        actions: [
          IconButton(
            onPressed: likedSongs.isEmpty
                ? null
                : () {
                    final queued = likedSongs
                        .map((item) => QueueItem.byId(item.songId))
                        .toList();
                    if (queued.isNotEmpty) {
                      ref.read(queueNotifierProvider.notifier).loadQueueFromQueueItems(queued);
                    }
                  },
            icon: const Icon(Icons.play_arrow_rounded),
            tooltip: 'Play all',
          ),
          IconButton(
            onPressed: likedSongs.isEmpty
                ? null
                : () {
                    final shuffled = List<FavoriteSong>.from(likedSongs)..shuffle();
                    final queued = shuffled
                        .map((item) => QueueItem.byId(item.songId))
                        .toList();
                    if (queued.isNotEmpty) {
                      ref.read(queueNotifierProvider.notifier).loadQueueFromQueueItems(queued);
                    }
                  },
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Shuffle',
          ),
        ],
      ),
      body: likedSongs.isEmpty
          ? _EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No liked songs yet',
              subtitle: 'Songs you like will appear here',
              actionLabel: 'Explore Music',
              onAction: () => Navigator.of(context).pop(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: likedSongs.length,
              itemBuilder: (context, index) {
                final item = likedSongs[index];
                return _LikedSongTile(
                  item: item,
                  index: index,
                  onTap: () {
                    final queued = likedSongs
                        .map((e) => QueueItem.byId(e.songId))
                        .toList();
                    if (queued.isNotEmpty) {
                      ref.read(queueNotifierProvider.notifier)
                          .loadQueueFromQueueItems(queued, startIndex: index);
                    }
                  },
                  onToggleFavorite: () {
                    ref.read(favoritesProvider.notifier).toggleFavoriteSong(item.songId);
                  },
                );
              },
            ),
    );
  }
}

class _LikedSongTile extends ConsumerWidget {
  final FavoriteSong item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LikedSongTile({
    required this.item,
    required this.index,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.notifier).isFavoriteSong(item.songId);

    return Dismissible(
      key: ValueKey(item.songId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onToggleFavorite();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Liked Songs')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.favorite_border_rounded, color: Colors.white),
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
          child: const Icon(Icons.music_note_rounded, color: AppColors.textHint),
        ),
        title: Text(
          item.songId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Added ${_timeAgo(item.addedAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
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
            Icon(
              icon,
              size: 64,
              color: AppColors.textHint,
            ),
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