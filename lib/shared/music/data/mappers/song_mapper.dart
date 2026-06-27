import 'package:echo/shared/music/domain/song.dart';

class SongMapper {
  const SongMapper();

  Song fromMap(Map<String, dynamic> data, {String? id}) {
    final durationSeconds = _toInt(data['durationSeconds'] ?? data['duration'] ?? 0);

    final duration = Duration(seconds: durationSeconds);

    return Song(
      id: id ?? (data['id'] as String?) ?? '',
      title: (data['title'] ?? '') as String,
      artistId: (data['artistId'] ?? '') as String,
      artistName: (data['artistName'] ?? '') as String,
      albumId: data['albumId'] as String?,
      albumTitle: data['albumTitle'] as String?,
      albumArtUrl: data['albumArtUrl'] as String?,
      duration: duration,
      audioUrl: data['audioUrl'] as String?,
      isExplicit: (data['isExplicit'] ?? false) as bool,
      trackNumber: _toInt(data['trackNumber'] ?? 1),
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

