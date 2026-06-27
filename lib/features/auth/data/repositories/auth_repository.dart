import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../datasources/mock_auth_datasource.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepositoryInterface] using mock data source.
///
/// Connect to real Firebase datasource here in a future sprint.
class AuthRepository implements AuthRepositoryInterface {
  final MockAuthDataSource _dataSource;

  AuthRepository({MockAuthDataSource? dataSource})
      : _dataSource = dataSource ?? MockAuthDataSource();

  @override
  Future<Either<AuthException, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final mockUser = await _dataSource.signIn(
        email: email,
        password: password,
      );
      final user = UserModel.fromMockUser(
        id: mockUser.id,
        email: mockUser.email,
        displayName: mockUser.displayName,
        photoUrl: mockUser.photoUrl,
      ).toEntity();
      return Right(user);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          code: AuthException.unknown,
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }

  @override
  Future<Either<AuthException, UserEntity>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final mockUser = await _dataSource.signUp(
        email: email,
        password: password,
      );
      final user = UserModel.fromMockUser(
        id: mockUser.id,
        email: mockUser.email,
        displayName: mockUser.displayName,
        photoUrl: mockUser.photoUrl,
      ).toEntity();
      return Right(user);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          code: AuthException.unknown,
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }

  @override
  Future<Either<AuthException, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          code: AuthException.unknown,
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }

  @override
  Future<Either<AuthException, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await _dataSource.forgotPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          code: AuthException.unknown,
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }

  @override
  Future<Either<AuthException, UserEntity>> continueAsGuest() async {
    try {
      final mockUser = await _dataSource.continueAsGuest();
      final user = UserModel.fromMockUser(
        id: mockUser.id,
        email: mockUser.email,
        displayName: mockUser.displayName,
        isGuest: mockUser.isGuest,
      ).toEntity();
      return Right(user);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          code: AuthException.unknown,
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }

  @override
  Future<Either<AuthException, UserEntity?>> getCurrentUser() async {
    try {
      final mockUser = await _dataSource.getCurrentUser();
      if (mockUser == null) {
        return const Right(null);
      }
      final user = UserModel.fromMockUser(
        id: mockUser.id,
        email: mockUser.email,
        displayName: mockUser.displayName,
        photoUrl: mockUser.photoUrl,
        isGuest: mockUser.isGuest,
      ).toEntity();
      return Right(user);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          code: AuthException.unknown,
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }
}