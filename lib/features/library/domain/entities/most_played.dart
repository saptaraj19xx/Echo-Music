/// Represents an item in the user's most played list.
class MostPlayed {
  final String songId;
  final int playCount;
  final DateTime lastPlayed;

  final String title;
  final String artist;
  final String artworkUrl;
  final Duration duration;

  const MostPlayed({
    required this.songId,
    required this.playCount,
    required this.lastPlayed,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.duration,
  });
}

