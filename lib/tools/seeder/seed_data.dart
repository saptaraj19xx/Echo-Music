import 'dart:math';

import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Deterministic music data generator for the Firestore seeder.
///
/// Keeps seed output stable across runs (important for idempotency).
class SeedData {
  SeedData({this.seed = 42});

  final int seed;

  static const List<String> _genreNames = [
    'Pop',
    'Hip Hop',
    'Rock',
    'Electronic',
    'Jazz',
    'Classical',
    'R&B',
    'Indie',
    'Metal',
    'Country',
  ];

  static const List<int> _genreColors = [
    0xFFE91E63,
    0xFFFF9800,
    0xFF4CAF50,
    0xFF00BCD4,
    0xFF9C27B0,
    0xFF3F51B5,
    0xFFF44336,
    0xFF607D8B,
    0xFF795548,
    0xFF8BC34A,
  ];

  static const List<String> _artistFirst = [
    'Aurora',
    'Neon',
    'Luna',
    'Solar',
    'Midnight',
    'Nova',
    'Violet',
    'Atlas',
    'Echo',
    'Kinetic',
  ];

  static const List<String> _artistLast = [
    'Waves',
    'Eclipse',
    'Drift',
    'Pulse',
    'Reverie',
    'Horizon',
    'Comet',
    'Bloom',
    'Summit',
    'Cascades',
  ];

  static const List<String> _albumSuffix = [
    'Symphony',
    'Horizons',
    'Dreams',
    'Flare',
    'Frequencies',
    'Chronicles',
    'Wavelengths',
    'Moments',
  ];

  static const List<String> _playlistNames = [
    'Chill Vibes',
    'Focus Mode',
    'Workout Energy',
    'Late Night Drive',
    'Discover Weekly',
    'Throwback Hits',
    'Golden Hour',
    'Rainy Days',
    'Roadtrip Rhythm',
    'Late Bloomers',
    'Midnight Mix',
    'Fresh Finds',
    'Sleep Mode',
    'Wake Up Call',
    'Weekend Warriors',
  ];

  List<Genre> generateGenres({int count = 10}) {
    return List.generate(count, (i) {
      final id = 'genre-${i + 1}';
      return Genre(
        id: id,
        name: _genreNames[i],
        colorValue: _genreColors[i],
        imageUrl: null,
      );
    });
  }

  List<Artist> generateArtists({int count = 20}) {
    final rng = Random(seed);
    return List.generate(count, (i) {
      final first = _artistFirst[i % _artistFirst.length];
      final last = _artistLast[(i * 2) % _artistLast.length];
      final id = 'artist-${i + 1}';
      final monthlyListeners = 100_000 + rng.nextInt(9_900_000);
      final isVerified = i % 3 == 0;
      return Artist(
        id: id,
        name: '$first $last',
        imageUrl: null,
        monthlyListeners: monthlyListeners,
        isVerified: isVerified,
        bio: isVerified ? 'Official artist page seeded for development.' : null,
      );
    });
  }

  List<Album> generateAlbums({
    required List<Artist> artists,
    int count = 20,
    int songsPerAlbum = 5,
  }) {
    final rng = Random(seed + 1);
    return List.generate(count, (i) {
      final id = 'album-${i + 1}';
      final artist = artists[i % artists.length];
      final title =
          '${artist.name.split(' ').first} ${_albumSuffix[i % _albumSuffix.length]}';
      final releaseYear = 2020 + rng.nextInt(7);
      return Album(
        id: id,
        title: title,
        artistId: artist.id,
        artistName: artist.name,
        coverUrl: null,
        releaseYear: releaseYear,
        songCount: songsPerAlbum,
        label: i % 4 == 0 ? 'Echo Records' : null,
      );
    });
  }

  List<Song> generateSongs({
    required List<Album> albums,
    int songsPerAlbum = 5,
  }) {
    final rng = Random(seed + 2);

    final titles = [
      'Starlight',
      'Neon Pulse',
      'Velvet Night',
      'Crystal Drift',
      'Midnight Train',
      'Golden Signal',
      'Electric Bloom',
      'Solar Whisper',
      'Orbit Lines',
      'Echoes & Waves',
      'Quiet Thunder',
      'Wavelengths',
      'Cloud Atlas',
      'Radiant Memory',
      'Nova Bloom',
    ];

    var global = 0;
    final songs = <Song>[];

    for (final album in albums) {
      for (var t = 1; t <= songsPerAlbum; t++) {
        global++;
        final id = 'song-$global';
        final trackTitle = titles[(global - 1) % titles.length];
        final durationSeconds = 120 + rng.nextInt(210); // 2-5 minutes
        final isExplicit = (global % 11 == 0);

        songs.add(
          Song(
            id: id,
            title: '$trackTitle ${t == 1 ? '' : 'Pt.${t}'}'.trim(),
            artistId: album.artistId,
            artistName: album.artistName,
            albumId: album.id,
            albumTitle: album.title,
            albumArtUrl: null,
            duration: Duration(seconds: durationSeconds),
            audioUrl: null,
            isExplicit: isExplicit,
            trackNumber: t,
          ),
        );
      }
    }

    return songs;
  }

  List<Playlist> generatePlaylists({
    required List<Song> songs,
    int playlistCount = 15,
  }) {
    // 'songs' parameter reserved for future playlist duration/count realism.

    final rng = Random(seed + 3);

    return List.generate(playlistCount, (i) {
      final id = 'playlist-${i + 1}';
      final name = _playlistNames[i];
      final description =
          i % 2 == 0 ? 'Curated mix seeded for development.' : null;
      final songCount = (10 + (i % 6) * 3).toInt();
      return Playlist(
        id: id,
        name: name,
        description: description,
        coverUrl: null,
        ownerName: 'Echo',
        songCount: songCount,
        totalDuration: Duration.zero,
        isCollaborative: i % 5 == 0,
      );
    });
  }

  List<List<String>> pickPlaylistSongIds({
    required List<Song> songs,
    required int playlistCount,
  }) {
    final rng = Random(seed + 4);
    final ids = songs.map((s) => s.id).toList();

    return List.generate(playlistCount, (i) {
      final count = 10 + ((i % 6) * 3).toInt();
      final start = ((i * 7) % max(1, ids.length)).toInt();
      final selected = <String>[];
      for (var k = 0; k < count; k++) {
        selected.add(ids[(start + k) % ids.length]);
      }

      // Deterministic shuffle.
      for (var s = selected.length - 1; s > 0; s--) {
        final j = rng.nextInt(s + 1);
        final tmp = selected[s];
        selected[s] = selected[j];
        selected[j] = tmp;
      }

      return selected;
    });
  }
}

