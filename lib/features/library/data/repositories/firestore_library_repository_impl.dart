import 'package:echo/core/firebase/auth_adapter.dart';
import 'package:echo/core/firebase/firestore_adapter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:echo/features/library/data/mappers/favorite_album_mapper.dart';
import 'package:echo/features/library/data/mappers/favorite_artist_mapper.dart';
import 'package:echo/features/library/data/mappers/favorite_song_mapper.dart';
import 'package:echo/features/library/data/mappers/recently_played_mapper.dart';
import 'package:echo/features/library/domain/entities/favorite_album.dart';
import 'package:echo/features/library/domain/entities/favorite_artist.dart';
import 'package:echo/features/library/domain/entities/favorite_song.dart';
import 'package:echo/features/library/domain/entities/downloaded_song.dart';
import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/library/domain/entities/collection.dart';
import 'package:echo/features/library/domain/entities/most_played.dart';
import 'package:echo/features/library/data/mappers/most_played_mapper.dart';

import 'package:echo/features/library/domain/repositories/library_repository.dart';
import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';


/// Firestore-backed implementation of [LibraryRepository].
///
/// Sprint 12 Phase 4 scope: only user library write operations.
/// - favorites: add/remove/getFavoriteSongs
/// - recentlyPlayed: add (upsert timestamp) + getRecentlyPlayed
/// - followed artists: follow/unfollow (persisted)
/// - saved albums/playlists: persist add/remove
///
/// Read methods are backed by an in-memory cache because Sprint 12 Phase 4
/// explicitly focuses on writes only.
class FirestoreLibraryRepositoryImpl implements LibraryRepository {
  FirestoreLibraryRepositoryImpl({
    required AuthAdapter auth,
    required FirestoreAdapter firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final AuthAdapter _auth;
  final FirestoreAdapter _firestore;

  final FavoriteSongMapper _favoriteSongMapper = FavoriteSongMapper();
  final RecentlyPlayedMapper _recentlyPlayedMapper = RecentlyPlayedMapper();
  final MostPlayedMapper _mostPlayedMapper = MostPlayedMapper();

  final FavoriteAlbumMapper _favoriteAlbumMapper = FavoriteAlbumMapper();
  final FavoriteArtistMapper _favoriteArtistMapper = FavoriteArtistMapper();

  final List<FavoriteSong> _favoriteSongs = [];
  final List<FavoriteAlbum> _favoriteAlbums = [];
  final List<FavoriteArtist> _favoriteArtists = [];
  final List<DownloadedSong> _downloadedSongs = [];
  final List<RecentlyPlayed> _recentlyPlayed = [];
  final List<MostPlayed> _mostPlayed = [];

  String _favoritesSongsPath(String uid) => 'users/$uid/favorites/songs';

  String _favoritesAlbumsPath(String uid) => 'users/$uid/library/savedAlbums';
  String _favoritesArtistsPath(String uid) => 'users/$uid/library/followedArtists';
  String _recentlyPlayedPath(String uid) => 'users/$uid/recently_played';
  String _mostPlayedPath(String uid) => 'users/$uid/most_played';
  String _savedPlaylistsPath(String uid) => 'users/$uid/library/savedPlaylists';


  Future<String> _uidOrThrow() async {
    final user = await _auth.currentUser();
    final uid = user?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('No authenticated user.');
    }
    return uid;
  }

  @override
  List<FavoriteSong> getFavoriteSongs() => List.unmodifiable(_favoriteSongs);

  @override
  List<FavoriteAlbum> getFavoriteAlbums() => List.unmodifiable(_favoriteAlbums);

  @override
  List<FavoriteArtist> getFavoriteArtists() =>
      List.unmodifiable(_favoriteArtists);

  @override
  List<DownloadedSong> getDownloadedSongs() =>
      List.unmodifiable(_downloadedSongs);

  @override
  List<RecentlyPlayed> getRecentlyPlayed() =>
      List.unmodifiable(_recentlyPlayed);

  @override
  Stream<List<MostPlayed>> watchMostPlayed() async* {
    final uid = await _uidOrThrow();

    yield* _firestore
        .collection(_mostPlayedPath(uid))
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => _mostPlayedMapper.fromMap(doc.data()));

      final sorted = items.toList()
        ..sort(
          (a, b) {
            final byCount = b.playCount.compareTo(a.playCount);
            if (byCount != 0) return byCount;
            return b.lastPlayed.compareTo(a.lastPlayed);
          },
        );
      return sorted;
    });
  }

  @override
  Stream<List<RecentlyPlayed>> watchRecentlyPlayed() async* {
    final uid = await _uidOrThrow();


    yield* _firestore
        .collection(_recentlyPlayedPath(uid))
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => _recentlyPlayedMapper.fromMap(doc.data()));
      // Firestore has no guaranteed ordering unless stored; keep deterministic newest-first:
      final sorted = items.toList()
        ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
      return sorted;
    });
  }


  @override
  List<Collection> getCollections() => const [];


  // ----------------------------
  // Favorites: songs
  // ----------------------------
  @override
  Future<void> addFavoriteSong(String songId) async {
    final uid = await _uidOrThrow();

    // Update in-memory cache.
    _favoriteSongs.removeWhere((s) => s.songId == songId);
    _favoriteSongs.add(FavoriteSong(songId: songId, addedAt: DateTime.now()));

    final mapper = _favoriteSongMapper;
    final entity = _favoriteSongs.firstWhere((s) => s.songId == songId);

    // Write doc with deterministic id.
    await _firestore.collection(_favoritesSongsPath(uid)).doc(songId).set(
          mapper.toMap(entity),
        );
  }

  @override
  Future<void> removeFavoriteSong(String songId) async {
    final uid = await _uidOrThrow();

    _favoriteSongs.removeWhere((s) => s.songId == songId);

    await _firestore.collection(_favoritesSongsPath(uid)).doc(songId).delete();
  }

  // ----------------------------
  // Recently played
  // ----------------------------
  @override
  void addRecentlyPlayed(String songId) {
    // Backward-compatible wrapper: no metadata available here.
    // Kept for incremental migration; prefer addRecentlyPlayedEntry for new writes.
    final now = DateTime.now();
    addRecentlyPlayedEntry(
      songId: songId,
      title: '',
      artist: '',
      artworkUrl: '',
      duration: Duration.zero,
      lastPosition: Duration.zero,
      playedAt: now,
    );
  }

  @override
  void addRecentlyPlayedEntry({
    required String songId,
    required String title,
    required String artist,
    required String artworkUrl,
    required Duration duration,
    required Duration lastPosition,
    required DateTime playedAt,
  }) {
    _addRecentlyPlayedEntryToCache(
      songId: songId,
      title: title,
      artist: artist,
      artworkUrl: artworkUrl,
      duration: duration,
      lastPosition: lastPosition,
      playedAt: playedAt,
    );
    _addRecentlyPlayedEntryToFirestore(
      songId: songId,
      title: title,
      artist: artist,
      artworkUrl: artworkUrl,
      duration: duration,
      lastPosition: lastPosition,
      playedAt: playedAt,
    );
  }


  static const int _recentlyPlayedMaxEntries = 100;

  void _addRecentlyPlayedEntryToCache({
    required String songId,
    required String title,
    required String artist,
    required String artworkUrl,
    required Duration duration,
    required Duration lastPosition,
    required DateTime playedAt,
  }) {
    _recentlyPlayed.removeWhere((r) => r.songId == songId);

    _recentlyPlayed.insert(
      0,
      RecentlyPlayed(
        songId: songId,
        title: title,
        artist: artist,
        artworkUrl: artworkUrl,
        duration: duration,
        lastPosition: lastPosition,
        playedAt: playedAt,
      ),
    );

    if (_recentlyPlayed.length > _recentlyPlayedMaxEntries) {
      _recentlyPlayed.removeRange(
        _recentlyPlayedMaxEntries,
        _recentlyPlayed.length,
      );
    }
  }



  Future<void> _addRecentlyPlayedEntryToFirestore({
    required String songId,
    required String title,
    required String artist,
    required String artworkUrl,
    required Duration duration,
    required Duration lastPosition,
    required DateTime playedAt,
  }) async {

    final uid = await _uidOrThrow();

    // Ensure cache is consistent before mapping.
    _recentlyPlayed.removeWhere((r) => r.songId == songId);
    _recentlyPlayed.insert(
      0,
      RecentlyPlayed(
        songId: songId,
        title: title,
        artist: artist,
        artworkUrl: artworkUrl,
        duration: duration,
        lastPosition: lastPosition,
        playedAt: playedAt,
      ),
    );
    if (_recentlyPlayed.length > _recentlyPlayedMaxEntries) {
      _recentlyPlayed.removeRange(
        _recentlyPlayedMaxEntries,
        _recentlyPlayed.length,
      );
    }

    await _firestore
        .collection(_recentlyPlayedPath(uid))
        .doc(songId)
        .set(
          _recentlyPlayedMapper.toMap(
            _recentlyPlayed.firstWhere((r) => r.songId == songId),
          ),
        );
  }


  // Repository interface expects sync getters (read-only in-memory cache).

  // ----------------------------

  // Follow/unfollow artists
  // ----------------------------
  Future<void> followArtist(String artistId) async {



    final uid = await _uidOrThrow();

    _favoriteArtists.removeWhere((a) => a.artistId == artistId);
    _favoriteArtists.add(
      FavoriteArtist(artistId: artistId, addedAt: DateTime.now()),
    );

    final entity = _favoriteArtists.firstWhere((a) => a.artistId == artistId);
    await _firestore
        .collection(_favoritesArtistsPath(uid))
        .doc(artistId)
        .set(_favoriteArtistMapper.toMap(entity));
  }

  Future<void> unfollowArtist(String artistId) async {

    final uid = await _uidOrThrow();

    _favoriteArtists.removeWhere((a) => a.artistId == artistId);
    await _firestore
        .collection(_favoritesArtistsPath(uid))
        .doc(artistId)
        .delete();
  }

  // ----------------------------
  // Saved albums
  // ----------------------------
  Future<void> saveAlbum(String albumId) async {

    final uid = await _uidOrThrow();

    _favoriteAlbums.removeWhere((a) => a.albumId == albumId);
    _favoriteAlbums.add(FavoriteAlbum(albumId: albumId, addedAt: DateTime.now()));

    final entity = _favoriteAlbums.firstWhere((a) => a.albumId == albumId);
    await _firestore
        .collection(_favoritesAlbumsPath(uid))
        .doc(albumId)
        .set(_favoriteAlbumMapper.toMap(entity));
  }

  Future<void> removeSavedAlbum(String albumId) async {

    final uid = await _uidOrThrow();

    _favoriteAlbums.removeWhere((a) => a.albumId == albumId);
    await _firestore
        .collection(_favoritesAlbumsPath(uid))
        .doc(albumId)
        .delete();
  }

  // ----------------------------
  // Saved playlists
  // ----------------------------
  Future<void> savePlaylist(String playlistId) async {

    final uid = await _uidOrThrow();

    // Reuse Collection entity list? For Sprint 12 Phase 4, keep simple in-memory no-op.
    // Persist a marker doc.
    await _firestore
        .collection(_savedPlaylistsPath(uid))
        .doc(playlistId)
        .set(<String, dynamic>{
      'playlistId': playlistId,
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeSavedPlaylist(String playlistId) async {

    final uid = await _uidOrThrow();

    await _firestore
        .collection(_savedPlaylistsPath(uid))
        .doc(playlistId)
        .delete();
  }

  // ----------------------------
  // Unchanged/inactive members required by interface
  // ----------------------------
  @override
  void addFavoriteAlbum(String albumId) => saveAlbum(albumId);

  @override
  void removeFavoriteAlbum(String albumId) => removeSavedAlbum(albumId);

  @override
  void addFavoriteArtist(String artistId) => followArtist(artistId);

  @override
  void removeFavoriteArtist(String artistId) => unfollowArtist(artistId);

  @override
  void addDownload(String songId) {
    _downloadedSongs.add(
      DownloadedSong(songId: songId, downloadedAt: DateTime.now()),
    );
  }

  @override
  void removeDownload(String songId) {
    _downloadedSongs.removeWhere((d) => d.songId == songId);
  }

  // addRecentlyPlayed handled above (sync interface) — no additional override here.



  @override
  List<Song> getFavoriteSongsSongs() => const [];

  @override
  List<Album> getFavoriteAlbumsAlbums() => const [];

  @override
  List<Artist> getFavoriteArtistsArtists() => const [];

  @override
  List<Song> getDownloadedSongsSongs() => const [];

  @override
  void removeRecentlyPlayed(String songId) {
    _recentlyPlayed.removeWhere((r) => r.songId == songId);
    _deleteFromFirestore(songId);
  }

  @override
  void addMostPlayedEntry({
    required String songId,
    required String title,
    required String artist,
    required String artworkUrl,
    required Duration duration,
    required DateTime lastPlayed,
  }) {
    // Update local cache.
    _mostPlayed.removeWhere((m) => m.songId == songId);

    final existing = _mostPlayed.where((m) => m.songId == songId);
    final nextCount = existing.isNotEmpty ? existing.first.playCount + 1 : 1;

    _mostPlayed.add(
      MostPlayed(
        songId: songId,
        playCount: nextCount,
        lastPlayed: lastPlayed,
        title: title,
        artist: artist,
        artworkUrl: artworkUrl,
        duration: duration,
      ),
    );

    _mostPlayed.sort((a, b) {
      final byCount = b.playCount.compareTo(a.playCount);
      if (byCount != 0) return byCount;
      return b.lastPlayed.compareTo(a.lastPlayed);
    });

    _addMostPlayedEntryToFirestore(
      songId: songId,
      title: title,
      artist: artist,
      artworkUrl: artworkUrl,
      duration: duration,
      lastPlayed: lastPlayed,
    );
  }

  Future<void> _addMostPlayedEntryToFirestore({
    required String songId,
    required String title,
    required String artist,
    required String artworkUrl,
    required Duration duration,
    required DateTime lastPlayed,
  }) async {
    final uid = await _uidOrThrow();

    final docRef = _firestore.collection(_mostPlayedPath(uid)).doc(songId);

    // Best-effort atomicity: we use a Firestore-side increment if supported by the adapter.
    // (This repository pattern avoids introducing new adapter APIs in this sprint.)
    await docRef.set(
      <String, dynamic>{
        'songId': songId,
        'playCount': FieldValue.increment(1),
        'lastPlayed': lastPlayed.toIso8601String(),
        'title': title,
        'artist': artist,
        'artworkUrl': artworkUrl,
        'durationMs': duration.inMilliseconds,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _deleteFromFirestore(String songId) async {

    final uid = await _uidOrThrow();
    await _firestore.collection(_recentlyPlayedPath(uid)).doc(songId).delete();
  }

  @override
  List<Song> getRecentlyPlayedSongs() => const [];

  @override
  List<Playlist> getUserPlaylists() => const [];

}

