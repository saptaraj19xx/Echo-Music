import 'dart:async';

import 'service.dart';

/// Mock implementation of [DownloadService].
///
/// Current mock limitations:
/// - No filesystem or network access.
/// - Simulates progress in memory.
class MockDownloadService implements DownloadService {
  final _controller = StreamController<DownloadProgress>.broadcast();
  final Map<String, DownloadProgress> _downloads = {};

  bool _isCancelled(String songId) =>
      _downloads[songId]?.status == DownloadStatus.cancelled;

  @override
  Stream<DownloadProgress> downloadProgress() => _controller.stream;

  @override
  Future<void> downloadSong(String songId, String audioUrl) async {
    final initial = DownloadProgress(songId: songId);
    _downloads[songId] = initial;
    _controller.add(initial);

    for (int i = 0; i <= 100; i++) {
      if (_isCancelled(songId)) return;
      await Future.delayed(const Duration(milliseconds: 30));

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
    final updated = DownloadProgress(
      songId: songId,
      status: DownloadStatus.cancelled,
      progress: _downloads[songId]?.progress ?? 0.0,
      downloadedBytes: _downloads[songId]?.downloadedBytes ?? 0,
      totalBytes: _downloads[songId]?.totalBytes ?? 0,
    );

    _downloads[songId] = updated;
    _controller.add(updated);
  }

  @override
  Future<void> removeDownload(String songId) async {
    _downloads.remove(songId);
  }
}


