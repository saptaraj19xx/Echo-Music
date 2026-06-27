import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Centralized mock data source for all music-related features.
///
/// Single source of truth — both Home and Player (and future features)
/// consume data from this class instead of feature-specific mocks.
class MockMusicDataSource {
  // ---------------------------------------------------------------------------
  // Artists
  // ---------------------------------------------------------------------------
  static const List<Artist> artists = [
    Artist(id: 'artist-1', name: 'Aurora', imageUrl: null, monthlyListeners: 4_200_000, isVerified: true),
    Artist(id: 'artist-2', name: 'Neon Waves', imageUrl: null, monthlyListeners: 1_800_000, isVerified: true),
    Artist(id: 'artist-3', name: 'Luna Eclipse', imageUrl: null, monthlyListeners: 3_100_000, isVerified: true),
    Artist(id: 'artist-4', name: 'Solar Drift', imageUrl: null, monthlyListeners: 890_000, isVerified: false),
    Artist(id: 'artist-5', name: 'Midnight Echo', imageUrl: null, monthlyListeners: 6_500_000, isVerified: true),
  ];

  // ---------------------------------------------------------------------------
  // Albums
  // ---------------------------------------------------------------------------
  static const List<Album> albums = [
    Album(id: 'album-1', title: 'Starlight Symphony', artistId: 'artist-1', artistName: 'Aurora', coverUrl: null, releaseYear: 2025, songCount: 12),
    Album(id: 'album-2', title: 'Digital Horizons', artistId: 'artist-2', artistName: 'Neon Waves', coverUrl: null, releaseYear: 2025, songCount: 10),
    Album(id: 'album-3', title: 'Celestial Dreams', artistId: 'artist-3', artistName: 'Luna Eclipse', coverUrl: null, releaseYear: 2024, songCount: 14),
    Album(id: 'album-4', title: 'Solar Flare', artistId: 'artist-4', artistName: 'Solar Drift', coverUrl: null, releaseYear: 2025, songCount: 8),
    Album(id: 'album-5', title: 'Phantom Frequencies', artistId: 'artist-5', artistName: 'Midnight Echo', coverUrl: null, releaseYear: 2025, songCount: 16),
  ];

  // ---------------------------------------------------------------------------
  // Songs
  // ---------------------------------------------------------------------------
  static const List<Song> songs = [
    Song(id: 'song-1', title: 'Aurora Borealis', artistId: 'artist-1', artistName: 'Aurora', albumId: 'album-1', albumTitle: 'Starlight Symphony', albumArtUrl: null, duration: Duration(seconds: 214), isExplicit: false, trackNumber: 1),
    Song(id: 'song-2', title: 'Cosmic Drift', artistId: 'artist-1', artistName: 'Aurora', albumId: 'album-1', albumTitle: 'Starlight Symphony', albumArtUrl: null, duration: Duration(seconds: 198), isExplicit: false, trackNumber: 2),
    Song(id: 'song-3', title: 'Pulse Wave', artistId: 'artist-2', artistName: 'Neon Waves', albumId: 'album-2', albumTitle: 'Digital Horizons', albumArtUrl: null, duration: Duration(seconds: 187), isExplicit: false, trackNumber: 1),
    Song(id: 'song-4', title: 'Moonlit Serenade', artistId: 'artist-3', artistName: 'Luna Eclipse', albumId: 'album-3', albumTitle: 'Celestial Dreams', albumArtUrl: null, duration: Duration(seconds: 243), isExplicit: false, trackNumber: 1),
    Song(id: 'song-5', title: 'Heatwave', artistId: 'artist-4', artistName: 'Solar Drift', albumId: 'album-4', albumTitle: 'Solar Flare', albumArtUrl: null, duration: Duration(seconds: 176), isExplicit: false, trackNumber: 1),
    Song(id: 'song-6', title: 'Shadow Dance', artistId: 'artist-5', artistName: 'Midnight Echo', albumId: 'album-5', albumTitle: 'Phantom Frequencies', albumArtUrl: null, duration: Duration(seconds: 225), isExplicit: true, trackNumber: 1),
    Song(id: 'song-7', title: 'Starlight Reprise', artistId: 'artist-1', artistName: 'Aurora', albumId: 'album-1', albumTitle: 'Starlight Symphony', albumArtUrl: null, duration: Duration(seconds: 162), isExplicit: false, trackNumber: 3),
    Song(id: 'song-8', title: 'Neon Lights', artistId: 'artist-2', artistName: 'Neon Waves', albumId: 'album-2', albumTitle: 'Digital Horizons', albumArtUrl: null, duration: Duration(seconds: 204), isExplicit: false, trackNumber: 2),
  ];

  // ---------------------------------------------------------------------------
  // Playlists
  // ---------------------------------------------------------------------------
  static const List<Playlist> playlists = [
    Playlist(id: 'playlist-1', name: 'Chill Vibes', description: 'Relax and unwind with these smooth tracks.', coverUrl: null, ownerName: 'Echo', songCount: 25),
    Playlist(id: 'playlist-2', name: 'Focus Mode', description: 'Deep focus music for productivity.', coverUrl: null, ownerName: 'Echo', songCount: 18),
    Playlist(id: 'playlist-3', name: 'Workout Energy', description: 'High-energy tracks to power your workout.', coverUrl: null, ownerName: 'Echo', songCount: 30),
    Playlist(id: 'playlist-4', name: 'Late Night Drive', description: 'Perfect soundtrack for a night drive.', coverUrl: null, ownerName: 'Echo', songCount: 20),
    Playlist(id: 'playlist-5', name: 'Discover Weekly', description: 'Your weekly dose of new music.', coverUrl: null, ownerName: 'Echo', songCount: 15),
    Playlist(id: 'playlist-6', name: 'Throwback Hits', description: 'Classic hits from the past.', coverUrl: null, ownerName: 'Echo', songCount: 40),
  ];

  // ---------------------------------------------------------------------------
  // Genres
  // ---------------------------------------------------------------------------
  static const List<Genre> genres = [
    Genre(id: 'genre-1', name: 'Pop', colorValue: 0xFFE91E63),
    Genre(id: 'genre-2', name: 'Hip Hop', colorValue: 0xFFFF9800),
    Genre(id: 'genre-3', name: 'Rock', colorValue: 0xFF4CAF50),
    Genre(id: 'genre-4', name: 'Electronic', colorValue: 0xFF00BCD4),
    Genre(id: 'genre-5', name: 'Jazz', colorValue: 0xFF9C27B0),
    Genre(id: 'genre-6', name: 'Classical', colorValue: 0xFF3F51B5),
    Genre(id: 'genre-7', name: 'R&B', colorValue: 0xFFF44336),
    Genre(id: 'genre-8', name: 'Indie', colorValue: 0xFF607D8B),
    Genre(id: 'genre-9', name: 'Metal', colorValue: 0xFF795548),
    Genre(id: 'genre-10', name: 'Country', colorValue: 0xFF8BC34A),
  ];

  // ---------------------------------------------------------------------------
  // Convenience methods
  // ---------------------------------------------------------------------------
  List<Song> get recentlyPlayed => songs.take(4).toList();
  List<Playlist> get madeForYou => playlists.take(3).toList();
  List<Song> get trendingNow => songs.reversed.take(5).toList();
  List<Album> get newReleases => albums.take(4).toList();
  List<Playlist> get continueListening => playlists.skip(3).take(3).toList();
}