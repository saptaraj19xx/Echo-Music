import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage_upload_service.dart';

import 'firebase_storage_upload_service_provider.dart';

/// Provider exposing a stable [StorageUploadService] instance.
///
/// NOTE: This file intentionally delegates to the Firebase-backed provider.
/// This ensures there is exactly one production storage implementation.
final storageUploadServiceProvider = Provider<StorageUploadService>((ref) {
  return ref.watch(firebaseStorageUploadServiceProvider);
});
