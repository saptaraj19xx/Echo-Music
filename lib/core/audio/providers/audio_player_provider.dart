import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio_player_service.dart';

/// Riverpod provider for [AudioPlayerService].
///
/// Exposes the interface and provides a concrete implementation inside the
/// provider.
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final service = JustAudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

