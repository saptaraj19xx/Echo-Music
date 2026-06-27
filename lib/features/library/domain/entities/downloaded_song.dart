/// Represents a song downloaded for offline playback.
class DownloadedSong {
  final String songId;
  final DateTime downloadedAt;
  final int sizeBytes;
  final String? localPath;

  const DownloadedSong({
    required this.songId,
    required this.downloadedAt,
    this.sizeBytes = 0,
    this.localPath,
  });
}