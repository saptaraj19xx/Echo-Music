/// Base entity for library sections.
class LibraryItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final int count;

  const LibraryItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.count = 0,
  });
}