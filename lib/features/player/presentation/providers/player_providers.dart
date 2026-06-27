import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/shared/music/domain/song.dart';
import 'package:echo/features/player/data/datasources/mock_player_datasource.dart';
import 'package:echo/features/player/data/repositories/player_repository_impl.dart';
import 'package:echo/features/player/domain/entities/playback_state.dart';
import 'package:echo/features/player/domain/repositories/player_repository.dart';
import 'package:echo/features/player/domain/usecases/player_use_cases.dart';

// ---------------------------------------------------------------------------
// PlayerRepository (singleton — shared across the app)
// ---------------------------------------------------------------------------
final _mockDataSourceProvider = Provider<MockPlayerDataSource>((ref) {
  final ds = MockPlayerDataSource();
  ref.onDispose(() => ds.dispose());
  return ds;
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final dataSource = ref.watch(_mockDataSourceProvider);
  return PlayerRepositoryImpl(dataSource);
});

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------
final playSongUseCaseProvider = Provider<PlaySong>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PlaySong(repo);
});

final pauseSongUseCaseProvider = Provider<PauseSong>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PauseSong(repo);
});

final nextSongUseCaseProvider = Provider<NextSong>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return NextSong(repo);
});

final previousSongUseCaseProvider = Provider<PreviousSong>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PreviousSong(repo);
});

final toggleShuffleUseCaseProvider = Provider<ToggleShuffle>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return ToggleShuffle(repo);
});

final toggleRepeatUseCaseProvider = Provider<ToggleRepeat>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return ToggleRepeat(repo);
});

final seekPositionUseCaseProvider = Provider<SeekPosition>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return SeekPosition(repo);
});

// ---------------------------------------------------------------------------
// Playback state stream — the single source of truth
// ---------------------------------------------------------------------------
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return repo.stateStream;
});

/// A notifier that wraps the player repository for imperative control.
final playerControllerProvider = Provider<PlayerController>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PlayerController(ref, repo);
});

/// Controller class that exposes player operations as methods.
class PlayerController {
  final Ref _ref;
  final PlayerRepository _repository;

  PlayerController(this._ref, this._repository);

  void loadQueue(List<Song> songs, {int startIndex = 0, bool autoPlay = true}) {
    _ref.read(playSongUseCaseProvider)(songs, startIndex: startIndex, autoPlay: autoPlay);
  }

  void togglePlayPause() => _repository.togglePlayPause();

  void play() => _repository.play();

  void pause() => _repository.pause();

  void next() => _repository.next();

  void previous() => _repository.previous();

  void seek(Duration position) => _repository.seek(position);

  void toggleShuffle() => _repository.toggleShuffle();

  void toggleRepeat() => _repository.toggleRepeat();

  void toggleFavorite() => _repository.toggleFavorite();
}