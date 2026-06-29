import 'package:echo/core/firebase/firestore_adapter.dart';

/// Datasource responsible for Firestore writes for song publication.
class SongUploadDatasource {
  final FirestoreAdapter _firestore;

  const SongUploadDatasource({
    required FirestoreAdapter firestore,
  }) : _firestore = firestore;

  /// Creates the Firestore song document at `songs/{songId}`.
  Future<void> createSongDocument({
    required String songId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('songs').doc(songId).set(data);
  }
}

