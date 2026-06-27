import 'package:echo/features/library/domain/entities/favorite_song.dart';

class FavoriteSongMapper {
  FavoriteSong fromMap(Map<String, dynamic> map) {
    return FavoriteSong(
      songId: map['songId'] as String,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  Map<String, dynamic> toMap(FavoriteSong entity) {
    return <String, dynamic>{
      'songId': entity.songId,
      'addedAt': entity.addedAt.toIso8601String(),
    };
  }
}

