/// Represents an item in the user's recently played history.
class RecentlyPlayed {
  final String songId;
  final String title;
  final String artist;
  final String artworkUrl;
  final Duration duration;
  final Duration lastPosition;
  final DateTime playedAt;

  const RecentlyPlayed({
    required this.songId,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.duration,
    required this.lastPosition,
    required this.playedAt,
  });
}
