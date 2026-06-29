import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';
import 'package:echo/features/player/domain/entities/playing_song.dart';
import 'package:echo/features/player/presentation/widgets/album_art.dart';
import 'package:echo/features/player/presentation/widgets/playback_controls.dart';
import 'package:echo/features/player/presentation/widgets/player_background.dart';
import 'package:echo/features/player/presentation/widgets/player_header.dart';
import 'package:echo/features/player/presentation/widgets/queue_bottom_sheet.dart';
import 'package:echo/features/player/presentation/widgets/seek_bar.dart';

/// Full-screen music player page.
///
/// Premium Spotify/Apple Music-style experience with dynamic artwork-based
/// background, Hero artwork transition, floating animation, and smooth
/// animated metadata changes.
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
          final isBuffering = state.isBuffering;
          final errorMessage = state.errorMessage;

          return _DynamicBackground(
            albumArtUrl: currentSong?.song.albumArtUrl,
            child: PlayerBackground(
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
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: AppSpacing.lg),

                                // Album Artwork with floating animation
                                _FloatingArtwork(
                                  isPlaying: isPlaying,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xl,
                                    ),
                                    child: Hero(
                                      tag: 'artwork_${currentSong?.song.id ?? "none"}',
                                      child: AlbumArt(
                                        size: MediaQuery.of(context).size.width * 0.75,
                                        imageUrl: currentSong?.song.albumArtUrl,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xl + 8),

                                // Song metadata with animated transitions
                                _SongMetadata(
                                  currentSong: currentSong,
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Seek Bar
                                SeekBar(
                                  currentPosition: currentPosition,
                                  totalDuration: totalDuration,
                                  onSeek: (position) => controller.seek(position),
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Premium Playback Controls
                                PlaybackControls(
                                  isPlaying: isPlaying,
                                  onPrevious: () => controller.previous(),
                                  onPlayPause: () => controller.togglePlayPause(),
                                  onNext: () => controller.next(),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Bottom action buttons
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxl,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Favorite
                                      _ActionButton(
                                        icon: currentSong?.isFavorite == true
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: currentSong?.isFavorite == true
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        onPressed: () => controller.toggleFavorite(),
                                      ),
                                      // Shuffle
                                      _ActionButton(
                                        icon: Icons.shuffle_rounded,
                                        color: isShuffled
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        onPressed: () => controller.toggleShuffle(),
                                      ),
                                      // Repeat
                                      _ActionButton(
                                        icon: Icons.repeat_rounded,
                                        color: isRepeating
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        onPressed: () => controller.toggleRepeat(),
                                      ),
                                      // Queue
                                      _ActionButton(
                                        icon: Icons.queue_music_rounded,
                                        color: AppColors.textSecondary,
                                        onPressed: () => QueueBottomSheet.show(
                                          context,
                                          queue: state.queue,
                                          currentIndex: state.currentIndex,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xl),
                              ],
                            ),
                          ),

                          // Buffering overlay
                          if (isBuffering)
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                          // Error message toast
                          if (errorMessage != null && errorMessage.isNotEmpty)
                            Positioned(
                              top: AppSpacing.lg,
                              left: AppSpacing.md,
                              right: AppSpacing.md,
                              child: _PlaybackErrorBanner(
                                message: _cleanErrorMessage(errorMessage),
                                onDismiss: () {},
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  String _cleanErrorMessage(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Playback error';
    final firstLine = trimmed.split('\n').first.trim();
    if (firstLine.isEmpty) return 'Playback error';
    return firstLine.replaceAll('Exception: ', '').trim();
  }
}

class _DynamicBackground extends StatefulWidget {
  final String? albumArtUrl;
  final Widget child;

  const _DynamicBackground({
    required this.albumArtUrl,
    required this.child,
  });

  @override
  State<_DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<_DynamicBackground> {
  Color _topColor = AppColors.surface;
  Color _bottomColor = AppColors.background;

  @override
  void didUpdateWidget(_DynamicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.albumArtUrl != oldWidget.albumArtUrl) {
      _extractColors(widget.albumArtUrl);
    }
  }

  @override
  void initState() {
    super.initState();
    _extractColors(widget.albumArtUrl);
  }

  Future<void> _extractColors(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      setState(() {
        _topColor = AppColors.surface;
        _bottomColor = AppColors.background;
      });
      return;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(200, 200),
      );
      final dominant = palette.dominantColor;
      setState(() {
        _topColor = (dominant?.color ?? AppColors.surface).withValues(alpha: 0.35);
        _bottomColor = AppColors.background;
      });
    } catch (_) {
      setState(() {
        _topColor = AppColors.surface;
        _bottomColor = AppColors.background;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_topColor, _bottomColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: widget.child,
    );
  }
}

class _FloatingArtwork extends StatefulWidget {
  final bool isPlaying;
  final Widget child;

  const _FloatingArtwork({
    required this.isPlaying,
    required this.child,
  });

  @override
  State<_FloatingArtwork> createState() => _FloatingArtworkState();
}

class _FloatingArtworkState extends State<_FloatingArtwork>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_FloatingArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = _animation.value * 6 - 3;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SongMetadata extends StatelessWidget {
  final PlayingSong? currentSong;

  const _SongMetadata({this.currentSong});

  @override
  Widget build(BuildContext context) {
    final song = currentSong?.song;
    final title = song?.title ?? 'No track selected';
    final artist = song?.artistName ?? 'Unknown artist';
    final album = song?.albumTitle;

    return Column(
      children: [
        // Title
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Text(
            title,
            key: ValueKey(title),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Artist
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Text(
            artist,
            key: ValueKey(artist),
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Album
        if (album != null)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Text(
              album,
              key: ValueKey(album),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),

        // High Quality badge (placeholder)
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Text(
            'High Quality',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 26),
      splashRadius: 22,
      padding: const EdgeInsets.all(8),
    );
  }
}

class _PlaybackErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _PlaybackErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: AppColors.error,
      child: InkWell(
        onTap: onDismiss,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}