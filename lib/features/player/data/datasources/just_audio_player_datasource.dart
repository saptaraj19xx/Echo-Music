import 'dart:async';

import 'package:echo/core/audio/audio_player_service.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/player/domain/entities/playing_song.dart';
import 'package:echo/features/player/domain/entities/playback_state.dart';
import 'package:echo/features/player/domain/entities/queue_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real player data source that bridges the Player feature to
/// [AudioPlayerService] (just_audio).
///
/// This keeps the Player feature's existing repository pattern intact while
/// replacing the mock playback backend.
class JustAudioPlayerDataSource {
  final Ref ref;
  final AudioPlayerService _audioPlayerService;

  JustAudioPlayerDataSource(this.ref, this._audioPlayerService) {
    _audioPlayerService.positionStream.listen((position) {
      _state = _state.copyWith(currentPosition: position);
      _emitState();
    });

    _audioPlayerService.durationStream.listen((duration) {
      _state = _state.copyWith(totalDuration: duration);
      _emitState();
    });

    _audioPlayerService.isPlayingStream.listen((isPlaying) {
      _state = _state.copyWith(isPlaying: isPlaying);
      _emitState();
    });

    _audioPlayerService.processingStateStream.listen((processingState) {
      // Map just_audio processing states to buffering flag.
      final isBuffering = processingState == ja.ProcessingState.buffering ||
          processingState == ja.ProcessingState.loading;
      _state = _state.copyWith(isBuffering: isBuffering);
      _emitState();

      // Clear buffer flag once ready.
      if (processingState == ja.ProcessingState.ready) {
        _state = _state.copyWith(isBuffering: false);
        _emitState();
      }
    });

    _audioPlayerService.errorStream.listen((error) {
      _state = _state.copyWith(
        isBuffering: false,
        errorMessage: error,
      );
      _emitState();
    });
  }

  List<QueueItem> _queue = const [];
  int _currentIndex = -1;
  bool _isShuffled = false;
  bool _isRepeating = false;

  bool _isFavorite = false;
  final double _playbackSpeed = 1.0;

  PlaybackState _state = const PlaybackState();

  final _stateController = StreamController<PlaybackState>.broadcast();

  Stream<PlaybackState> get stateStream => _stateController.stream;

  PlaybackState get state => _state;

  void _emitState() => _stateController.add(_state);

  /// Resolves audio URLs for playback.
  ///
  /// Supports standard HTTP(S) URLs and Firebase Storage paths (either
  /// `gs://bucket/path` or as a Firestore `audioUrl` reference). Other
  /// values are passed through as-is so callers can supply already-valid
  /// download URLs.
  static String resolveAudioUrl(String? rawUrl, String? path) {
    final candidate = (rawUrl ?? '').trim();
    if (candidate.isEmpty) return '';

    // Already a download URL.
    if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
      return candidate;
    }

    // Firebase Storage gs:// reference.
    if (candidate.startsWith('gs://')) {
      final withoutScheme = candidate.substring(5);
      final slashIndex = withoutScheme.indexOf('/');
      if (slashIndex == -1) return candidate;
      final bucket = withoutScheme.substring(0, slashIndex);
      final encodedPath = withoutScheme.substring(slashIndex + 1);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(encodedPath)}?alt=media';
    }

    // Relative path or Firestore storage path: treat as if it were under the
    // default Firebase Storage bucket. This mirrors common apps that store
    // the `fullPath` from Storage metadata in Firestore.
    if (path != null && path.startsWith('/')) path = path.substring(1);
    final storagePath = path ?? candidate;
    final encoded = Uri.encodeComponent(storagePath);
    // NOTE: In a real app the bucket name should come from Firebase config.
    // For now we rely on the Firebase Storage SDK default bucket mapping,
    // which works when `firebase_storage` initializes a default instance.
    return 'https://firebasestorage.googleapis.com/v0/b/echo-music.appspot.com/o/$encoded?alt=media';
  }

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
      isBuffering: false,
      isShuffled: _isShuffled,
      isRepeating: _isRepeating,
      currentPosition: Duration.zero,
      totalDuration: currentSong?.duration ?? Duration.zero,
      playbackSpeed: _playbackSpeed,
      currentIndex: _currentIndex,
      errorMessage: null,
    );

    _emitState();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;

    final originalAudioUrl = _queue[_currentIndex].song.audioUrl;
    final resolvedUrl = resolveAudioUrl(
      originalAudioUrl,
      _queue[_currentIndex].song.id,
    );

    // Update playing song state before triggering playback so the UI
    // shows the correct title even while buffering.
    _state = _state.copyWith(
      currentSong: PlayingSong(
        song: _queue[_currentIndex].song,
        isFavorite: _isFavorite,
      ),
      currentIndex: _currentIndex,
      isBuffering: true,
      errorMessage: null,
    );
    _emitState();

    try {
      await _audioPlayerService.play(resolvedUrl);
    } catch (e) {
      _state = _state.copyWith(
        isBuffering: false,
        isPlaying: false,
        errorMessage: 'Playback failed: ${e.toString()}',
      );
      _emitState();
    }
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
      isBuffering: true,
      errorMessage: null,
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
    // Always reload the source via _playCurrent() to ensure a source
    // is loaded before starting playback. The previous approach assumed
    // playAt() had already loaded the source, but its fire-and-forget
    // execution could silently swallow errors (due to void interface
    // between Repository -> DataSource). This also prevents a race
    // where the user taps play before playAt()'s async setUrl completes.
    //
    // just_audio's setUrl is idempotent when called with the same URL,
    // so calling _playCurrent() from both playAt() and play() is safe.
    await _playCurrent();
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
        _state = _state.copyWith(isPlaying: false, isBuffering: false);
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
      currentSong: _state.currentSong?.copyWith(isFavorite: _isFavorite),
    );
    _emitState();
  }

  void dispose() {
    _stateController.close();
  }
}
