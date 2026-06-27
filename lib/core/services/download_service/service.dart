import 'dart:async';

/// Represents the progress of a download operation.
class DownloadProgress {
  /// Identifier for the song being downloaded.
  final String songId;

  /// 0.0 to 1.0
  final double progress;

  /// Bytes downloaded so far (mocked).
  final int downloadedBytes;

  /// Total bytes (mocked).
  final int totalBytes;

  /// Current download state.
  final DownloadStatus status;

  const DownloadProgress({
    required this.songId,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = DownloadStatus.downloading,
  });
}

/// Enum representing the status of a download.
enum DownloadStatus {
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Service for managing music downloads.
///
/// Purpose:
/// - Provide a stable API for download orchestration.
///
/// Future production implementation:
/// - Replace [MockDownloadService] with an implementation that downloads
///   files and persists them (no filesystem access in Sprint 11).
///
/// Current mock limitations:
/// - No real downloads are performed.
/// - Progress is simulated in memory.
abstract class DownloadService {
  /// Starts downloading a song.
  Future<void> downloadSong(String songId, String audioUrl);

  /// Cancels an ongoing download.
  Future<void> cancelDownload(String songId);

  /// Removes a downloaded file.
  Future<void> removeDownload(String songId);

  /// Stream of download progress updates.
  Stream<DownloadProgress> downloadProgress();
}

