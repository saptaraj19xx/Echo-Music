import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for creating a new account.
class SignUp {
  final AuthRepositoryInterface _repository;

  SignUp(this._repository);

  Future<Either<AuthException, UserEntity>> execute({
    required String email,
    required String password,
  }) {
    return _repository.signUp(email: email, password: password);
  }
}