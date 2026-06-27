/// Represents a user-created collection of music items.
class Collection {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> songIds;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
    this.songIds = const [],
  });
}