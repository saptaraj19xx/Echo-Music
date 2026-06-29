import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';

/// Displays a large album artwork placeholder.
class AlbumArt extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final String? title;

  const AlbumArt({
    super.key,
    this.size = 300,
    this.imageUrl,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final hasArtwork = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: hasArtwork
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
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

  Widget _placeholder() => Center(
        child: Icon(
          Icons.music_note_rounded,
          size: size * 0.35,
          color: AppColors.textHint,
        ),
      );
}