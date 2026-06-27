import 'package:echo/core/firebase/auth_adapter.dart';
import 'package:echo/core/firebase/firestore_adapter.dart';
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
  final FavoriteAlbumMapper _favoriteAlbumMapper = FavoriteAlbumMapper();
  final FavoriteArtistMapper _favoriteArtistMapper = FavoriteArtistMapper();

  final List<FavoriteSong> _favoriteSongs = [];
  final List<FavoriteAlbum> _favoriteAlbums = [];
  final List<FavoriteArtist> _favoriteArtists = [];
  final List<DownloadedSong> _downloadedSongs = [];
  final List<RecentlyPlayed> _recentlyPlayed = [];

  String _favoritesSongsPath(String uid) => 'users/$uid/favorites/songs';
  String _favoritesAlbumsPath(String uid) => 'users/$uid/library/savedAlbums';
  String _favoritesArtistsPath(String uid) => 'users/$uid/library/followedArtists';
  String _recentlyPlayedPath(String uid) => 'users/$uid/recentlyPlayed';
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
    _addRecentlyPlayedToCache(songId);
    _addRecentlyPlayedToFirestore(songId);
  }

  void _addRecentlyPlayedToCache(String songId) {
    final now = DateTime.now();

    _recentlyPlayed.removeWhere((r) => r.songId == songId);
    _recentlyPlayed.insert(0, RecentlyPlayed(songId: songId, playedAt: now));
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed.removeRange(50, _recentlyPlayed.length);
    }
  }

  Future<void> _addRecentlyPlayedToFirestore(String songId) async {



    final uid = await _uidOrThrow();

    final now = DateTime.now();


    // Update in-memory list newest-first with max 50.
    _recentlyPlayed.removeWhere((r) => r.songId == songId);
    _recentlyPlayed.insert(0, RecentlyPlayed(songId: songId, playedAt: now));
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed.removeRange(50, _recentlyPlayed.length);
    }

    // Upsert timestamp on replay.
    await _firestore.collection(_recentlyPlayedPath(uid)).doc(songId).set(
          _recentlyPlayedMapper
              .toMap(_recentlyPlayed.firstWhere((r) => r.songId == songId)),
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
  List<Song> getRecentlyPlayedSongs() => const [];

  @override
  List<Playlist> getUserPlaylists() => const [];

}

