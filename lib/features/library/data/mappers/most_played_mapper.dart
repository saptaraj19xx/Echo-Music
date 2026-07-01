import 'package:echo/features/library/domain/entities/most_played.dart';

class MostPlayedMapper {
  MostPlayed fromMap(Map<String, dynamic> map) {
    return MostPlayed(
      songId: map['songId'] as String,
      playCount: (map['playCount'] as num?)?.toInt() ?? 0,
      lastPlayed: DateTime.parse(map['lastPlayed'] as String),
      title: (map['title'] as String?) ?? '',
      artist: (map['artist'] as String?) ?? '',
      artworkUrl: (map['artworkUrl'] as String?) ?? '',
      duration: Duration(milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0),
    );
  }

  Map<String, dynamic> toMap(MostPlayed entity) {
    return <String, dynamic>{
      'songId': entity.songId,
      'playCount': entity.playCount,
      'lastPlayed': entity.lastPlayed.toIso8601String(),
      'title': entity.title,
      'artist': entity.artist,
      'artworkUrl': entity.artworkUrl,
      'durationMs': entity.duration.inMilliseconds,
    };
  }
}

