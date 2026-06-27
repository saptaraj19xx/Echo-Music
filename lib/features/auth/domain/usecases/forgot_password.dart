import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for sending a password reset email.
class ForgotPassword {
  final AuthRepositoryInterface _repository;

  ForgotPassword(this._repository);

  Future<Either<AuthException, void>> execute({
    required String email,
  }) {
    return _repository.forgotPassword(email: email);
  }
}