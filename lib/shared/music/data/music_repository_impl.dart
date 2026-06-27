import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/music_repository.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/core/firebase/firestore_adapter.dart';

import 'package:echo/shared/music/data/mock_music_datasource.dart';
import 'package:echo/shared/music/data/mappers/album_mapper.dart';
import 'package:echo/shared/music/data/mappers/artist_mapper.dart';
import 'package:echo/shared/music/data/mappers/genre_mapper.dart';
import 'package:echo/shared/music/data/mappers/playlist_mapper.dart';
import 'package:echo/shared/music/data/mappers/song_mapper.dart';

/// Implementation of [MusicRepository] backed by Firestore (Phase 3A read layer).
///
/// Note: Only Songs/Albums/Artists/Playlists/Genres are migrated in Phase 3A.
/// RecentlyPlayed/Trending/NewReleases remain mock for now to avoid write
/// requirements and maintain Sprint 12 constraints.
class MusicRepositoryImpl implements MusicRepository {
  final MockMusicDataSource _dataSource;

  final FirestoreAdapter _firestore;

  MusicRepositoryImpl(this._dataSource, {FirestoreAdapter? firestore})
      : _firestore = firestore ?? FirestoreAdapter();

  @override
  Future<List<Song>> getSongs() async {
    try {
      final docs = await _firestore.getCollection('songs');
      if (docs.isEmpty) return MockMusicDataSource.songs;

      final mapper = SongMapper();
      return docs
          .map((d) => mapper.fromMap(d, id: (d['id'] as String?) ?? (d['docId'] as String?)))
          .toList();
    } catch (_) {
      // Fallback to mock when collections/schemas are not ready.
      return MockMusicDataSource.songs;
    }
  }

  @override
  Future<List<Album>> getAlbums() async {
    try {
      final docs = await _firestore.getCollection('albums');
      if (docs.isEmpty) return MockMusicDataSource.albums;

      final mapper = AlbumMapper();
      return docs
          .map((d) => mapper.fromMap(d, id: (d['id'] as String?) ?? (d['docId'] as String?)))
          .toList();
    } catch (_) {
      return MockMusicDataSource.albums;
    }
  }

  @override
  Future<List<Artist>> getArtists() async {
    try {
      final docs = await _firestore.getCollection('artists');
      if (docs.isEmpty) return MockMusicDataSource.artists;

      final mapper = ArtistMapper();
      return docs
          .map((d) => mapper.fromMap(d, id: (d['id'] as String?) ?? (d['docId'] as String?)))
          .toList();
    } catch (_) {
      return MockMusicDataSource.artists;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    try {
      final docs = await _firestore.getCollection('playlists');
      if (docs.isEmpty) return MockMusicDataSource.playlists;

      final mapper = PlaylistMapper();
      return docs
          .map((d) => mapper.fromMap(d, id: (d['id'] as String?) ?? (d['docId'] as String?)))
          .toList();
    } catch (_) {
      return MockMusicDataSource.playlists;
    }
  }

  @override
  Future<List<Genre>> getGenres() async {
    try {
      final docs = await _firestore.getCollection('genres');
      if (docs.isEmpty) return MockMusicDataSource.genres;

      final mapper = GenreMapper();
      return docs
          .map((d) => mapper.fromMap(d, id: (d['id'] as String?) ?? (d['docId'] as String?)))
          .toList();
    } catch (_) {
      return MockMusicDataSource.genres;
    }
  }

  @override
  Future<List<Song>> getRecentlyPlayed() async => _dataSource.recentlyPlayed;

  @override
  Future<List<Song>> getTrendingSongs() async => _dataSource.trendingNow;

  @override
  Future<List<Album>> getNewReleases() async => _dataSource.newReleases;
}

