import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for signing out the current user.
class SignOut {
  final AuthRepositoryInterface _repository;

  SignOut(this._repository);

  Future<Either<AuthException, void>> execute() {
    return _repository.signOut();
  }
}