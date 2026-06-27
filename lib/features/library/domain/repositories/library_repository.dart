import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/library/domain/entities/favorite_song.dart';
import 'package:echo/features/library/domain/entities/favorite_album.dart';
import 'package:echo/features/library/domain/entities/favorite_artist.dart';
import 'package:echo/features/library/domain/entities/downloaded_song.dart';
import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/library/domain/entities/collection.dart';

abstract class LibraryRepository {
  List<FavoriteSong> getFavoriteSongs();
  List<FavoriteAlbum> getFavoriteAlbums();
  List<FavoriteArtist> getFavoriteArtists();
  List<DownloadedSong> getDownloadedSongs();
  List<RecentlyPlayed> getRecentlyPlayed();
  List<Collection> getCollections();

  void addFavoriteSong(String songId);
  void removeFavoriteSong(String songId);
  void addFavoriteAlbum(String albumId);
  void removeFavoriteAlbum(String albumId);
  void addFavoriteArtist(String artistId);
  void removeFavoriteArtist(String artistId);

  void addDownload(String songId);
  void removeDownload(String songId);

  void addRecentlyPlayed(String songId);

  List<Song> getFavoriteSongsSongs();
  List<Album> getFavoriteAlbumsAlbums();
  List<Artist> getFavoriteArtistsArtists();
  List<Song> getDownloadedSongsSongs();
  List<Song> getRecentlyPlayedSongs();
  List<Playlist> getUserPlaylists();
}