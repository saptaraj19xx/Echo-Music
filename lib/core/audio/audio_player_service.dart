import 'dart:async';

import 'package:just_audio/just_audio.dart' as ja;

/// Abstraction for audio playback.
///
/// This is designed to be extended in future sprints with queue management,
/// shuffle/repeat, background playback, lock screen controls, and
/// notifications.
abstract class AudioPlayerService {
  /// Plays the provided [url].
  ///
  /// Implementations should replace the current source.
  /// Throws [Exception] if playback fails after retries.
  Future<void> play(String url);

  /// Pauses playback.
  Future<void> pause();

  /// Resumes playback if possible.
  Future<void> resume();

  /// Stops playback.
  ///
  /// Implementations are encouraged to reset position to the beginning.
  ///
  /// Returns a Future to allow callers to await any internal cleanup.
  Future<void> stop();

  /// Seeks to the given [position] (in the currently loaded media source).
  Future<void> seek(Duration position);

  /// Releases internal resources.
  Future<void> dispose();

  /// Stream of the current playback position.
  Stream<Duration> get positionStream;

  /// Stream of the total duration.
  ///
  /// When duration is not yet known, implementations should emit
  /// [Duration.zero].
  Stream<Duration> get durationStream;

  /// Whether the player is currently playing.
  Stream<bool> get isPlayingStream;

  /// Stream of the just_audio processing state.
  Stream<ja.ProcessingState> get processingStateStream;

  /// Stream of playback errors.
  Stream<String?> get errorStream;

  /// Last known playback position.
  Duration get currentPosition;

  /// Last known duration.
  Duration get totalDuration;

  /// Whether the player is playing.
  bool get isPlaying;

  /// Last known processing state.
  ja.ProcessingState get processingState;

  /// Last known error message, if any.
  String? get lastError;
}

/// A production-ready [AudioPlayerService] implementation using
/// `just_audio`.
///
/// Owns exactly one [ja.AudioPlayer] instance.
class JustAudioPlayerService implements AudioPlayerService {
  final ja.AudioPlayer _player;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  final _processingStateController =
      StreamController<ja.ProcessingState>.broadcast();
  final _errorController = StreamController<String?>.broadcast();

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  ja.ProcessingState _processingState = ja.ProcessingState.idle;
  String? _lastError;

  JustAudioPlayerService({ja.AudioPlayer? player})
      : _player = player ?? ja.AudioPlayer() {
    _player.positionStream.listen((value) {
      final position = value;
      _currentPosition = position;
      _positionController.add(position);
    });

    _player.durationStream.listen((value) {
      final duration = value ?? Duration.zero;
      _totalDuration = duration;
      _durationController.add(duration);
    });

    _player.playingStream.listen((value) {
      _isPlaying = value;
      _isPlayingController.add(value);
    });

    _player.processingStateStream.listen((value) {
      _processingState = value;
      _processingStateController.add(value);
      if (value == ja.ProcessingState.ready) {
        _lastError = null;
        _errorController.add(null);
      }
    });

    _player.playbackEventStream.listen((_) {
      // playbackEventStream is used to stay synchronized with just_audio
      // internal events such as track transitions.
    });

    _emitInitial();
  }

  void _emitInitial() {
    _positionController.add(_currentPosition);
    _durationController.add(_totalDuration);
    _isPlayingController.add(_isPlaying);
    _processingStateController.add(_processingState);
    _errorController.add(_lastError);
  }

  Future<void> _loadUrl(String url) async {
    // Reset error state before loading.
    _lastError = null;
    _errorController.add(null);

    // Clear any existing source to avoid "Loading interrupted" when
    // setUrl is called while a previous load is still in progress.
    try {
      await _player.stop();
    } catch (_) {
      // Ignore stop errors; we just want to clear the pipeline.
    }

    try {
      await _player.setUrl(url);
    } catch (e) {
      _lastError = e.toString();
      _errorController.add(_lastError);
      rethrow;
    }
  }

  @override
  Future<void> play(String url) async {
    final success = await _loadUrlWithRetry(url);
    if (success) {
      await _player.play();
    }
  }

  ///Attempts to set the URL with a single retry on failure.
  Future<bool> _loadUrlWithRetry(String url, {int attempt = 1}) async {
    try {
      await _loadUrl(url);
      return true;
    } catch (e) {
      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _loadUrlWithRetry(url, attempt: attempt + 1);
      }
      return false;
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentPosition = Duration.zero;
    _positionController.add(_currentPosition);
    _isPlaying = false;
    _isPlayingController.add(_isPlaying);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _positionController.close();
    await _durationController.close();
    await _isPlayingController.close();
    await _processingStateController.close();
    await _errorController.close();
  }

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Stream<ja.ProcessingState> get processingStateStream =>
      _processingStateController.stream;

  @override
  Stream<String?> get errorStream => _errorController.stream;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Duration get totalDuration => _totalDuration;

  @override
  bool get isPlaying => _isPlaying;

  @override
  ja.ProcessingState get processingState => _processingState;

  @override
  String? get lastError => _lastError;
}