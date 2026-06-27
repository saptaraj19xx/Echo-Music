import 'package:echo/shared/music/domain/playlist.dart';

class PlaylistMapper {
  const PlaylistMapper();

  Playlist fromMap(Map<String, dynamic> data, {String? id}) {
    final totalSeconds = _toInt(data['totalDurationSeconds'] ?? data['totalDuration'] ?? 0);

    return Playlist(
      id: id ?? (data['id'] as String?) ?? '',
      name: (data['name'] ?? '') as String,
      description: data['description'] as String?,
      coverUrl: data['coverUrl'] as String?,
      ownerName: (data['ownerName'] ?? data['owner'] ?? '') as String,
      songCount: _toInt(data['songCount'] ?? data['tracks'] ?? 0),
      totalDuration: Duration(seconds: totalSeconds),
      isCollaborative: (data['isCollaborative'] ?? false) as bool,
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

