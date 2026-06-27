import 'package:echo/features/library/domain/entities/recently_played.dart';

class RecentlyPlayedMapper {
  RecentlyPlayed fromMap(Map<String, dynamic> map) {
    return RecentlyPlayed(
      songId: map['songId'] as String,
      playedAt: DateTime.parse(map['playedAt'] as String),
    );
  }

  Map<String, dynamic> toMap(RecentlyPlayed entity) {
    return <String, dynamic>{
      'songId': entity.songId,
      'playedAt': entity.playedAt.toIso8601String(),
    };
  }
}

