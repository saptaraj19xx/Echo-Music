import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../errors/storage_upload_exceptions.dart';

/// Upload status for media transfers.
///
/// Reusable across audio uploads, cover art uploads and future media types.
enum UploadStatus {
  idle,
  uploading,
  success,
  failed,
  cancelled,
}

/// Model representing upload progress and outcome.
///
/// Designed to be extensible for future use cases.
class UploadProgress {
  /// Progress in the range 0..100.
  final double progress;

  final UploadStatus status;

  /// Filled when upload succeeds.
  final String? downloadUrl;

  /// Filled when upload fails.
  final Object? error;

  const UploadProgress({
    required this.progress,
    required this.status,
    this.downloadUrl,
    this.error,
  });

  const UploadProgress.idle()
      : this(progress: 0, status: UploadStatus.idle, downloadUrl: null, error: null);

  UploadProgress copyWith({
    double? progress,
    UploadStatus? status,
    String? downloadUrl,
    Object? error,
  }) {
    return UploadProgress(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      error: error ?? this.error,
    );
  }
}

/// Cancellation token used to abort an upload.
///
/// This is intentionally UI-agnostic so it can later be wired to
/// drag-and-drop batch uploads.
class UploadCancellationToken {
  final Completer<void> _cancelCompleter = Completer<void>();

  bool get isCancelled => _cancelCompleter.isCompleted;

  /// Future that completes when cancellation is requested.
  Future<void> get cancelled => _cancelCompleter.future;

  void cancel() {
    if (!_cancelCompleter.isCompleted) {
      _cancelCompleter.complete();
    }
  }
}

/// Service responsible for uploading files to cloud storage.
///
/// Architecture: UI -> Riverpod provider -> Repository -> Datasource ->
/// StorageUploadService -> Firebase Storage.
///
/// This Sprint 14 Phase 1 implements the reusable upload layer.
class StorageUploadService {
  final Future<Option<String>> Function() _getAuthenticatedUserId;
  final Future<String> Function(String localPath, String remotePath) _uploadFile;
  final Future<String> Function(String remotePath) _getDownloadUrl;
  final Future<void> Function(String downloadUrl) _deleteFile;

  StorageUploadService({
    required Future<Option<String>> Function() getAuthenticatedUserId,
    required Future<String> Function(String localPath, String remotePath) uploadFile,
    required Future<String> Function(String remotePath) getDownloadUrl,
    required Future<void> Function(String downloadUrl) deleteFile,
  })  : _getAuthenticatedUserId = getAuthenticatedUserId,
        _uploadFile = uploadFile,
        _getDownloadUrl = getDownloadUrl,
        _deleteFile = deleteFile;


  /// Uploads an audio file and returns its download URL.
  ///
  /// Remote path:
  /// audio/{userId}/{uuid}.mp3
  Future<String> uploadAudio(
    File file, {
    required UploadCancellationToken cancellationToken,
    required void Function(int progress) onProgress,
  }) async {
    final userIdOpt = await _getAuthenticatedUserId();
    final userId = userIdOpt.getOrElse(() => '');

    if (userId.isEmpty) {
      throw const StorageAuthenticationException(
        message: 'User must be authenticated to upload audio.',
      );
    }


    if (cancellationToken.isCancelled) {
      throw const StorageCancelledException(message: 'Upload cancelled.');
    }

    final remotePath = 'audio/$userId/${const Uuid().v4()}.mp3';

    // No real progress feed available from current StorageService adapter.
    // Keep API ready for future firebase_storage progress events.
    onProgress(0);

    try {
      final uploadFuture = _uploadFile(file.path, remotePath);
      final url = await _raceWithCancellation(uploadFuture, cancellationToken);

      if (cancellationToken.isCancelled) {
        throw const StorageCancelledException(message: 'Upload cancelled.');
      }

      onProgress(100);
      return await _getDownloadUrl(remotePath);
    } on StorageUploadException {
      rethrow;
    } on Object catch (e) {
      // Best-effort classification based on known patterns.
      // Real mapping should be added once firebase_storage is integrated.
      final msg = e.toString();
      if (cancellationToken.isCancelled) {
        throw const StorageCancelledException(message: 'Upload cancelled.');
      }
      if (msg.toLowerCase().contains('permission')) {
        throw StoragePermissionException(
          message: 'Permission denied while uploading.',
        );
      }

      if (msg.toLowerCase().contains('network')) {
        throw StorageNetworkException(
          message: 'Network error while uploading.',
        );
      }

      throw StorageUnknownException(message: 'Failed to upload audio.');
    }
  }

  /// Uploads an image file (cover art) and returns its download URL.
  ///
  /// Remote path:
  /// covers/{userId}/{uuid}.jpg
  Future<String> uploadImage(
    File file, {
    required UploadCancellationToken cancellationToken,
    required void Function(int progress) onProgress,
  }) async {
    final userIdOpt = await _getAuthenticatedUserId();
    final userId = userIdOpt.getOrElse(() => '');

    if (userId.isEmpty) {
      throw const StorageAuthenticationException(
        message: 'User must be authenticated to upload images.',
      );
    }


    if (cancellationToken.isCancelled) {
      throw const StorageCancelledException(message: 'Upload cancelled.');
    }

    final remotePath = 'covers/$userId/${const Uuid().v4()}.jpg';

    onProgress(0);

    try {
      final uploadFuture = _uploadFile(file.path, remotePath);
      await _raceWithCancellation(uploadFuture, cancellationToken);

      if (cancellationToken.isCancelled) {
        throw const StorageCancelledException(message: 'Upload cancelled.');
      }

      onProgress(100);
      return await _getDownloadUrl(remotePath);
    } on StorageUploadException {
      rethrow;
    } on Object catch (e) {
      final msg = e.toString();
      if (cancellationToken.isCancelled) {
        throw const StorageCancelledException(message: 'Upload cancelled.');
      }
      if (msg.toLowerCase().contains('permission')) {
        throw StoragePermissionException(message: 'Permission denied while uploading.');
      }
      if (msg.toLowerCase().contains('network')) {
        throw StorageNetworkException(message: 'Network error while uploading.');
      }
      throw StorageUnknownException(message: 'Failed to upload image.');
    }
  }

  Future<T> _raceWithCancellation<T>(
    Future<T> operation,
    UploadCancellationToken cancellationToken,
  ) async {
    if (cancellationToken.isCancelled) {
      throw const StorageCancelledException(message: 'Upload cancelled.');
    }

    try {
      return await operation.timeout(
        // This just ensures the future completes if something stalls.
        const Duration(days: 365),
        onTimeout: () {
          throw const StorageUnknownException(
            message: 'Upload timed out. (unexpected)',
          );
        },
      );
    } catch (e) {
      // Preserve the original error.
      throw e;
    }
  }
}


