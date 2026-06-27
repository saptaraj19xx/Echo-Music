import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/player/domain/repositories/player_repository.dart';

/// Use case: Load a queue of songs and optionally start playing from an index.
class PlaySong {
  final PlayerRepository _repository;

  PlaySong(this._repository);

  void call(List<Song> songs, {int startIndex = 0, bool autoPlay = true}) {
    _repository.loadQueue(songs, startIndex: startIndex);
    if (autoPlay) {
      _repository.playAt(startIndex);
    }
  }
}

/// Use case: Pause the current playback.
class PauseSong {
  final PlayerRepository _repository;

  PauseSong(this._repository);

  void call() => _repository.pause();
}

/// Use case: Skip to the next song in the queue.
class NextSong {
  final PlayerRepository _repository;

  NextSong(this._repository);

  void call() => _repository.next();
}

/// Use case: Go to the previous song in the queue.
class PreviousSong {
  final PlayerRepository _repository;

  PreviousSong(this._repository);

  void call() => _repository.previous();
}

/// Use case: Toggle shuffle mode.
class ToggleShuffle {
  final PlayerRepository _repository;

  ToggleShuffle(this._repository);

  void call() => _repository.toggleShuffle();
}

/// Use case: Toggle repeat mode.
class ToggleRepeat {
  final PlayerRepository _repository;

  ToggleRepeat(this._repository);

  void call() => _repository.toggleRepeat();
}

/// Use case: Seek to a specific position in the current song.
class SeekPosition {
  final PlayerRepository _repository;

  SeekPosition(this._repository);

  void call(Duration position) => _repository.seek(position);
}