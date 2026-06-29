import 'package:echo/features/player/domain/entities/queue_item.dart';

/// Manages the playback queue state and operations.
class PlaybackQueue {
  final List<QueueItem> items;
  final int currentIndex;

  const PlaybackQueue({
    required this.items,
    required this.currentIndex,
  });

  PlaybackQueue copyWith({
    List<QueueItem>? items,
    int? currentIndex,
  }) {
    return PlaybackQueue(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  QueueItem? get currentItem {
    if (currentIndex >= 0 && currentIndex < items.length) {
      return items[currentIndex];
    }
    return null;
  }

  int get length => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get hasNext => currentIndex < items.length - 1;

  bool get hasPrevious => currentIndex > 0;
}