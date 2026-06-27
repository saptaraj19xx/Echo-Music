import 'package:echo/shared/music/domain/artist.dart';

class ArtistMapper {
  const ArtistMapper();

  Artist fromMap(Map<String, dynamic> data, {String? id}) {
    return Artist(
      id: id ?? (data['id'] as String?) ?? '',
      name: (data['name'] ?? '') as String,
      imageUrl: data['imageUrl'] as String?,
      bio: data['bio'] as String?,
      monthlyListeners: _toInt(data['monthlyListeners'] ?? data['listeners'] ?? 0),
      isVerified: (data['isVerified'] ?? false) as bool,
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

