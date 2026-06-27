import 'package:echo/features/library/domain/entities/favorite_artist.dart';

class FavoriteArtistMapper {
  FavoriteArtist fromMap(Map<String, dynamic> map) {
    return FavoriteArtist(
      artistId: map['artistId'] as String,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  Map<String, dynamic> toMap(FavoriteArtist entity) {
    return <String, dynamic>{
      'artistId': entity.artistId,
      'addedAt': entity.addedAt.toIso8601String(),
    };
  }
}

