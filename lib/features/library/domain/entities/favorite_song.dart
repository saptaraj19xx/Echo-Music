/// Represents a song marked as favorite by the user.
class FavoriteSong {
  final String songId;
  final DateTime addedAt;

  const FavoriteSong({
    required this.songId,
    required this.addedAt,
  });
}