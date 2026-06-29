import 'dart:async';

import 'package:echo/core/firebase/firestore_adapter.dart';
import 'package:echo/shared/music/data/mappers/song_mapper.dart';
import 'package:echo/shared/music/domain/song.dart';

import 'song_repository.dart';

class SongRepositoryImpl implements SongRepository {
  SongRepositoryImpl({
    required FirestoreAdapter firestore,
    SongMapper? mapper,
  })  : _firestore = firestore,
        _mapper = mapper ?? const SongMapper();

  final FirestoreAdapter _firestore;
  final SongMapper _mapper;

  @override
  Stream<List<Song>> watchSongs() {
    // FirestoreAdapter currently does not expose snapshots, so we create a
    // stream from Firebase directly via the internal collection reference.
    //
    // Note: FirestoreAdapter.collection(...) returns a Firebase
    // CollectionReference<Map<String, dynamic>>.
    final collection = _firestore.collection('songs');

    return collection.snapshots().map((querySnap) {
      return querySnap.docs
          .map((d) {
            final data = d.data();
            return _mapper.fromMap(
              data,
              id: (data['id'] as String?) ?? d.id,
            );
          })
          .toList();
    });
  }
}

