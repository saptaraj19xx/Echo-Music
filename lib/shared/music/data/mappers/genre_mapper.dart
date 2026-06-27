import 'package:echo/shared/music/domain/genre.dart';

class GenreMapper {
  const GenreMapper();

  Genre fromMap(Map<String, dynamic> data, {String? id}) {
    final rawColor = data['colorValue'] ?? data['color'] ?? data['colorValueInt'];
    final colorValue = rawColor is int ? rawColor : _toInt(rawColor);

    return Genre(
      id: id ?? (data['id'] as String?) ?? '',
      name: (data['name'] ?? '') as String,
      colorValue: colorValue,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  static int _toInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final cleaned = v.startsWith('0x') ? v : '0xFF${v.replaceFirst('#', '')}';
      try {
        return int.parse(cleaned);
      } catch (_) {
        return int.tryParse(v) ?? 0;
      }
    }
    return 0;
  }
}

