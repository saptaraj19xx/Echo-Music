/// Represents a music track.
///
/// Single source of truth — all features reference this class.
class Song {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? albumId;
  final String? albumTitle;
  final String? albumArtUrl;
  final Duration duration;
  final String? audioUrl;
  final bool isExplicit;
  final int trackNumber;

  const Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.albumId,
    this.albumTitle,
    this.albumArtUrl,
    this.duration = Duration.zero,
    this.audioUrl,
    this.isExplicit = false,
    this.trackNumber = 1,
  });
}