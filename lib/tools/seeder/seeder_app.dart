import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:echo/core/firebase/firebase_initializer.dart';
import 'package:echo/core/firebase/firestore_adapter.dart';
import 'package:echo/tools/seeder/music_seed_repository.dart';
import 'package:echo/tools/seeder/seed_data.dart';

class SeederApp extends StatelessWidget {
  const SeederApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _SeederPage(),
    );
  }
}

class _SeederPage extends StatefulWidget {
  const _SeederPage();

  @override
  State<_SeederPage> createState() => _SeederPageState();
}

class _SeederPageState extends State<_SeederPage> {
  String _status = 'Seeding Firestore...';

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Default: overwrite=false
    const overwrite = false;

    try {
      // Generate deterministic entities
      final seedData = SeedData();
      final repo = MusicSeedRepository(firestore: FirestoreAdapter());

      final genres = seedData.generateGenres(count: 10);
      final artists = seedData.generateArtists(count: 20);
      final albums = seedData.generateAlbums(artists: artists, count: 20);
      final songs = seedData.generateSongs(albums: albums, songsPerAlbum: 5);
      final playlists =
          seedData.generatePlaylists(songs: songs, playlistCount: 15);
      final playlistSongIds = seedData.pickPlaylistSongIds(
        songs: songs,
        playlistCount: playlists.length,
      );

      // Dependency order: Genres -> Artists -> Albums -> Songs -> Playlists
      await repo.seedGenres(genres: genres, overwrite: overwrite);
      // ignore: avoid_print
      print('✓ Genres');

      await repo.seedArtists(artists: artists, overwrite: overwrite);
      // ignore: avoid_print
      print('✓ Artists');

      await repo.seedAlbums(albums: albums, overwrite: overwrite);
      // ignore: avoid_print
      print('✓ Albums');

      await repo.seedSongs(songs: songs, overwrite: overwrite);
      // ignore: avoid_print
      print('✓ Songs');

      await repo.seedPlaylists(
        playlists: playlists,
        playlistSongIds: playlistSongIds,
        overwrite: overwrite,
      );
      // ignore: avoid_print
      print('✓ Playlists');

      // ignore: avoid_print
      print('Seeder completed successfully.');

      if (!mounted) return;
      setState(() {
        _status = 'Seeder completed successfully.';
      });

      // Give the user time to read the success message.
      await Future<void>.delayed(const Duration(seconds: 2));

      // Graceful shutdown isn't available across all Flutter targets for this tool,
      // so use process exit to ensure the seeder doesn't keep running.
      if (mounted) return;
      exit(0);
    } catch (e, st) {
      // Print full exception + stack trace.
      // ignore: avoid_print
      print('Seeder failed: $e');
      // ignore: avoid_print
      print(st);

      if (!mounted) return;
      setState(() {
        _status = 'Seeder failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.init();
  runApp(const SeederApp());
}

