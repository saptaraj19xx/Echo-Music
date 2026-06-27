import 'package:echo/shared/music/domain/song.dart';

/// Represents an item in the playback queue.
class QueueItem {
  final Song song;
  final bool isPlaying;

  const QueueItem({
    required this.song,
    this.isPlaying = false,
  });

  QueueItem copyWith({
    Song? song,
    bool? isPlaying,
  }) {
    return QueueItem(
      song: song ?? this.song,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}