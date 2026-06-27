import 'dart:async';

/// Represents the progress of a download operation.
class DownloadProgress {
  final String songId;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
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
abstract class DownloadService {
  /// Starts downloading a song.
  Future<void> downloadSong(String songId, String audioUrl);

  /// Cancels an ongoing download.
  Future<void> cancelDownload(String songId);

  /// Removes a downloaded file.
  Future<void> removeDownload(String songId);

  /// Stream of download progress updates.
  Stream<DownloadProgress> get downloadProgressStream;

  /// Returns true if a song is downloaded.
  bool isDownloaded(String songId);

  /// Returns the download progress for a song.
  DownloadProgress? getProgress(String songId);
}

/// Mock implementation of DownloadService for development and testing.
///
/// Later this will handle actual file downloads and storage.
class MockDownloadService implements DownloadService {
  final _controller = StreamController<DownloadProgress>.broadcast();
  final Map<String, DownloadProgress> _downloads = {};

  @override
  Stream<DownloadProgress> get downloadProgressStream => _controller.stream;

  @override
  Future<void> downloadSong(String songId, String audioUrl) async {
    // Mock: simulate download progress
    final progress = DownloadProgress(songId: songId);
    _downloads[songId] = progress;

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      final updated = DownloadProgress(
        songId: songId,
        progress: i / 100.0,
        downloadedBytes: i * 1000,
        totalBytes: 100000,
        status: i == 100 ? DownloadStatus.completed : DownloadStatus.downloading,
      );
      _downloads[songId] = updated;
      _controller.add(updated);
    }
  }

  @override
  Future<void> cancelDownload(String songId) async {
    // Mock: cancel download
    _downloads[songId] = DownloadProgress(
      songId: songId,
      status: DownloadStatus.cancelled,
    );
    _controller.add(_downloads[songId]!);
  }

  @override
  Future<void> removeDownload(String songId) async {
    // Mock: remove download
    _downloads.remove(songId);
  }

  @override
  bool isDownloaded(String songId) {
    return _downloads[songId]?.status == DownloadStatus.completed;
  }

  @override
  DownloadProgress? getProgress(String songId) {
    return _downloads[songId];
  }
}