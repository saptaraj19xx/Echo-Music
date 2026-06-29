import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase/storage_adapter.dart';
import '../storage_upload_service.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/auth/presentation/providers/auth_state.dart';

/// Production [StorageUploadService] backed by Firebase Storage via [StorageAdapter].
final firebaseStorageUploadServiceProvider = Provider<StorageUploadService>((ref) {
  final authState = ref.watch(authStateProvider);
  final storageAdapter = StorageAdapter();

  Future<Option<String>> getAuthenticatedUserId() async {
    return authState is AuthStateAuthenticated
        ? Some((authState as AuthStateAuthenticated).user.id)
        : const None();
  }

  Future<String> uploadFile(String localPath, String remotePath) async {
    final file = File(localPath);

    final contentType = remotePath.endsWith('.mp3')
        ? 'audio/mpeg'
        : 'image/jpeg';

    return storageAdapter.uploadFile(
      file: file,
      remotePath: remotePath,
      contentType: contentType,
    );
  }

  Future<String> getDownloadUrl(String remotePath) async {
    return storageAdapter.getDownloadUrl(remotePath: remotePath);
  }

  Future<void> deleteFile(String remotePath) async {
    await storageAdapter.deleteFile(remotePath: remotePath);
  }

  return StorageUploadService(
    getAuthenticatedUserId: getAuthenticatedUserId,
    uploadFile: uploadFile,
    getDownloadUrl: getDownloadUrl,
    deleteFile: deleteFile,
  );
});

