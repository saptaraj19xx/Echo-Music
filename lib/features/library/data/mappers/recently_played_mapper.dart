import 'package:echo/features/library/domain/entities/recently_played.dart';

class RecentlyPlayedMapper {
  RecentlyPlayed fromMap(Map<String, dynamic> map) {
    return RecentlyPlayed(
      songId: map['songId'] as String,
      title: (map['title'] as String?) ?? '',
      artist: (map['artist'] as String?) ?? '',
      artworkUrl: (map['artworkUrl'] as String?) ?? '',
      duration: Duration(milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0),
      lastPosition:
          Duration(milliseconds: (map['lastPositionMs'] as num?)?.toInt() ?? 0),
      playedAt: DateTime.parse(map['playedAt'] as String),
    );
  }

  Map<String, dynamic> toMap(RecentlyPlayed entity) {
    return <String, dynamic>{
      'songId': entity.songId,
      'title': entity.title,
      'artist': entity.artist,
      'artworkUrl': entity.artworkUrl,
      'durationMs': entity.duration.inMilliseconds,
      'lastPositionMs': entity.lastPosition.inMilliseconds,
      'playedAt': entity.playedAt.toIso8601String(),
    };
  }
}



