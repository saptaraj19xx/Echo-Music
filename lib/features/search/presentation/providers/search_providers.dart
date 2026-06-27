import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/shared/core/ui_state.dart';
import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/shared/music/providers/music_providers.dart';
import 'package:echo/features/search/data/repositories/search_repository_impl.dart';
import 'package:echo/features/search/domain/repositories/search_repository.dart';

// ---------------------------------------------------------------------------
// SearchRepository provider
// ---------------------------------------------------------------------------
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return SearchRepositoryImpl(musicRepository);
});

// ---------------------------------------------------------------------------
// Debounce timer helper
// ---------------------------------------------------------------------------
const _searchDebounce = Duration(milliseconds: 300);

// ---------------------------------------------------------------------------
// Search query provider
// ---------------------------------------------------------------------------
class SearchQueryNotifier extends StateNotifier<String> {
  Timer? _timer;

  SearchQueryNotifier() : super('');

  void updateQuery(String query) {
    _timer?.cancel();
    if (query.isEmpty) {
      state = '';
      return;
    }
    _timer = Timer(_searchDebounce, () {
      state = query;
    });
  }

  void clear() {
    _timer?.cancel();
    state = '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final searchQueryProvider = StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});

// ---------------------------------------------------------------------------
// Recent searches provider
// ---------------------------------------------------------------------------
final recentSearchesProvider = Provider<List<String>>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getRecentSearches();
});

// ---------------------------------------------------------------------------
// Trending searches provider
// ---------------------------------------------------------------------------
final trendingSearchesProvider = Provider<List<String>>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getTrendingSearches();
});

// ---------------------------------------------------------------------------
// Grouped search results provider
// ---------------------------------------------------------------------------
class SearchResults {
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;

  const SearchResults({
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
  });

  bool get isEmpty =>
      songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;

  bool get isNotEmpty =>
      songs.isNotEmpty || artists.isNotEmpty || albums.isNotEmpty || playlists.isNotEmpty;
}

final searchResultsProvider = FutureProvider<UiState<SearchResults>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return const Success(SearchResults());
  }

  try {
    final repository = ref.watch(searchRepositoryProvider);
    final rawResults = await repository.search(query);

    final songs = <Song>[];
    final artists = <Artist>[];
    final albums = <Album>[];
    final playlists = <Playlist>[];

    for (final item in rawResults) {
      if (item is Song) {
        songs.add(item);
      } else if (item is Artist) {
        artists.add(item);
      } else if (item is Album) {
        albums.add(item);
      } else if (item is Playlist) {
        playlists.add(item);
      }
    }

    return Success(SearchResults(
      songs: songs,
      artists: artists,
      albums: albums,
      playlists: playlists,
    ));
  } catch (e) {
    return Error<SearchResults>(e);
  }
});


// ---------------------------------------------------------------------------
// Boolean provider: is searching
// ---------------------------------------------------------------------------
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchQueryProvider).isNotEmpty;
});