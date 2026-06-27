import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for signing in with email and password.
class SignIn {
  final AuthRepositoryInterface _repository;

  SignIn(this._repository);

  Future<Either<AuthException, UserEntity>> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}