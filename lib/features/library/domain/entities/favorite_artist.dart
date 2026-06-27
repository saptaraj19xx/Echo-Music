/// Represents an artist marked as favorite by the user.
class FavoriteArtist {
  final String artistId;
  final DateTime addedAt;

  const FavoriteArtist({
    required this.artistId,
    required this.addedAt,
  });
}