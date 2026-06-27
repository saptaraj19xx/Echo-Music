import 'playing_song.dart';
import 'queue_item.dart';

/// Represents the overall state of the music player.
class PlaybackState {
  final PlayingSong? currentSong;
  final List<QueueItem> queue;
  final bool isPlaying;
  final bool isShuffled;
  final bool isRepeating;
  final Duration currentPosition;
  final Duration totalDuration;
  final double playbackSpeed;
  final int currentIndex;

  const PlaybackState({
    this.currentSong,
    this.queue = const [],
    this.isPlaying = false,
    this.isShuffled = false,
    this.isRepeating = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.currentIndex = -1,
  });

  QueueItem? get currentQueueItem {
    if (currentIndex >= 0 && currentIndex < queue.length) {
      return queue[currentIndex];
    }
    return null;
  }

  PlaybackState copyWith({
    PlayingSong? currentSong,
    List<QueueItem>? queue,
    bool? isPlaying,
    bool? isShuffled,
    bool? isRepeating,
    Duration? currentPosition,
    Duration? totalDuration,
    double? playbackSpeed,
    int? currentIndex,
  }) {
    return PlaybackState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffled: isShuffled ?? this.isShuffled,
      isRepeating: isRepeating ?? this.isRepeating,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}