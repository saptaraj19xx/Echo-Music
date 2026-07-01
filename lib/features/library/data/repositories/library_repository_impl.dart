import 'package:echo/features/library/domain/entities/favorite_song.dart';
import 'package:echo/features/library/domain/entities/favorite_album.dart';
import 'package:echo/features/library/domain/entities/favorite_artist.dart';
import 'package:echo/features/library/domain/entities/downloaded_song.dart';
import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/library/domain/entities/most_played.dart';
import 'dart:async';


import 'package:echo/features/library/domain/entities/collection.dart';
import 'package:echo/shared/music/domain/song.dart';



import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final List<FavoriteSong> _favoriteSongs = [];
  final List<FavoriteAlbum> _favoriteAlbums = [];
  final List<FavoriteArtist> _favoriteArtists = [];
  final List<DownloadedSong> _downloadedSongs = [];
  final List<RecentlyPlayed> _recentlyPlayed = [];
  final List<MostPlayed> _mostPlayed = [];
  final List<Collection> _collections = [];


  @override
  List<FavoriteSong> getFavoriteSongs() => List.unmodifiable(_favoriteSongs);

  @override
  List<FavoriteAlbum> getFavoriteAlbums() => List.unmodifiable(_favoriteAlbums);

  @override
  List<FavoriteArtist> getFavoriteArtists() => List.unmodifiable(_favoriteArtists);

  @override
  List<DownloadedSong> getDownloadedSongs() => List.unmodifiable(_downloadedSongs);

  @override
  List<RecentlyPlayed> getRecentlyPlayed() => List.unmodifiable(_recentlyPlayed);

  final StreamController<List<RecentlyPlayed>> _recentlyPlayedController =
      StreamController<List<RecentlyPlayed>>.broadcast();

  @override
  Stream<List<RecentlyPlayed>> watchRecentlyPlayed() =>
      _recentlyPlayedController.stream;


  @override
  List<Collection> getCollections() => List.unmodifiable(_collections);

  @override
  void addFavoriteSong(String songId) {
    _favoriteSongs.add(FavoriteSong(songId: songId, addedAt: DateTime.now()));
  }

  @override
  void removeFavoriteSong(String songId) {
    _favoriteSongs.removeWhere((s) => s.songId == songId);
  }

  @override
  void addFavoriteAlbum(String albumId) {
    _favoriteAlbums.add(FavoriteAlbum(albumId: albumId, addedAt: DateTime.now()));
  }

  @override
  void removeFavoriteAlbum(String albumId) {
    _favoriteAlbums.removeWhere((a) => a.albumId == albumId);
  }

  @override
  void addFavoriteArtist(String artistId) {
    _favoriteArtists
        .add(FavoriteArtist(artistId: artistId, addedAt: DateTime.now()));
  }

  @override
  void removeFavoriteArtist(String artistId) {
    _favoriteArtists.removeWhere((a) => a.artistId == artistId);
  }

  @override
  void addDownload(String songId) {
    _downloadedSongs.add(
        DownloadedSong(songId: songId, downloadedAt: DateTime.now()));
  }

  @override
  void removeDownload(String songId) {
    _downloadedSongs.removeWhere((d) => d.songId == songId);
  }

  static const int _recentlyPlayedMaxEntries = 100;

  @override
  void addRecentlyPlayed(String songId) {
    // Backward-compatible wrapper: no metadata available here.
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

    _recentlyPlayedController.add(List.unmodifiable(_recentlyPlayed));
  }



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
    _recentlyPlayedController.add(List.unmodifiable(_recentlyPlayed));
  }


  final StreamController<List<MostPlayed>> _mostPlayedController =
      StreamController<List<MostPlayed>>.broadcast();

  @override
  Stream<List<MostPlayed>> watchMostPlayed() => _mostPlayedController.stream;

  @override
  void addMostPlayedEntry({
    required String songId,
    required String title,
    required String artist,
    required String artworkUrl,
    required Duration duration,
    required DateTime lastPlayed,
  }) {
    final existing = _mostPlayed.where((m) => m.songId == songId).toList();
    final nextCount = existing.isNotEmpty ? existing.first.playCount + 1 : 1;

    _mostPlayed.removeWhere((m) => m.songId == songId);


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

    _mostPlayedController.add(List.unmodifiable(_mostPlayed));
  }

  @override
  List<Song> getRecentlyPlayedSongs() => const [];


  @override
  List<Playlist> getUserPlaylists() => const [];
}
