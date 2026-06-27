/// Represents an album marked as favorite by the user.
class FavoriteAlbum {
  final String albumId;
  final DateTime addedAt;

  const FavoriteAlbum({
    required this.albumId,
    required this.addedAt,
  });
}