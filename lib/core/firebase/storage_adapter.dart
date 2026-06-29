import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Production Firebase Storage adapter.
///
/// This adapter is the single entry point for Firebase Storage operations.
/// Higher layers should not depend on `firebase_storage` directly.
class StorageAdapter {
  StorageAdapter({
    FirebaseStorage? firebaseStorage,
  }) : _storage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads a local file to [remotePath] and returns the download URL.
  Future<String> uploadFile({
    required File file,
    required String remotePath,
    required String contentType,
    void Function(int bytesSent, int bytesTotal)? onProgress,
  }) async {
    final ref = _storage.ref(remotePath);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snap) {
        onProgress(snap.bytesTransferred, snap.totalBytes);
      });
    }

    await uploadTask;
    return ref.getDownloadURL();
  }

  /// Downloads a file.
  ///
  /// NOTE: Currently unused by the upload flow.
  Future<String> downloadFile({
    required String remotePath,
    required String localPath,
  }) async {
    final ref = _storage.ref(remotePath);
    final url = await ref.getDownloadURL();
    return url;
  }

  /// Gets the download URL for [remotePath].
  Future<String> getDownloadUrl({required String remotePath}) async {
    final ref = _storage.ref(remotePath);
    return ref.getDownloadURL();
  }

  /// Deletes the remote file.
  Future<void> deleteFile({required String remotePath}) async {
    final ref = _storage.ref(remotePath);
    await ref.delete();
  }

  /// Helper for mapping an authentication result to a userId.
  ///
  /// Kept here so higher layers can stay storage-agnostic.
  Future<Option<String>> emptyUserId() async => const None();
}

