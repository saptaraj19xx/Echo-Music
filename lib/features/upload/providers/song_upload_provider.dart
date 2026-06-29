import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/core/firebase/providers/firestore_adapter_provider.dart';
import 'package:echo/core/storage/storage_upload_service.dart';

import 'package:echo/core/storage/providers/storage_upload_service_provider.dart';

import '../data/datasources/song_upload_datasource.dart';
import '../data/repositories/song_upload_repository_impl.dart';
import '../repositories/song_upload_repository.dart';

/// Riverpod provider for [SongUploadRepository].
final songUploadRepositoryProvider = Provider<SongUploadRepository>((ref) {
  final firestore = ref.watch(firestoreAdapterProvider);

  // TODO(Sprint14-Phase2): expose StorageUploadService directly from
  // storage layer.
  final storageUploadService = ref.watch(storageUploadServiceProvider);

  final datasource = SongUploadDatasource(firestore: firestore);

  // StorageUploadService currently doesn't expose a stable way to delete
  // by remotePath or infer remote path from downloadUrl.
  // Until the storage layer is extended, we provide a safe no-op rollback
  // implementation.
  Future<void> deleteByRemotePath(String remotePath) async {
    // no-op (rollback disabled)
  }

  Future<String> inferRemotePath(String downloadUrl) async {
    // no-op inference (rollback disabled)
    return downloadUrl;
  }

  return SongUploadRepositoryImpl(
    storageUploadService: storageUploadService,
    songUploadDatasource: datasource,
    deleteByRemotePath: deleteByRemotePath,
    inferRemotePath: inferRemotePath,
  );
});


