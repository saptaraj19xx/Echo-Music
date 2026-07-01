import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/home/presentation/widgets/song_card.dart';
import 'package:echo/shared/music/domain/song.dart';

class RecentlyPlayedLiveCard extends StatelessWidget {
  final List<RecentlyPlayed> items;
  final int liveItemCount;
  final void Function(RecentlyPlayed) onSongTap;

  const RecentlyPlayedLiveCard({
    super.key,
    required this.items,
    required this.liveItemCount,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recently Played',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$liveItemCount',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final recent = items[index];
                return SongCard(
                  song: Song(
                    id: recent.songId,
                    title: recent.title,
                    artistId: recent.artist,
                    artistName: recent.artist,
                  ),
                  onTap: () => onSongTap(recent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecentlyPlayedEmptyCard extends StatelessWidget {
  const RecentlyPlayedEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 42, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'No listening history yet',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Songs you play will appear here so you can pick up where you left off.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

