/// Service for sharing content via system share sheet.
abstract class ShareService {
  /// Shares a song with optional text.
  Future<void> shareSong(String songTitle, String artistName, {String? text});

  /// Shares a playlist with optional text.
  Future<void> sharePlaylist(String playlistName, {String? text});

  /// Shares an album with optional text.
  Future<void> shareAlbum(String albumTitle, String artistName, {String? text});
}

/// Mock implementation of ShareService for development and testing.
///
/// Later this will use the share_plus package.
class MockShareService implements ShareService {
  @override
  Future<void> shareSong(String songTitle, String artistName, {String? text}) async {
    // Mock: no-op.
  }

  @override
  Future<void> sharePlaylist(String playlistName, {String? text}) async {
    // Mock: no-op.
  }

  @override
  Future<void> shareAlbum(String albumTitle, String artistName, {String? text}) async {
    // Mock: no-op.
  }
}