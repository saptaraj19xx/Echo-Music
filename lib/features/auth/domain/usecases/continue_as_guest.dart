import 'package:dartz/dartz.dart';

import '../../../../core/errors/auth_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for continuing as a guest user.
class ContinueAsGuest {
  final AuthRepositoryInterface _repository;

  ContinueAsGuest(this._repository);

  Future<Either<AuthException, UserEntity>> execute() {
    return _repository.continueAsGuest();
  }
}