/// Represents a music playlist.
///
/// Single source of truth — all features reference this class.
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String ownerName;
  final int songCount;
  final Duration totalDuration;
  final bool isCollaborative;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.ownerName,
    this.songCount = 0,
    this.totalDuration = Duration.zero,
    this.isCollaborative = false,
  });
}