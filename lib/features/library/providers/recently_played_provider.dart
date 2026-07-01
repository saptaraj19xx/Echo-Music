import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/features/player/presentation/providers/player_providers.dart';
import 'package:echo/features/library/domain/repositories/library_repository.dart';

import 'package:echo/features/library/presentation/providers/library_providers.dart';

import 'package:echo/shared/music/domain/song.dart';

/// Automatically writes recently played + most played entries when a playback
/// threshold is met.
///
/// Rules:
/// - threshold: position >= 30s OR position >= 50% of duration
/// - write only once per "song session" (resets when song id changes)
/// - does NOT write continuously
class RecentlyPlayedTracker extends AsyncNotifier<void> {
  StreamSubscription? _sub;
  String? _lastSongId;
  bool _writtenForCurrentSongSession = false;

  @override
  Future<void> build() async {
    // Subscribe to playback state changes.
    final playback = ref.read(playbackStateProvider.stream);
    _sub = playback.listen((state) async {
      final current = state.currentSong;
      if (current == null) return;

      final song = current.song;
      final songId = song.id;


      // Reset when the song changes.
      if (_lastSongId != songId) {
        _lastSongId = songId;
        _writtenForCurrentSongSession = false;
      }

      if (_writtenForCurrentSongSession) return;

      final thresholdReached = _isThresholdReached(
        currentPosition: state.currentPosition,
        totalDuration: state.totalDuration,
      );

      if (!thresholdReached) return;

      _writtenForCurrentSongSession = true;



      final duration = state.totalDuration;
      final lastPosition = state.currentPosition;
      final playedAt = DateTime.now();

      // Metadata sourced only from canonical playback state.
      final title = song.title;
      final artist = song.artistName;
      final artworkUrl = song.albumArtUrl ?? '';


      final libraryRepository = ref.read(libraryRepositoryProvider);

      libraryRepository.addRecentlyPlayedEntry(
        songId: songId,
        title: title,
        artist: artist,
        artworkUrl: artworkUrl,
        duration: duration,
        lastPosition: lastPosition,
        playedAt: playedAt,
      );

      libraryRepository.addMostPlayedEntry(
        songId: songId,
        title: title,
        artist: artist,
        artworkUrl: artworkUrl,
        duration: duration,
        lastPlayed: playedAt,
      );






    });

    // Keep notifier alive.
    ref.onDispose(() {
      _sub?.cancel();
    });
  }

  bool _isThresholdReached({
    required Duration currentPosition,
    required Duration totalDuration,
  }) {
    // Avoid division by zero / invalid duration.
    if (totalDuration <= Duration.zero) {
      return currentPosition >= const Duration(seconds: 30);
    }

    final playedSeconds = currentPosition.inMilliseconds;
    final totalSeconds = totalDuration.inMilliseconds;

    final playedHalf = playedSeconds >= totalSeconds / 2;
    final atLeast30s = currentPosition >= const Duration(seconds: 30);

    return atLeast30s || playedHalf;
  }
}

/// Provider that activates the tracker.
///
/// IMPORTANT: This does not expose state; it just wires side-effects.
final recentlyPlayedTrackerProvider =
    AsyncNotifierProvider<RecentlyPlayedTracker, void>(() => RecentlyPlayedTracker());

