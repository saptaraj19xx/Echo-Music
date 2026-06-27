import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Repository interface for search operations.
///
/// Search feature queries music data through this abstraction,
/// delegating to the underlying [MusicRepository].
abstract class SearchRepository {
  /// Search across all content types (songs, artists, albums, playlists).
  Future<List<dynamic>> search(String query);

  /// Search songs by query.
  Future<List<Song>> searchSongs(String query);

  /// Search artists by query.
  Future<List<Artist>> searchArtists(String query);

  /// Search albums by query.
  Future<List<Album>> searchAlbums(String query);

  /// Search playlists by query.
  Future<List<Playlist>> searchPlaylists(String query);

  /// Get recent search history.
  List<String> getRecentSearches();

  /// Get trending search terms.
  List<String> getTrendingSearches();
}

