import 'favorite_song.dart';
import 'favorite_album.dart';
import 'favorite_artist.dart';
import 'downloaded_song.dart';
import 'recently_played.dart';
import 'collection.dart';

/// Represents the complete user music library.
class UserLibrary {
  final List<FavoriteSong> favoriteSongs;
  final List<FavoriteAlbum> favoriteAlbums;
  final List<FavoriteArtist> favoriteArtists;
  final List<DownloadedSong> downloadedSongs;
  final List<RecentlyPlayed> recentlyPlayed;
  final List<Collection> collections;

  const UserLibrary({
    this.favoriteSongs = const [],
    this.favoriteAlbums = const [],
    this.favoriteArtists = const [],
    this.downloadedSongs = const [],
    this.recentlyPlayed = const [],
    this.collections = const [],
  });

  UserLibrary copyWith({
    List<FavoriteSong>? favoriteSongs,
    List<FavoriteAlbum>? favoriteAlbums,
    List<FavoriteArtist>? favoriteArtists,
    List<DownloadedSong>? downloadedSongs,
    List<RecentlyPlayed>? recentlyPlayed,
    List<Collection>? collections,
  }) {
    return UserLibrary(
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      favoriteAlbums: favoriteAlbums ?? this.favoriteAlbums,
      favoriteArtists: favoriteArtists ?? this.favoriteArtists,
      downloadedSongs: downloadedSongs ?? this.downloadedSongs,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      collections: collections ?? this.collections,
    );
  }
}