import 'package:echo/core/firebase/firestore_adapter.dart';
import 'package:echo/core/firebase/firebase_initializer.dart';
import 'package:echo/tools/seeder/music_seed_repository.dart';
import 'package:echo/tools/seeder/seed_data.dart';

@Deprecated('Use the Flutter entrypoint: flutter run -t lib/tools/seeder/seeder_app.dart')
Future<void> main(List<String> args) async {

  // CLI args: --overwrite=true|false
  final overwrite = args
          .where((a) => a.startsWith('--overwrite='))
          .isNotEmpty
      ? (args
              .firstWhere((a) => a.startsWith('--overwrite='))
              .split('=')
              .last)
          .toLowerCase() ==
          'true'
      : false;

  await FirebaseInitializer.init();

  final repo = MusicSeedRepository(firestore: FirestoreAdapter());
  final seedData = SeedData();

  // Generate deterministic entities
  final genres = seedData.generateGenres(count: 10);
  final artists = seedData.generateArtists(count: 20);
  final albums = seedData.generateAlbums(artists: artists, count: 20);
  final songs = seedData.generateSongs(albums: albums, songsPerAlbum: 5);
  final playlists = seedData.generatePlaylists(songs: songs, playlistCount: 15);

  // Playlists store only songIds.
  final playlistSongIds = seedData.pickPlaylistSongIds(
    songs: songs,
    playlistCount: playlists.length,
  );

  // Dependency order: Genres -> Artists -> Albums -> Songs -> Playlists
  await repo.seedGenres(genres: genres, overwrite: overwrite);
  stdoutMark('Genres');

  await repo.seedArtists(artists: artists, overwrite: overwrite);
  stdoutMark('Artists');

  await repo.seedAlbums(albums: albums, overwrite: overwrite);
  stdoutMark('Albums');

  await repo.seedSongs(songs: songs, overwrite: overwrite);
  stdoutMark('Songs');

  await repo.seedPlaylists(
    playlists: playlists,
    playlistSongIds: playlistSongIds,
    overwrite: overwrite,
  );
  stdoutMark('Playlists');

  print('Seeder completed successfully.');
}

void stdoutMark(String label) {
  // ignore: avoid_print
  print('✓ $label');
}

