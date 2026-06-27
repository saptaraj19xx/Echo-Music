import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/music_repository.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/search/domain/repositories/search_repository.dart';

/// Implementation of [SearchRepository] that delegates to [MusicRepository].
class SearchRepositoryImpl implements SearchRepository {
  final MusicRepository _musicRepository;

  SearchRepositoryImpl(this._musicRepository);

  @override
  Future<List<dynamic>> search(String query) async {
    final songs = await searchSongs(query);
    final artists = await searchArtists(query);
    final albums = await searchAlbums(query);
    final playlists = await searchPlaylists(query);

    return [
      ...songs,
      ...artists,
      ...albums,
      ...playlists,
    ];
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    final lowerQuery = query.toLowerCase();
    final songs = await _musicRepository.getSongs();
    return songs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artistName.toLowerCase().contains(lowerQuery) ||
          (song.albumTitle?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<Artist>> searchArtists(String query) async {
    final lowerQuery = query.toLowerCase();
    final artists = await _musicRepository.getArtists();
    return artists.where((artist) {
      return artist.name.toLowerCase().contains(lowerQuery) ||
          (artist.bio?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<Album>> searchAlbums(String query) async {
    final lowerQuery = query.toLowerCase();
    final albums = await _musicRepository.getAlbums();
    return albums.where((album) {
      return album.title.toLowerCase().contains(lowerQuery) ||
          album.artistName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Playlist>> searchPlaylists(String query) async {
    final lowerQuery = query.toLowerCase();
    final playlists = await _musicRepository.getPlaylists();
    return playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(lowerQuery) ||
          (playlist.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  List<String> getRecentSearches() {
    // Placeholder — in a real app this would use local storage.
    return const [
      'Blinding Lights',
      'The Weeknd',
      'After Hours',
      'Midnight Rain',
      'Taylor Swift',
    ];
  }

  @override
  List<String> getTrendingSearches() {
    // Placeholder — in a real app this would come from analytics or backend.
    return const [
      'Vampire',
      'Flowers',
      'Kill Bill',
      'Cruel Summer',
      'As It Was',
      'Anti-Hero',
      'Blinding Lights',
      'Shape of You',
      'Someone Like You',
      'Rolling in the Deep',
    ];
  }
}

