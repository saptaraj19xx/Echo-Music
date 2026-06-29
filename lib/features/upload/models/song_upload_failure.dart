import 'package:echo/core/errors/storage_upload_exceptions.dart';

/// Typed failures for the song publishing flow.
sealed class SongUploadFailure {
  /// Human readable message.
  final String message;

  const SongUploadFailure({required this.message});
}


/// Returned when uploads succeed but Firestore write fails.
class SongUploadRollbackFailure extends SongUploadFailure {
  /// The original Firestore failure.

  final Object firestoreError;

  /// Any error that happened while attempting to delete uploaded files.
  final Object? rollbackError;

  /// URLs that were uploaded and should have been deleted.
  final String audioUrl;
  final String coverUrl;

  const SongUploadRollbackFailure({
    required this.firestoreError,
    required this.audioUrl,
    required this.coverUrl,
    this.rollbackError,
    required super.message,
  });
}

/// Returned when storage uploads fail.
class SongStorageUploadFailure extends SongUploadFailure {
  /// Typed storage exception.
  final StorageUploadException error;

  const SongStorageUploadFailure({
    required this.error,
    required super.message,
  });
}

/// Returned when the user is not authenticated.
class SongUploadAuthenticationFailure extends SongUploadFailure {
  const SongUploadAuthenticationFailure({required super.message});
}

