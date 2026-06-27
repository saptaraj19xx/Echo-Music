/// Represents a music genre.
///
/// Single source of truth — all features reference this class.
class Genre {
  final String id;
  final String name;
  final int colorValue;
  final String? imageUrl;

  const Genre({
    required this.id,
    required this.name,
    this.colorValue = 0xFF7C4DFF,
    this.imageUrl,
  });
}