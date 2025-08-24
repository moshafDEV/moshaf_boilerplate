import 'package:dartz/dartz.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/domain/entities/auth/auth_response_entity.dart';
import 'package:ProjectName/domain/entities/login_param/login_param_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> login(LoginParamEntity params);
  Future<Either<Failure, AuthResponseEntity>> logout();
}
