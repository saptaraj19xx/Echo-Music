/// User entity representing an authenticated user in the domain layer.
class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final bool isGuest;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.isGuest = false,
  });

  /// Create an anonymous guest user.
  factory UserEntity.guest() {
    return const UserEntity(
      id: 'guest',
      email: '',
      displayName: 'Guest',
      isGuest: true,
      isEmailVerified: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          isEmailVerified == other.isEmailVerified &&
          isGuest == other.isGuest;

  @override
  int get hashCode => Object.hash(id, email, displayName, photoUrl, isEmailVerified, isGuest);
}