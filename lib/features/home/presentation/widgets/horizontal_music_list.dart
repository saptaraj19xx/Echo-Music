import 'package:flutter/material.dart';

import 'package:echo/app/theme/app_spacing.dart';

/// A horizontally-scrollable list of widgets (cards).
///
/// Used to display rows of [SongCard], [AlbumCard], [PlaylistCard], etc.
class HorizontalMusicList extends StatelessWidget {
  final List<Widget> children;
  final double? itemHeight;

  const HorizontalMusicList({
    super.key,
    required this.children,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight ?? 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}