/// Represents a music artist.
///
/// Single source of truth — all features reference this class.
class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bio;
  final int monthlyListeners;
  final bool isVerified;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    this.monthlyListeners = 0,
    this.isVerified = false,
  });
}