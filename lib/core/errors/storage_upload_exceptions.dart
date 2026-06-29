/// Typed exceptions for media uploads to Firebase Storage (or compatible).
///
/// NOTE: This file intentionally focuses on upload-layer failures and does not
/// include any Firestore metadata handling.

class StorageUploadException implements Exception {
  final String code;
  final String message;

  const StorageUploadException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'StorageUploadException($code): $message';
}

/// Thrown when an upload is attempted without an authenticated user.
class StorageAuthenticationException extends StorageUploadException {
  const StorageAuthenticationException({
    required super.message,
    super.code = StorageCodes.unauthenticated,
  });
}

/// Thrown when a network error occurs during upload.
class StorageNetworkException extends StorageUploadException {
  const StorageNetworkException({
    required super.message,
    super.code = StorageCodes.network,
  });
}

/// Thrown when the caller does not have permission to upload to the
/// configured storage location.
class StoragePermissionException extends StorageUploadException {
  const StoragePermissionException({
    required super.message,
    super.code = StorageCodes.permissionDenied,
  });
}

/// Thrown when an upload is cancelled.
class StorageCancelledException extends StorageUploadException {
  const StorageCancelledException({
    required super.message,
    super.code = StorageCodes.cancelled,
  });
}

/// Fallback exception for any unknown upload failure.
class StorageUnknownException extends StorageUploadException {
  const StorageUnknownException({
    required super.message,
    super.code = StorageCodes.unknown,
  });
}

/// Shared codes to keep exception mapping stable.
class StorageCodes {
  static const String unauthenticated = 'storage-unauthenticated';
  static const String network = 'storage-network-error';
  static const String permissionDenied = 'storage-permission-denied';
  static const String cancelled = 'storage-cancelled';
  static const String unknown = 'storage-unknown';
}

