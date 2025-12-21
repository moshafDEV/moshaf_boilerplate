import 'package:dartz/dartz.dart';
import 'package:example_app/core/error/failure.dart';
import 'package:example_app/domain/entities/auth/auth_response_entity.dart';
import 'package:example_app/domain/entities/login_param/login_param_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> login(LoginParamEntity params);
  Future<Either<Failure, AuthResponseEntity>> logout();
}
