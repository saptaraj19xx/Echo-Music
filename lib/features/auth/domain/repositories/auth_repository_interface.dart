import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../entities/user_entity.dart';

/// Abstract repository for authentication operations.
///
/// All methods return [Either] with [AuthException] on failure
/// and the expected result on success.
abstract class AuthRepositoryInterface {
  /// Sign in with email and password.
  Future<Either<AuthException, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  Future<Either<AuthException, UserEntity>> signUp({
    required String email,
    required String password,
  });

  /// Sign out the current user.
  Future<Either<AuthException, void>> signOut();

  /// Send a password reset email.
  Future<Either<AuthException, void>> forgotPassword({
    required String email,
  });

  /// Continue as a guest user without authentication.
  Future<Either<AuthException, UserEntity>> continueAsGuest();

  /// Get the currently authenticated user, if any.
  Future<Either<AuthException, UserEntity?>> getCurrentUser();
}