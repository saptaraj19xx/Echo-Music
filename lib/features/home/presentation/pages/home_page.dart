import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/shared/music/providers/music_providers.dart';


import 'package:echo/features/home/presentation/widgets/album_card.dart';
import 'package:echo/features/home/presentation/widgets/artist_card.dart';
import 'package:echo/features/home/presentation/widgets/horizontal_music_list.dart';
import 'package:echo/features/home/presentation/widgets/mini_player.dart';
import 'package:echo/features/home/presentation/widgets/playlist_card.dart';
import 'package:echo/features/home/presentation/widgets/section_header.dart';
import 'package:echo/features/home/presentation/widgets/song_card.dart';
import 'package:echo/features/home/presentation/widgets/genre_chip.dart';
import 'package:echo/features/player/presentation/pages/full_player_page.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';

/// Echo Home page — displays all home sections in a scrollable layout.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Future<void> _onSongTap(Song song) async {
    final controller = ref.read(playerControllerProvider);
    final songs = await ref.read(songsProvider.future);
    final index = songs.indexOf(song);
    controller.loadQueue(
      songs,
      startIndex: index >= 0 ? index : 0,
      autoPlay: true,
    );
  }

  void _openFullPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FullPlayerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);

    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final madeForYouPlaylists = ref.watch(madeForYouProvider);
    final trendingNow = ref.watch(trendingProvider);
    final newReleases = ref.watch(newReleasesProvider);

    final genres = ref.watch(genresProvider);
    final continueListeningPlaylists = ref.watch(continueListeningProvider);
    final artists = ref.watch(artistsProvider);

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  floating: true,
                  pinned: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        userName,
                        style: AppTypography.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: TextField(
                      style: AppTypography.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'What do you want to listen to?',
                        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textHint,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm + 4,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Recently Played'),
                        const SizedBox(height: AppSpacing.sm),
                        recentlyPlayed.when(
                          data: (songs) {
                            return HorizontalMusicList(
                              children: songs
                                  .map(
                                    (song) => SongCard(
                                      song: song,
                                      onTap: () => _onSongTap(song),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Made For You',
                          onSeeAllTap: null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        madeForYouPlaylists.when(
                          data: (playlists) {
                            return HorizontalMusicList(
                              children: playlists
                                  .map(
                                    (playlist) => PlaylistCard(
                                      playlist: playlist,
                                      onTap: () {},
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Trending Now'),
                        const SizedBox(height: AppSpacing.sm),
                        trendingNow.when(
                          data: (songs) {
                            return HorizontalMusicList(
                              children: songs
                                  .map(
                                    (song) => SongCard(
                                      song: song,
                                      onTap: () => _onSongTap(song),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'New Releases'),
                        const SizedBox(height: AppSpacing.sm),
                        newReleases.when(
                          data: (albums) {
                            return HorizontalMusicList(
                              children: albums
                                  .map(
                                    (album) => AlbumCard(
                                      album: album,
                                      onTap: () {},
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Genres'),
                        const SizedBox(height: AppSpacing.sm),
                        genres.when(
                          data: (genreList) {
                            return SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                itemCount: genreList.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: AppSpacing.sm),
                                itemBuilder: (context, index) =>
                                    GenreChip(genre: genreList[index]),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Continue Listening'),
                        const SizedBox(height: AppSpacing.sm),
                        continueListeningPlaylists.when(
                          data: (playlists) {
                            return HorizontalMusicList(
                              children: playlists
                                  .map(
                                    (playlist) => PlaylistCard(
                                      playlist: playlist,
                                      onTap: () {},
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Popular Artists'),
                        const SizedBox(height: AppSpacing.sm),
                        artists.when(
                          data: (artistList) {
                            return SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                itemCount: artistList.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: AppSpacing.sm),
                                itemBuilder: (context, index) =>
                                    ArtistCard(artist: artistList[index]),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 72),
                ),
              ],
            ),
          ),

          MiniPlayer(onTap: _openFullPlayer),
        ],
      ),
    );
  }
}

