/// Represents a music album.
///
/// Single source of truth — all features reference this class.
class Album {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? coverUrl;
  final int releaseYear;
  final int songCount;
  final String? label;

  const Album({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.coverUrl,
    required this.releaseYear,
    this.songCount = 0,
    this.label,
  });
}