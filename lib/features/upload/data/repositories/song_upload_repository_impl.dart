import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:echo/core/errors/storage_upload_exceptions.dart';
import 'package:echo/core/storage/storage_upload_service.dart';
import 'package:echo/features/upload/data/datasources/song_upload_datasource.dart';
import 'package:echo/features/upload/models/song_upload_failure.dart';
import 'package:echo/features/upload/models/song_upload_request.dart';
import 'package:echo/features/upload/models/song_upload_result.dart';
import 'package:echo/features/upload/repositories/song_upload_repository.dart';

/// Firestore + Storage implementation of [SongUploadRepository].
///
/// Guarantees rollback: if Firestore write fails after successful uploads,
/// it attempts to delete both uploaded files.
class SongUploadRepositoryImpl implements SongUploadRepository {
  final StorageUploadService _storage;
  final SongUploadDatasource _datasource;

  /// Delete callback used for rollback.
  final Future<void> Function(String remotePath) _deleteByRemotePath;

  final Future<String> Function(String downloadUrl) _inferRemotePath;

  SongUploadRepositoryImpl({
    required StorageUploadService storageUploadService,
    required SongUploadDatasource songUploadDatasource,
    required Future<void> Function(String remotePath) deleteByRemotePath,
    required Future<String> Function(String downloadUrl) inferRemotePath,
  })  : _storage = storageUploadService,
        _datasource = songUploadDatasource,
        _deleteByRemotePath = deleteByRemotePath,
        _inferRemotePath = inferRemotePath;

  @override
  Future<Either<SongUploadFailure, SongUploadResult>> publishSong(
    SongUploadRequest request,
  ) async {

    final uploadedAt = DateTime.now();
    final songId = const Uuid().v4();

    String? audioUrl;
    String? coverUrl;

    try {
      // Step 1: upload audio
      audioUrl = await _storage.uploadAudio(
        request.audioFile,
        cancellationToken: UploadCancellationToken(),
        onProgress: (_) {},
      );

      // Step 2: upload cover
      coverUrl = await _storage.uploadImage(
        request.coverFile,
        cancellationToken: UploadCancellationToken(),
        onProgress: (_) {},
      );

      // Step 3: create Firestore document
      final data = <String, dynamic>{
        // Canonical schema derived from Song domain model.
        // NOTE: artistId/uploadedBy are written as empty until we expose
        // authenticated user id through the StorageUploadService public API.
        'id': songId,
        'title': request.title,
        'artistId': '',
        'artistName': request.artist,




        'albumTitle': request.album,
        'genre': request.genre,
        'durationSeconds': request.duration.inSeconds,
        'audioUrl': audioUrl,
        'albumArtUrl': coverUrl,
        'isExplicit': request.explicit,
        'trackNumber': 1,
        'uploadedBy': '',
        'createdAt': uploadedAt,
        'updatedAt': uploadedAt,
        'playCount': 0,
        'likeCount': 0,
        'visibility': request.visibility,
      };

      await _datasource.createSongDocument(songId: songId, data: data);

      return Right(
        SongUploadResult(
          songId: songId,
          audioUrl: audioUrl!,
          coverUrl: coverUrl!,
          uploadedAt: uploadedAt,
        ),
      );
    } on StorageAuthenticationException catch (e) {
      return Left(
        SongUploadAuthenticationFailure(message: e.message),
      );
    } on StorageUploadException catch (e) {
      return Left(
        SongStorageUploadFailure(
          error: e,
          message: e.message,
        ),
      );
    } on Object catch (firestoreError) {
      // Rollback if we already uploaded media.
      if (audioUrl != null || coverUrl != null) {
        Object? rollbackError;
        try {
          if (audioUrl != null) {
            final audioRemote = await _inferRemotePath(audioUrl!);
            await _deleteByRemotePath(audioRemote);
          }
          if (coverUrl != null) {
            final coverRemote = await _inferRemotePath(coverUrl!);
            await _deleteByRemotePath(coverRemote);
          }
        } catch (e) {
          rollbackError = e;
        }

        return Left(
          SongUploadRollbackFailure(
            firestoreError: firestoreError,
            audioUrl: audioUrl ?? '',
            coverUrl: coverUrl ?? '',
            rollbackError: rollbackError,
            message: 'Failed to create song in Firestore; rollback attempted.',
          ),
        );
      }

      return Left(
        SongUploadRollbackFailure(
          firestoreError: firestoreError,
          audioUrl: audioUrl ?? '',
          coverUrl: coverUrl ?? '',
          message: 'Failed to create song in Firestore.',
        ),
      );
    }
  }
}

