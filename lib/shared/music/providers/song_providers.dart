import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/core/firebase/providers/firestore_adapter_provider.dart';
import 'package:echo/shared/music/data/song_repository.dart';
import 'package:echo/shared/music/data/song_repository_impl.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Riverpod provider for Firestore-backed realtime songs.
final liveSongsProvider = StreamProvider<List<Song>>((ref) {
  final firestore = ref.watch(firestoreAdapterProvider);

  final repo = SongRepositoryImpl(firestore: firestore);
  return repo.watchSongs();
});

