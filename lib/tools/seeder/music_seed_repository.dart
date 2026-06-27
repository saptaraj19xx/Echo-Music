import 'dart:math';

import 'package:echo/core/firebase/firestore_adapter.dart';
import 'package:echo/shared/music/data/mappers/album_mapper.dart';
import 'package:echo/shared/music/data/mappers/artist_mapper.dart';
import 'package:echo/shared/music/data/mappers/genre_mapper.dart';
import 'package:echo/shared/music/data/mappers/playlist_mapper.dart';
import 'package:echo/shared/music/data/mappers/song_mapper.dart';
import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Firestore write repository for development seeding.
///
/// Constraint: use [FirestoreAdapter] exclusively.
class MusicSeedRepository {
  MusicSeedRepository({FirestoreAdapter? firestore})
      : _firestore = firestore ?? FirestoreAdapter();

  final FirestoreAdapter _firestore;

  // ---- Collection paths ----
  static const String _genresPath = 'genres';
  static const String _artistsPath = 'artists';
  static const String _albumsPath = 'albums';
  static const String _songsPath = 'songs';
  static const String _playlistsPath = 'playlists';

  String _playlistSongsSubcollectionPath(String playlistId) =>
      '$_playlistsPath/$playlistId/songs';

  // ---- Helpers ----
  Future<bool> docExists(String collectionPath, String docId) async {
    final data = await _firestore.getDoc(collectionPath, docId);
    return data != null;
  }

  Future<void> upsertDocIfNeeded({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
    required bool overwrite,
  }) async {
    final exists = await docExists(collectionPath, docId);
    if (exists && !overwrite) return;

    await _firestore.collection(collectionPath).doc(docId).set(data);
  }

  // ---- Map writers ----
  // Note: We reuse existing mappers by ensuring field names match their
  // fromMap expectations.

  Map<String, dynamic> _genreToMap(Genre g) => {
        'id': g.id,
        'name': g.name,
        'colorValue': g.colorValue,
        'imageUrl': g.imageUrl,
      };

  Map<String, dynamic> _artistToMap(Artist a) => {
        'id': a.id,
        'name': a.name,
        'imageUrl': a.imageUrl,
        'bio': a.bio,
        'monthlyListeners': a.monthlyListeners,
        'isVerified': a.isVerified,
      };

  Map<String, dynamic> _albumToMap(Album a) => {
        'id': a.id,
        'title': a.title,
        'artistId': a.artistId,
        'artistName': a.artistName,
        'coverUrl': a.coverUrl,
        'releaseYear': a.releaseYear,
        'songCount': a.songCount,
        'label': a.label,
      };

  Map<String, dynamic> _songToMap(Song s) => {
        'id': s.id,
        'title': s.title,
        'artistId': s.artistId,
        'artistName': s.artistName,
        'albumId': s.albumId,
        'albumTitle': s.albumTitle,
        'albumArtUrl': s.albumArtUrl,
        'durationSeconds': s.duration.inSeconds,
        'audioUrl': s.audioUrl,
        'isExplicit': s.isExplicit,
        'trackNumber': s.trackNumber,
      };

  Map<String, dynamic> _playlistToMap(Playlist p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'coverUrl': p.coverUrl,
        'ownerName': p.ownerName,
        'songCount': p.songCount,
        'totalDurationSeconds': p.totalDuration.inSeconds,
        'isCollaborative': p.isCollaborative,
      };

  // ---- Public API ----
  Future<void> seedGenres({
    required List<Genre> genres,
    required bool overwrite,
  }) async {
    final mapper = const GenreMapper();
    for (final g in genres) {
      mapper.fromMap(_genreToMap(g), id: g.id);
      await upsertDocIfNeeded(
        collectionPath: _genresPath,
        docId: g.id,
        data: _genreToMap(g),
        overwrite: overwrite,
      );
    }
  }

  Future<void> seedArtists({
    required List<Artist> artists,
    required bool overwrite,
  }) async {
    final mapper = const ArtistMapper();
    for (final a in artists) {
      mapper.fromMap(_artistToMap(a), id: a.id);
      await upsertDocIfNeeded(
        collectionPath: _artistsPath,
        docId: a.id,
        data: _artistToMap(a),
        overwrite: overwrite,
      );
    }
  }

  Future<void> seedAlbums({
    required List<Album> albums,
    required bool overwrite,
  }) async {
    final mapper = const AlbumMapper();
    for (final a in albums) {
      mapper.fromMap(_albumToMap(a), id: a.id);
      await upsertDocIfNeeded(
        collectionPath: _albumsPath,
        docId: a.id,
        data: _albumToMap(a),
        overwrite: overwrite,
      );
    }
  }

  Future<void> seedSongs({
    required List<Song> songs,
    required bool overwrite,
  }) async {
    final mapper = const SongMapper();
    for (final s in songs) {
      mapper.fromMap(_songToMap(s), id: s.id);
      await upsertDocIfNeeded(
        collectionPath: _songsPath,
        docId: s.id,
        data: _songToMap(s),
        overwrite: overwrite,
      );
    }
  }

  Future<void> seedPlaylists({
    required List<Playlist> playlists,
    required List<List<String>> playlistSongIds,
    required bool overwrite,
  }) async {
    final rng = Random(42);
    final mapper = const PlaylistMapper();

    for (int i = 0; i < playlists.length; i++) {
      final p = playlists[i];
      final songIds = playlistSongIds[i];

      final data = _playlistToMap(p);
      mapper.fromMap(data, id: p.id);

      await upsertDocIfNeeded(
        collectionPath: _playlistsPath,
        docId: p.id,
        data: data,
        overwrite: overwrite,
      );

      final sub = _playlistSongsSubcollectionPath(p.id);

      for (final songId in songIds) {
        final exists = await docExists(sub, songId);
        if (exists && !overwrite) continue;

        await _firestore.collection(sub).doc(songId).set({
          // playlists store songIds only (idempotent sub-doc)
          'songId': songId,
          'index': rng.nextInt(1 << 30),
        });
      }
    }
  }
}

