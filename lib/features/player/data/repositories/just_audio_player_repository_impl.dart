import 'dart:async';

import 'package:echo/features/player/data/datasources/just_audio_player_datasource.dart';
import 'package:echo/features/player/domain/entities/playback_state.dart';
import 'package:echo/features/player/domain/repositories/player_repository.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Real implementation of [PlayerRepository] backed by [AudioPlayerService].
///
/// This repository is the single bridge between the Player feature and
/// the core playback service.
class JustAudioPlayerRepositoryImpl implements PlayerRepository {
  final JustAudioPlayerDataSource _dataSource;

  JustAudioPlayerRepositoryImpl(this._dataSource);

  @override
  void loadQueue(List<Song> songs, {int startIndex = 0}) {
    _dataSource.loadQueue(songs, startIndex: startIndex);
  }

  @override
  void playAt(int index) {
    _dataSource.playAt(index);
  }

  @override
  void togglePlayPause() => _dataSource.togglePlayPause();

  @override
  void play() {
    _dataSource.play();
  }

  @override
  void pause() => _dataSource.pause();

  @override
  void next() => _dataSource.next();

  @override
  void previous() => _dataSource.previous();

  @override
  void seek(Duration position) => _dataSource.seek(position);

  @override
  void toggleShuffle() => _dataSource.toggleShuffle();

  @override
  void toggleRepeat() => _dataSource.toggleRepeat();

  @override
  PlaybackState get state => _dataSource.state;

  @override
  Stream<PlaybackState> get stateStream => _dataSource.stateStream;

  @override
  void toggleFavorite() => _dataSource.toggleFavorite();
}

