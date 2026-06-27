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

  /// Last known playback position.
  Duration get currentPosition;

  /// Last known duration.
  Duration get totalDuration;

  /// Whether the player is playing.
  bool get isPlaying;

  /// Last known processing state.
  ja.ProcessingState get processingState;
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

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  ja.ProcessingState _processingState = ja.ProcessingState.idle;

  JustAudioPlayerService({ja.AudioPlayer? player}) : _player = player ?? ja.AudioPlayer() {
    // just_audio already exposes streams for these values, which we map into
    // our service's public streams and keep local state for getters.

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
    });

    // Emit initial values.
    _positionController.add(_currentPosition);
    _durationController.add(_totalDuration);
    _isPlayingController.add(_isPlaying);
    _processingStateController.add(_processingState);
  }

  @override
  Future<void> play(String url) async {
    // Using setUrl instead of a playlist/queue for this sprint.
    // Future queue support should be implemented behind this interface.
    await _player.setUrl(url);
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() async {

    await _player.stop();

    // Ensure local state and UI can instantly reflect the stopped status.
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
  Duration get currentPosition => _currentPosition;

  @override
  Duration get totalDuration => _totalDuration;

  @override
  bool get isPlaying => _isPlaying;

  @override
  ja.ProcessingState get processingState => _processingState;
}

