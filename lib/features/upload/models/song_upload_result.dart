/// Result returned by [SongUploadRepository] when publishing succeeds.
class SongUploadResult {
  /// Firestore document id.
  final String songId;

  /// Firebase Storage download URL for the uploaded MP3.
  final String audioUrl;

  /// Firebase Storage download URL for the uploaded cover image.
  final String coverUrl;

  /// When the song record was uploaded/created.
  final DateTime uploadedAt;

  const SongUploadResult({
    required this.songId,
    required this.audioUrl,
    required this.coverUrl,
    required this.uploadedAt,
  });
}

