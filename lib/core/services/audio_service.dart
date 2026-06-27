import 'dart:async';

/// Service for controlling audio playback.
abstract class AudioService {
  /// Plays a song by its URL.
  Future<void> play(String audioUrl);

  /// Pauses the current playback.
  Future<void> pause();

  /// Stops playback and resets position.
  Future<void> stop();

  /// Seeks to the specified duration.
  Future<void> seek(Duration position);

  /// Plays the next track in the queue.
  Future<void> next();

  /// Plays the previous track in the queue.
  Future<void> previous();

  /// Stream of playback state.
  Stream<PlaybackState> get playbackStateStream;
}

/// Represents the current state of audio playback.
class PlaybackState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? currentTrackUrl;

  const PlaybackState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentTrackUrl,
  });
}

/// Mock implementation of AudioService for development and testing.
///
/// Later this will wrap just_audio or audioplayers.
class MockAudioService implements AudioService {
  final _controller = StreamController<PlaybackState>.broadcast();

  @override
  Stream<PlaybackState> get playbackStateStream => _controller.stream;

  @override
  Future<void> play(String audioUrl) async {
    // Mock: start playback
    _controller.add(PlaybackState(
      isPlaying: true,
      currentTrackUrl: audioUrl,
    ));
  }

  @override
  Future<void> pause() async {
    // Mock: pause playback
    _controller.add(const PlaybackState(isPlaying: false));
  }

  @override
  Future<void> stop() async {
    // Mock: stop playback
    _controller.add(const PlaybackState());
  }

  @override
  Future<void> seek(Duration position) async {
    // Mock: no-op (position updates will be handled by the real player later).
  }

  @override
  Future<void> next() async {
    // Mock: no-op.
  }

  @override
  Future<void> previous() async {
    // Mock: no-op.
  }
}