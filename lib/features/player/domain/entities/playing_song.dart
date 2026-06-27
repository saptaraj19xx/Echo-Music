import 'package:echo/shared/music/domain/song.dart';

/// Represents a song that is currently loaded in the player.
class PlayingSong {
  final Song song;
  final bool isFavorite;

  const PlayingSong({
    required this.song,
    this.isFavorite = false,
  });

  PlayingSong copyWith({
    Song? song,
    bool? isFavorite,
  }) {
    return PlayingSong(
      song: song ?? this.song,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}