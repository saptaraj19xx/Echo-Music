import 'dart:io';

/// Request payload for uploading and publishing a song.
class SongUploadRequest {
  /// Song metadata.
  final String title;
  final String artist;
  final String album;
  final String genre;
  final Duration duration;

  /// Media files to upload.
  final File audioFile;
  final File coverFile;

  /// Visibility of the song.
  final String visibility;

  /// Whether the content is explicit.
  final bool explicit;

  const SongUploadRequest({
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.audioFile,
    required this.coverFile,
    required this.visibility,
    required this.explicit,
  });
}

