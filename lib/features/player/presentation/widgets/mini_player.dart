import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';
import 'package:echo/features/player/presentation/pages/full_player_page.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Spotify-style persistent Mini Player.
///
/// Appears automatically when a song is loaded/playing and disappears when
/// playback stops or the queue is empty.
///
/// Sits above the bottom navigation bar inside [MainShellPage].
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(playbackStateProvider);

    return stateAsync.when(
      data: (state) {
        final song = state.currentSong?.song;
        final isPlaying = state.isPlaying;
        final isBuffering = state.isBuffering;
        final position = state.currentPosition;
        final totalDuration = state.totalDuration;
        final hasContent = song != null && (song.albumArtUrl != null || song.title.isNotEmpty);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: hasContent
              ? _MiniPlayerContent(
                  key: const ValueKey('mini_player_active'),
                  song: song,
                  isPlaying: isPlaying,
                  isBuffering: isBuffering,
                  position: position,
                  totalDuration: totalDuration,
                )
              : const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _MiniPlayerContent extends ConsumerWidget {
  final Song song;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration totalDuration;

  const _MiniPlayerContent({
    required this.song,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.totalDuration,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = totalDuration > Duration.zero
        ? position.inMilliseconds / totalDuration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTap: () => _openFullPlayer(context),
      child: Container(
        height: 76,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.surfaceVariant,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Content row
                  Expanded(
                    child: Row(
                      children: [
                        // Artwork
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                          child: Hero(
                            tag: 'artwork_${song.id}',
                            child: _Artwork(
                              albumArtUrl: song.albumArtUrl,
                              size: 52,
                            ),
                          ),
                        ),

                        // Title / artist + controls
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artistName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Playback controls
                        _PlaybackControls(
                          isPlaying: isPlaying,
                          isBuffering: isBuffering,
                          onPlayPause: () => ref.read(playerControllerProvider).togglePlayPause(),
                          onStop: () => ref.read(playerControllerProvider).pause(),
                        ),
                      ],
                    ),
                  ),

                  // Live progress indicator
                  SizedBox(
                    height: 3,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFullPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FullPlayerPage(),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final String? albumArtUrl;
  final double size;

  const _Artwork({required this.albumArtUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final hasArtwork = albumArtUrl != null && albumArtUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceVariant,
      ),
      child: hasArtwork
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                albumArtUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surfaceVariant,
        ),
        child: const Icon(
          Icons.music_note_rounded,
          color: AppColors.textHint,
          size: 22,
        ),
      );
}

class _PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;

  const _PlaybackControls({
    required this.isPlaying,
    required this.isBuffering,
    required this.onPlayPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onStop,
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          splashRadius: 18,
          padding: const EdgeInsets.all(8),
        ),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isBuffering
              ? const SizedBox(
                  key: ValueKey('buffering'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : IconButton(
                  key: const ValueKey('play_pause'),
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                  splashRadius: 20,
                  padding: const EdgeInsets.all(6),
                ),
        ),
      ],
    );
  }
}