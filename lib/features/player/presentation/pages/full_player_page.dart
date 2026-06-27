import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';
import 'package:echo/features/player/presentation/widgets/album_art.dart';
import 'package:echo/features/player/presentation/widgets/playback_controls.dart';
import 'package:echo/features/player/presentation/widgets/player_background.dart';
import 'package:echo/features/player/presentation/widgets/player_header.dart';
import 'package:echo/features/player/presentation/widgets/queue_bottom_sheet.dart';
import 'package:echo/features/player/presentation/widgets/seek_bar.dart';

/// Full-screen music player page.
///
/// Displays album artwork, song metadata, playback controls,
/// seek bar, and additional controls (shuffle, repeat, etc.).
class FullPlayerPage extends ConsumerWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(playbackStateProvider);
    final controller = ref.watch(playerControllerProvider);

    return Scaffold(
      body: stateAsync.when(
        data: (state) {
          final currentSong = state.currentSong;
          final isPlaying = state.isPlaying;
          final isShuffled = state.isShuffled;
          final isRepeating = state.isRepeating;
          final currentPosition = state.currentPosition;
          final totalDuration = state.totalDuration;

          return PlayerBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  PlayerHeader(
                    onDismiss: () => Navigator.of(context).pop(),
                    title: 'Now Playing',
                  ),

                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),

                          // Album Artwork
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: AlbumArt(
                              size: MediaQuery.of(context).size.width * 0.75,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl + 8),

                          // Song Title
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Text(
                              currentSong?.song.title ?? 'No track selected',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Artist
                          Text(
                            currentSong?.song.artistName ?? 'Unknown artist',
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Album
                          if (currentSong?.song.albumTitle != null)
                            Text(
                              currentSong!.song.albumTitle!,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),

                          const SizedBox(height: AppSpacing.lg),

                          // Action buttons row (Favorite, Share, Queue, Lyrics)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Favorite
                                IconButton(
                                  onPressed: () => controller.toggleFavorite(),
                                  icon: Icon(
                                    currentSong?.isFavorite == true
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: currentSong?.isFavorite == true
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                                // Share (placeholder)
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.share_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                                // Queue
                                IconButton(
                                  onPressed: () => QueueBottomSheet.show(
                                    context,
                                    queue: state.queue,
                                    currentIndex: state.currentIndex,
                                  ),
                                  icon: const Icon(
                                    Icons.queue_music_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                                // Lyrics (placeholder)
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.lyrics_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Seek Bar
                          SeekBar(
                            currentPosition: currentPosition,
                            totalDuration: totalDuration,
                            onSeek: (position) => controller.seek(position),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Playback Controls
                          PlaybackControls(
                            isPlaying: isPlaying,
                            onPrevious: () => controller.previous(),
                            onPlayPause: () => controller.togglePlayPause(),
                            onNext: () => controller.next(),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Additional controls row (Shuffle, Repeat, Speed)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Shuffle
                                IconButton(
                                  onPressed: () => controller.toggleShuffle(),
                                  icon: Icon(
                                    Icons.shuffle_rounded,
                                    color: isShuffled
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                                // Repeat
                                IconButton(
                                  onPressed: () => controller.toggleRepeat(),
                                  icon: Icon(
                                    Icons.repeat_rounded,
                                    color: isRepeating
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                                // Playback speed (placeholder)
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.speed_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  iconSize: 28,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}