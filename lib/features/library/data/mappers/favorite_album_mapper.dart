import 'package:echo/features/library/domain/entities/favorite_album.dart';

class FavoriteAlbumMapper {
  FavoriteAlbum fromMap(Map<String, dynamic> map) {
    return FavoriteAlbum(
      albumId: map['albumId'] as String,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  Map<String, dynamic> toMap(FavoriteAlbum entity) {
    return <String, dynamic>{
      'albumId': entity.albumId,
      'addedAt': entity.addedAt.toIso8601String(),
    };
  }
}

