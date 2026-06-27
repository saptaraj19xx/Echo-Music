import '../../domain/entities/user_entity.dart';

/// Data layer model for a user.
///
/// Converts between the domain entity and the raw data format.
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final bool isGuest;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.isGuest = false,
  });

  /// Convert to domain entity.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      isGuest: isGuest,
    );
  }

  /// Create from domain entity.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      isEmailVerified: entity.isEmailVerified,
      isGuest: entity.isGuest,
    );
  }

  /// Create from mock datasource's _MockUser.
  factory UserModel.fromMockUser({
    required String id,
    required String email,
    required String displayName,
    String? photoUrl,
    bool isGuest = false,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isGuest: isGuest,
    );
  }
}