import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/features/player/domain/entities/playback_queue.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Manages the playback queue state and operations.
class QueueNotifier extends StateNotifier<PlaybackQueue> {
  QueueNotifier(this._playerController) : super(const PlaybackQueue(items: [], currentIndex: -1));

  final PlayerController _playerController;

  void loadQueue(List<Song> songs, {int startIndex = 0}) {
    final items = songs.map((song) => QueueItem(song: song)).toList();
    state = state.copyWith(
      items: items,
      currentIndex: startIndex.clamp(0, items.length - 1),
    );
    if (items.isNotEmpty) {
      _playerController.playAt(startIndex);
    }
  }

  void playNext(Song song) {
    final nextIndex = state.currentIndex + 1;
    final newItems = List<QueueItem>.from(state.items);
    newItems.insert(nextIndex, QueueItem(song: song));
    state = state.copyWith(
      items: newItems,
      currentIndex: state.currentIndex,
    );
  }

  void addToQueue(Song song) {
    final newItems = List<QueueItem>.from(state.items);
    newItems.add(QueueItem(song: song));
    state = state.copyWith(items: newItems);
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    if (state.items.length == 1) {
      clear();
      return;
    }

    final newItems = List<QueueItem>.from(state.items)..removeAt(index);
    int newIndex = state.currentIndex;
    if (index < newIndex) newIndex--;
    else if (index == newIndex) newIndex = newIndex.clamp(0, newItems.length - 1);

    state = state.copyWith(
      items: newItems,
      currentIndex: newIndex,
    );

    if (index == state.currentIndex && newItems.isNotEmpty) {
      _playerController.playAt(newIndex);
    }
  }

  void clear() {
    state = const PlaybackQueue(items: [], currentIndex: -1);
    _playerController.pause();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final newItems = List<QueueItem>.from(state.items);
    final movedItem = newItems.removeAt(oldIndex);
    newItems.insert(newIndex, movedItem);

    int updatedCurrent = state.currentIndex;
    if (oldIndex == updatedCurrent) updatedCurrent = newIndex;
    else if (oldIndex < updatedCurrent && newIndex >= updatedCurrent) updatedCurrent--;
    else if (oldIndex > updatedCurrent && newIndex <= updatedCurrent) updatedCurrent++;

    state = state.copyWith(
      items: newItems,
      currentIndex: updatedCurrent,
    );
  }

  void playAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    state = state.copyWith(currentIndex: index);
    _playerController.playAt(index);
  }

  void next() {
    if (state.hasNext) {
      playAt(state.currentIndex + 1);
    }
  }

  void previous() {
    if (state.hasPrevious) {
      playAt(state.currentIndex - 1);
    }
  }
}

final queueNotifierProvider = StateNotifierProvider<QueueNotifier, PlaybackQueue>((ref) {
  return QueueNotifier(ref.watch(playerControllerProvider));
});

final hasQueueProvider = Provider<bool>((ref) {
  final queue = ref.watch(queueNotifierProvider);
  return queue.isNotEmpty;
});