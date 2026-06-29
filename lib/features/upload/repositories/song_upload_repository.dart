import 'dart:io';

import 'package:dartz/dartz.dart';

import '../models/song_upload_failure.dart';
import '../models/song_upload_request.dart';
import '../models/song_upload_result.dart';

/// Repository that handles the full song publishing flow:
/// upload audio + cover, then create the Firestore song document.
abstract class SongUploadRepository {
  /// Publishes a new song.
  ///
  /// On success returns [SongUploadResult].
  /// On failure returns a typed [SongUploadFailure].
  /// Publishes a new song.
  ///
  /// Flow:
  /// 1) upload MP3,
  /// 2) upload cover,
  /// 3) create Firestore document,
  /// 4) return [SongUploadResult].
  ///
  /// Rollback (typed) happens if the Firestore creation fails.
  Future<Either<SongUploadFailure, SongUploadResult>> publishSong(
    SongUploadRequest request,
  );

}

