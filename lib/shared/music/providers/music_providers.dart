import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/shared/music/data/mock_music_datasource.dart';
import 'package:echo/shared/music/data/music_repository_impl.dart';
import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/music_repository.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';


// ---------------------------------------------------------------------------
// MusicRepository (singleton — shared across the app)
// ---------------------------------------------------------------------------
final _mockMusicDataSourceProvider = Provider<MockMusicDataSource>((ref) {
  return MockMusicDataSource();
});

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final dataSource = ref.watch(_mockMusicDataSourceProvider);
  return MusicRepositoryImpl(dataSource);
});

// ---------------------------------------------------------------------------
// Derived providers — individual async data streams
// ---------------------------------------------------------------------------
final songsProvider = FutureProvider<List<Song>>((ref) async {
  return ref.watch(musicRepositoryProvider).getSongs();
});

final albumsProvider = FutureProvider<List<Album>>((ref) async {
  return ref.watch(musicRepositoryProvider).getAlbums();
});

final artistsProvider = FutureProvider<List<Artist>>((ref) async {
  return ref.watch(musicRepositoryProvider).getArtists();
});

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  return ref.watch(musicRepositoryProvider).getPlaylists();
});

final genresProvider = FutureProvider<List<Genre>>((ref) async {
  return ref.watch(musicRepositoryProvider).getGenres();
});

final recentlyPlayedProvider = FutureProvider<List<Song>>((ref) async {
  return ref.watch(musicRepositoryProvider).getRecentlyPlayed();
});

final trendingProvider = FutureProvider<List<Song>>((ref) async {
  return ref.watch(musicRepositoryProvider).getTrendingSongs();
});

final newReleasesProvider = FutureProvider<List<Album>>((ref) async {
  return ref.watch(musicRepositoryProvider).getNewReleases();
});

// ---------------------------------------------------------------------------
// Convenience providers for Home feature sections
// ---------------------------------------------------------------------------
final userNameProvider = Provider<String>((ref) {
  return 'Guest';
});

final madeForYouProvider = FutureProvider<List<Playlist>>((ref) async {
  final playlists = await ref.watch(playlistsProvider.future);
  return playlists.take(3).toList();
});

final continueListeningProvider = FutureProvider<List<Playlist>>((ref) async {
  final playlists = await ref.watch(playlistsProvider.future);
  return playlists.skip(3).take(3).toList();
});

