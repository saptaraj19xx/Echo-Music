/// Service for uploading and downloading files to/from cloud storage.
abstract class StorageService {
  /// Uploads a file to cloud storage.
  Future<String> uploadFile(String localPath, String remotePath);

  /// Downloads a file from cloud storage.
  Future<String> downloadFile(String remotePath, String localPath);

  /// Deletes a file from cloud storage.
  Future<void> deleteFile(String remotePath);

  /// Gets the download URL for a file.
  Future<String> getDownloadUrl(String remotePath);
}

/// Mock implementation of StorageService for development and testing.
///
/// Later this will connect to Firebase Storage or similar.
class MockStorageService implements StorageService {
  @override
  Future<String> uploadFile(String localPath, String remotePath) async {
    // Mock: no-op.
    return remotePath;
  }

  @override
  Future<String> downloadFile(String remotePath, String localPath) async {
    // Mock: no-op.
    return localPath;
  }

  @override
  Future<void> deleteFile(String remotePath) async {
    // Mock: no-op.
  }

  @override
  Future<String> getDownloadUrl(String remotePath) async {
    // Mock: get download URL
    return 'https://storage.example.com/$remotePath';
  }
}