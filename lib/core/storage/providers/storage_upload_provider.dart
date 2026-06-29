import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../errors/storage_upload_exceptions.dart';
import '../storage_upload_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/auth/presentation/providers/auth_state.dart';
import '../../../core/services/providers/service_providers.dart';

/// Immutable state exposed by Riverpod.
class StorageUploadState {
  final UploadProgress progress;

  const StorageUploadState({required this.progress});

  factory StorageUploadState.initial() =>
      const StorageUploadState(progress: UploadProgress.idle());

  StorageUploadState copyWith({UploadProgress? progress}) {
    return StorageUploadState(progress: progress ?? this.progress);
  }
}

class StorageUploadController extends StateNotifier<StorageUploadState> {
  final StorageUploadService _service;
  final Ref _ref;

  UploadCancellationToken? _token;

  StorageUploadController({
    required StorageUploadService service,
    required Ref ref,
  })  : _service = service,
        _ref = ref,
        super(StorageUploadState.initial());

  Future<String> uploadAudio(File file) async {
    // Cancel any in-flight upload.
    cancel();

    final token = UploadCancellationToken();
    _token = token;

    state = state.copyWith(
      progress: state.progress.copyWith(status: UploadStatus.uploading, progress: 0),
    );

    try {
      final url = await _service.uploadAudio(
        file,
        cancellationToken: token,
        onProgress: (p) {
          state = state.copyWith(
            progress: state.progress.copyWith(
              progress: p.toDouble(),
              status: UploadStatus.uploading,
              error: null,
              downloadUrl: null,
            ),
          );
        },
      );

      if (token.isCancelled) {
        state = state.copyWith(
          progress: state.progress.copyWith(
            status: UploadStatus.cancelled,
            error: const StorageCancelledException(message: 'Upload cancelled.'),
          ),
        );
        throw const StorageCancelledException(message: 'Upload cancelled.');
      }

      state = state.copyWith(
        progress: state.progress.copyWith(
          status: UploadStatus.success,
          progress: 100,
          downloadUrl: url,
          error: null,
        ),
      );
      return url;
    } on StorageUploadException catch (e) {
      final status = switch (e) {
        StorageCancelledException() => UploadStatus.cancelled,
        _ => UploadStatus.failed,
      };

      state = state.copyWith(
        progress: state.progress.copyWith(
          status: status,
          error: e,
        ),
      );
      rethrow;
    } on Object catch (e) {
      state = state.copyWith(
        progress: state.progress.copyWith(
          status: UploadStatus.failed,
          error: e,
        ),
      );
      throw StorageUnknownException(message: 'Upload failed.');
    }
  }

  Future<String> uploadImage(File file) async {
    cancel();

    final token = UploadCancellationToken();
    _token = token;

    state = state.copyWith(
      progress: state.progress.copyWith(status: UploadStatus.uploading, progress: 0),
    );

    try {
      final url = await _service.uploadImage(
        file,
        cancellationToken: token,
        onProgress: (p) {
          state = state.copyWith(
            progress: state.progress.copyWith(
              progress: p.toDouble(),
              status: UploadStatus.uploading,
              error: null,
              downloadUrl: null,
            ),
          );
        },
      );

      if (token.isCancelled) {
        state = state.copyWith(
          progress: state.progress.copyWith(
            status: UploadStatus.cancelled,
            error: const StorageCancelledException(message: 'Upload cancelled.'),
          ),
        );
        throw const StorageCancelledException(message: 'Upload cancelled.');
      }

      state = state.copyWith(
        progress: state.progress.copyWith(
          status: UploadStatus.success,
          progress: 100,
          downloadUrl: url,
          error: null,
        ),
      );
      return url;
    } on StorageUploadException catch (e) {
      final status = switch (e) {
        StorageCancelledException() => UploadStatus.cancelled,
        _ => UploadStatus.failed,
      };

      state = state.copyWith(
        progress: state.progress.copyWith(
          status: status,
          error: e,
        ),
      );
      rethrow;
    } on Object catch (e) {
      state = state.copyWith(
        progress: state.progress.copyWith(
          status: UploadStatus.failed,
          error: e,
        ),
      );
      throw StorageUnknownException(message: 'Upload failed.');
    }
  }

  void cancel() {
    _token?.cancel();
    _token = null;

    state = state.copyWith(
      progress: state.progress.copyWith(
        status: UploadStatus.cancelled,
        error: const StorageCancelledException(message: 'Upload cancelled.'),
      ),
    );
  }
}

/// Provider that exposes the upload controller + reactive upload state.
final storageUploadProvider = StateNotifierProvider<
    StorageUploadController, StorageUploadState>((ref) {
  final authState = ref.watch(authStateProvider);

  // Use existing StorageService abstraction (currently mock).
  // Later: swap this injection to a real Firebase Storage implementation
  // by updating StorageAdapter and wiring the uploadFile/getDownloadUrl.
  final storageService = ref.watch(storageServiceProvider);

  Future<Option<String>> getAuthenticatedUserId() async {
    return authState is AuthStateAuthenticated
        ? Some((authState as AuthStateAuthenticated).user.id)
        : const None();
  }

  Future<void> deleteFileByDownloadUrl(String downloadUrl) async {
    // Storage layer currently doesn't support deletions; safe no-op.
    // Implement once firebase storage delete is wired.
  }

  final service = StorageUploadService(
    getAuthenticatedUserId: getAuthenticatedUserId,
    uploadFile: storageService.uploadFile,
    getDownloadUrl: storageService.getDownloadUrl,
    deleteFile: deleteFileByDownloadUrl,
  );


  return StorageUploadController(service: service, ref: ref);
});

