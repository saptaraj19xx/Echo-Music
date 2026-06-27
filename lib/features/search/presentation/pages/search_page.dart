import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/shared/core/ui_state.dart';

import 'package:echo/shared/music/providers/music_providers.dart';
import 'package:echo/features/home/presentation/widgets/album_card.dart';
import 'package:echo/features/home/presentation/widgets/artist_card.dart';
import 'package:echo/features/home/presentation/widgets/playlist_card.dart';
import 'package:echo/features/home/presentation/widgets/song_card.dart';
import 'package:echo/features/search/presentation/providers/search_providers.dart';

/// Echo Search page — live search, genres, trending, and recent searches.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    ref.read(searchQueryProvider.notifier).updateQuery(query);
  }

  void _clearQuery() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isSearchingProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final trendingSearches = ref.watch(trendingSearchesProvider);
    final genresAsync = ref.watch(genresProvider);


    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // -----------------------------------------------------------
            // Search Bar
            // -----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _controller,
                style: AppTypography.textTheme.bodyLarge,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          onPressed: _clearQuery,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textHint,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + 4,
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------
            // Body
            // -----------------------------------------------------------
            Expanded(
            child: _buildBody(
              isSearching: isSearching,
              resultsAsync: resultsAsync,
              recentSearches: recentSearches,
              trendingSearches: trendingSearches,
              genresAsync: genresAsync,
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isSearching,
    required AsyncValue<UiState<SearchResults>> resultsAsync,
    required List<String> recentSearches,
    required List<String> trendingSearches,
    required AsyncValue<List<dynamic>> genresAsync,
  }) {
    if (!isSearching) {
      return _buildDiscoveryContent(
        recentSearches: recentSearches,
        trendingSearches: trendingSearches,
        genres: const [],
      );
    }

    return resultsAsync.when(
      data: (uiState) => uiState.when(
        success: (data) => _buildSuccessResults(data),
        loading: () => _buildLoadingResults(),
        error: (_) => _buildErrorResults(),
      ),
      loading: () => _buildLoadingResults(),
      error: (_, __) => _buildErrorResults(),
    );
  }

  Widget _buildDiscoveryContent({
    required List<String> recentSearches,
    required List<String> trendingSearches,
    required List<dynamic> genres,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.sm),

        // -----------------------------------------------------------
        // Recent Searches
        // -----------------------------------------------------------
        if (recentSearches.isNotEmpty) ...[
          const _SectionHeader(title: 'Recent Searches'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: recentSearches
                .map(
                  (term) => ActionChip(
                    label: Text(term),
                    onPressed: () {
                      _controller.text = term;
                      _onQueryChanged(term);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // -----------------------------------------------------------
        // Trending Searches
        // -----------------------------------------------------------
        if (trendingSearches.isNotEmpty) ...[
          const _SectionHeader(title: 'Trending'),
          const SizedBox(height: AppSpacing.sm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trendingSearches.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final term = trendingSearches[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.textTheme.labelSmall,
                  ),
                ),
                title: Text(term),
                onTap: () {
                  _controller.text = term;
                  _onQueryChanged(term);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // -----------------------------------------------------------
        // Browse by Genre
        // -----------------------------------------------------------
        if (genres.isNotEmpty) ...[
          const _SectionHeader(title: 'Browse by Genre'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => Chip(
                label: Text(genres[index].name),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // -----------------------------------------------------------
        // Featured Artists
        // -----------------------------------------------------------
        const _SectionHeader(title: 'Featured Artists'),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 120,
          child: Consumer(
            builder: (context, ref, child) {
              final artists = ref.watch(artistsProvider).maybeWhen(
                data: (list) => list.take(5).toList(),
                orElse: () => <dynamic>[],
              );
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: artists.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    ArtistCard(artist: artists[index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // -----------------------------------------------------------
        // Featured Albums
        // -----------------------------------------------------------
        const _SectionHeader(title: 'Featured Albums'),
        const SizedBox(height: AppSpacing.sm),
        Consumer(
          builder: (context, ref, child) {
            final albums = ref.watch(albumsProvider).maybeWhen(
                  data: (list) => list.take(8).toList(),
                  orElse: () => <dynamic>[],
                );
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: albums.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) => AlbumCard(
                album: albums[index],
                onTap: () {},
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSuccessResults(dynamic results) {
    return _buildResultsList(results);
  }

  Widget _buildLoadingResults() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Something went wrong. Please try again.',
          style: AppTypography.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildResultsList(dynamic results) {
    final hasAnyResult = (results as dynamic).isNotEmpty;
    if (!hasAnyResult) {
      return Center(
        child: Text(
          'No results found',
          style: AppTypography.textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.sm),

        // -----------------------------------------------------------
        // Songs
        // -----------------------------------------------------------
        if (results.songs.isNotEmpty) ...[
          const _SectionHeader(title: 'Songs'),
          const SizedBox(height: AppSpacing.sm),
          ...results.songs.map(
            (song) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SongCard(
                song: song,
                onTap: () {},
              ),
            ),
          ),
        ],

        // -----------------------------------------------------------
        // Artists
        // -----------------------------------------------------------
        if (results.artists.isNotEmpty) ...[
          const _SectionHeader(title: 'Artists'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: results.artists.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  ArtistCard(artist: results.artists[index]),
            ),
          ),
        ],

        // -----------------------------------------------------------
        // Albums
        // -----------------------------------------------------------
        if (results.albums.isNotEmpty) ...[
          const _SectionHeader(title: 'Albums'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: results.albums.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => SizedBox(
                width: 160,
                child: AlbumCard(
                  album: results.albums[index],
                  onTap: () {},
                ),
              ),
            ),
          ),
        ],

        // -----------------------------------------------------------
        // Playlists
        // -----------------------------------------------------------
        if (results.playlists.isNotEmpty) ...[
          const _SectionHeader(title: 'Playlists'),
          const SizedBox(height: AppSpacing.sm),
          ...results.playlists.map(
            (playlist) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PlaylistCard(
                playlist: playlist,
                onTap: () {},
              ),
            ),
          ),
        ],

        const SizedBox(height: 72),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.textTheme.titleMedium,
    );
  }
}