import 'package:echo/features/player/domain/entities/playback_state.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Repository interface for the music player.
///
/// All playback operations go through this interface.
/// Current implementation uses mock data only.
abstract class PlayerRepository {
  /// Loads a list of songs into the player queue.
  void loadQueue(List<Song> songs, {int startIndex = 0});

  /// Plays the song at the given queue index.
  void playAt(int index);

  /// Toggles play/pause.
  void togglePlayPause();

  /// Plays the current song (resumes from pause).
  void play();

  /// Pauses the current song.
  void pause();

  /// Skips to the next song in the queue.
  void next();

  /// Goes to the previous song in the queue.
  void previous();

  /// Seeks to the given position in the current song.
  void seek(Duration position);

  /// Toggles shuffle mode on/off.
  void toggleShuffle();

  /// Toggles repeat mode on/off.
  void toggleRepeat();

  /// Returns the current playback state.
  PlaybackState get state;

  /// Stream of playback state changes.
  Stream<PlaybackState> get stateStream;

  /// Toggles favorite for the current song.
  void toggleFavorite();
}