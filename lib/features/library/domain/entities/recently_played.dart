/// Represents an item in the user's recently played history.
class RecentlyPlayed {
  final String songId;
  final DateTime playedAt;

  const RecentlyPlayed({
    required this.songId,
    required this.playedAt,
  });
}