import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Repository interface for music data.
///
/// Single source of truth for all music-related data access.
/// All features (Home, Player, Search, etc.) consume data through this.
abstract class MusicRepository {
  Future<List<Song>> getSongs();
  Future<List<Album>> getAlbums();
  Future<List<Artist>> getArtists();
  Future<List<Playlist>> getPlaylists();
  Future<List<Genre>> getGenres();
  Future<List<Song>> getRecentlyPlayed();
  Future<List<Song>> getTrendingSongs();
  Future<List<Album>> getNewReleases();
}

