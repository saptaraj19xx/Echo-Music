import 'dart:async';
import 'dart:math';

import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/player/domain/entities/playing_song.dart';
import 'package:echo/features/player/domain/entities/playback_state.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';

/// Mock data source for the player feature.
///
/// Simulates playback without actual audio.
/// Uses a periodic timer to advance position.
class MockPlayerDataSource {
  List<QueueItem> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  bool _isFavorite = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  final double _playbackSpeed = 1.0;
  Timer? _progressTimer;
  final Random _random = Random();
  List<int> _shuffleOrder = [];
  int _shuffleIndex = 0;

  final StreamController<PlaybackState> _stateController =
      StreamController<PlaybackState>.broadcast();

  PlaybackState get state {
    final currentSong = _currentIndex >= 0 && _currentIndex < _queue.length
        ? _queue[_currentIndex]
        : null;
    return PlaybackState(
      currentSong: currentSong != null
          ? PlayingSong(
              song: currentSong.song,
              isFavorite: _isFavorite,
            )
          : null,
      queue: List.from(_queue),
      isPlaying: _isPlaying,
      isShuffled: _isShuffled,
      isRepeating: _isRepeating,
      currentPosition: _currentPosition,
      totalDuration: _totalDuration,
      playbackSpeed: _playbackSpeed,
      currentIndex: _currentIndex,
    );
  }

  Stream<PlaybackState> get stateStream => _stateController.stream;

  void _emitState() {
    _stateController.add(state);
  }

  void loadQueue(List<Song> songs, {int startIndex = 0}) {
    _stopTimer();
    _queue = songs
        .map((song) => QueueItem(song: song))
        .toList();
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _totalDuration =
        _currentIndex >= 0 ? _queue[_currentIndex].song.duration : Duration.zero;
    _isFavorite = false;
    _buildShuffleOrder();
    _emitState();
  }

  void playAt(int index) {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    _isPlaying = true;
    _currentPosition = Duration.zero;
    _totalDuration = _queue[index].song.duration;
    _startTimer();
    _emitState();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (_queue.isEmpty) return;
    if (_currentIndex < 0) _currentIndex = 0;
    _isPlaying = true;
    _startTimer();
    _emitState();
  }

  void pause() {
    _isPlaying = false;
    _stopTimer();
    _emitState();
  }

  void next() {
    if (_queue.isEmpty) return;

    if (_isShuffled) {
      _shuffleIndex++;
      if (_shuffleIndex >= _shuffleOrder.length) {
        if (_isRepeating) {
          _shuffleIndex = 0;
        } else {
          _isPlaying = false;
          _stopTimer();
          _emitState();
          return;
        }
      }
      _currentIndex = _shuffleOrder[_shuffleIndex];
    } else {
      if (_currentIndex + 1 >= _queue.length) {
        if (_isRepeating) {
          _currentIndex = 0;
        } else {
          _isPlaying = false;
          _stopTimer();
          _emitState();
          return;
        }
      } else {
        _currentIndex++;
      }
    }

    _currentPosition = Duration.zero;
    _totalDuration = _queue[_currentIndex].song.duration;
    _isFavorite = false;
    _startTimer();
    _emitState();
  }

  void previous() {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart current song
    if (_currentPosition.inSeconds > 3) {
      _currentPosition = Duration.zero;
      _emitState();
      return;
    }

    if (_isShuffled) {
      _shuffleIndex = (_shuffleIndex - 1).clamp(0, _shuffleOrder.length - 1);
      _currentIndex = _shuffleOrder[_shuffleIndex];
    } else {
      _currentIndex = (_currentIndex - 1).clamp(0, _queue.length - 1);
    }

    _currentPosition = Duration.zero;
    _totalDuration = _queue[_currentIndex].song.duration;
    _isFavorite = false;
    _startTimer();
    _emitState();
  }

  void seek(Duration position) {
    if (position < Duration.zero) {
      _currentPosition = Duration.zero;
    } else if (position > _totalDuration) {
      _currentPosition = _totalDuration;
    } else {
      _currentPosition = position;
    }
    _emitState();
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _buildShuffleOrder();
    }
    _emitState();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    _emitState();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    _emitState();
  }

  void _buildShuffleOrder() {
    _shuffleOrder = List.generate(_queue.length, (i) => i);
    _shuffleOrder.shuffle(_random);
    // Ensure current song is first
    if (_currentIndex >= 0) {
      _shuffleOrder.remove(_currentIndex);
      _shuffleOrder.insert(0, _currentIndex);
    }
    _shuffleIndex = 0;
  }

  void _startTimer() {
    _stopTimer();
    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) {
        if (_isPlaying) {
          _currentPosition += const Duration(milliseconds: 250);
          if (_currentPosition >= _totalDuration) {
            next();
          } else {
            _emitState();
          }
        }
      },
    );
  }

  void _stopTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void dispose() {
    _stopTimer();
    _stateController.close();
  }
}