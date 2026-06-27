import 'dart:async';

import 'package:echo/core/audio/audio_player_service.dart';
import 'package:echo/core/audio/providers/audio_player_provider.dart';
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/player/domain/entities/playing_song.dart';
import 'package:echo/features/player/domain/entities/playback_state.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real player data source that bridges the Player feature to
/// [AudioPlayerService] (just_audio).
///
/// This keeps the Player feature’s existing repository pattern intact while
/// replacing the mock playback backend.
class JustAudioPlayerDataSource {
  final Ref ref;
  final AudioPlayerService _audioPlayerService;

  JustAudioPlayerDataSource(this.ref, this._audioPlayerService) {
    _audioPlayerService.positionStream.listen((pos) {
      _state = _state.copyWith(currentPosition: pos);
      _emitState();
    });

    _audioPlayerService.durationStream.listen((dur) {
      _state = _state.copyWith(totalDuration: dur);
      _emitState();
    });

    _audioPlayerService.isPlayingStream.listen((isPlaying) {
      _state = _state.copyWith(isPlaying: isPlaying);
      _emitState();
    });

    _audioPlayerService.processingStateStream.listen((_) {
      // Future: map processing states to UI flags if needed.
      // For now, keep current state as-is.
    });
  }

  List<QueueItem> _queue = const [];
  int _currentIndex = -1;
  bool _isShuffled = false;
  bool _isRepeating = false;

  bool _isFavorite = false;
  double _playbackSpeed = 1.0;

  PlaybackState _state = const PlaybackState();

  final _stateController = StreamController<PlaybackState>.broadcast();

  Stream<PlaybackState> get stateStream => _stateController.stream;

  PlaybackState get state => _state;

  void _emitState() => _stateController.add(_state);

  void loadQueue(List<Song> songs, {int startIndex = 0}) {
    _queue = songs.map((song) => QueueItem(song: song)).toList(growable: false);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    _isFavorite = false;

    final currentSong = _currentIndex >= 0 ? _queue[_currentIndex].song : null;

    _state = PlaybackState(
      currentSong: currentSong != null
          ? PlayingSong(song: currentSong, isFavorite: _isFavorite)
          : null,
      queue: List.from(_queue),
      isPlaying: false,
      isShuffled: _isShuffled,
      isRepeating: _isRepeating,
      currentPosition: Duration.zero,
      totalDuration: currentSong?.duration ?? Duration.zero,
      playbackSpeed: _playbackSpeed,
      currentIndex: _currentIndex,
    );

    _emitState();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;

    final audioUrl = _queue[_currentIndex].song.audioUrl;
    if (audioUrl == null || audioUrl.trim().isEmpty) return;

    // Update playing song before calling play.
    _state = _state.copyWith(
      currentSong: PlayingSong(
        song: _queue[_currentIndex].song,
        isFavorite: _isFavorite,
      ),
      currentIndex: _currentIndex,
    );
    _emitState();

    await _audioPlayerService.play(audioUrl);
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    _isFavorite = false;

    _state = _state.copyWith(
      currentIndex: _currentIndex,
      currentSong: PlayingSong(
        song: _queue[_currentIndex].song,
        isFavorite: _isFavorite,
      ),
      currentPosition: Duration.zero,
      totalDuration: _queue[_currentIndex].song.duration,
      isPlaying: false,
    );
    _emitState();

    await _playCurrent();
  }

  void togglePlayPause() {
    final isPlaying = _state.isPlaying;
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  Future<void> play() async {
    // Resume if already loaded.
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      // just_audio resume uses play() on the same source.
      await _audioPlayerService.resume();
    } else {
      // LoadQueue should have been called first.
      await _playCurrent();
    }
  }

  Future<void> pause() => _audioPlayerService.pause();

  Future<void> next() async {
    if (_queue.isEmpty) return;

    // Shuffle/repeat will be added later. For now, implement linear next.
    if (_currentIndex + 1 >= _queue.length) {
      if (_isRepeating) {
        _currentIndex = 0;
      } else {
        await _audioPlayerService.stop();
        _state = _state.copyWith(isPlaying: false);
        _emitState();
        return;
      }
    } else {
      _currentIndex++;
    }

    await playAt(_currentIndex);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    // Future: match mock behavior (restart if >3s).
    if (_state.currentPosition > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }

    if (_currentIndex - 1 < 0) {
      if (_isRepeating) {
        _currentIndex = _queue.length - 1;
      } else {
        await seek(Duration.zero);
        return;
      }
    } else {
      _currentIndex--;
    }

    await playAt(_currentIndex);
  }

  Future<void> seek(Duration position) => _audioPlayerService.seek(position);

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    _state = _state.copyWith(isShuffled: _isShuffled);
    _emitState();
    // Future: implement actual shuffle order at queue level.
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    _state = _state.copyWith(isRepeating: _isRepeating);
    _emitState();
    // Future: implement repeat behavior more deeply (processing state).
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    _state = _state.copyWith(
      currentSong: _state.currentSong == null
          ? null
          : _state.currentSong!.copyWith(isFavorite: _isFavorite),
    );
    _emitState();
  }

  void dispose() {
    _stateController.close();
  }
}

/// Provider for [JustAudioPlayerDataSource].
final justAudioPlayerDataSourceProvider = Provider<JustAudioPlayerDataSource>((ref) {
  final audioPlayerService = ref.watch(audioPlayerProvider);
  return JustAudioPlayerDataSource(ref, audioPlayerService);
});

