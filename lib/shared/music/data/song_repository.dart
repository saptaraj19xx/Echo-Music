import 'dart:async';

import 'package:echo/shared/music/domain/song.dart';

/// Firestore-backed realtime repository for music [Song] documents.
///
/// This is intentionally separate from [MusicRepository] to keep the existing
/// mock-backed API stable for other parts of the app.
abstract class SongRepository {
  /// Streams all songs in the `songs` collection.
  ///
  /// Real-time updates are emitted for:
  /// - new documents
  /// - deleted documents
  Stream<List<Song>> watchSongs();
}

