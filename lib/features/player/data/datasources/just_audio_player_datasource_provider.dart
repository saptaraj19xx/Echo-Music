import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/core/audio/providers/audio_player_provider.dart';

import 'just_audio_player_datasource.dart';

/// Riverpod provider for the real [JustAudioPlayerDataSource].
final justAudioPlayerDataSourceProvider = Provider<JustAudioPlayerDataSource>((ref) {
  final audioPlayerService = ref.watch(audioPlayerProvider);
  final dataSource = JustAudioPlayerDataSource(ref, audioPlayerService);

  ref.onDispose(dataSource.dispose);

  return dataSource;
});