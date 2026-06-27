import 'package:echo/shared/music/domain/album.dart';

class AlbumMapper {
  const AlbumMapper();

  Album fromMap(Map<String, dynamic> data, {String? id}) {
    return Album(
      id: id ?? (data['id'] as String?) ?? '',
      title: (data['title'] ?? '') as String,
      artistId: (data['artistId'] ?? '') as String,
      artistName: (data['artistName'] ?? '') as String,
      coverUrl: data['coverUrl'] as String?,
      releaseYear: _toInt(data['releaseYear'] ?? data['year'] ?? 0),
      songCount: _toInt(data['songCount'] ?? data['tracks'] ?? 0),
      label: data['label'] as String?,
    );
  }

  static int _toInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

