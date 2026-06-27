import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';

/// Main playback controls: previous, play/pause, next.
class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    this.onPrevious,
    this.onPlayPause,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: AppColors.textPrimary,
          ),
          iconSize: 40,
          splashRadius: 24,
        ),
        const SizedBox(width: 24),
        // Play/Pause
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPlayPause,
            icon: Icon(
              isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppColors.background,
            ),
            iconSize: 36,
            splashRadius: 28,
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 24),
        // Next
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.skip_next_rounded,
            color: AppColors.textPrimary,
          ),
          iconSize: 40,
          splashRadius: 24,
        ),
      ],
    );
  }
}