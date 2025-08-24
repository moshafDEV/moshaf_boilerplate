import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/domain/entities/auth/auth_response_entity.dart';
import 'package:ProjectName/domain/entities/login_param/login_param_entity.dart';
import 'package:ProjectName/domain/repositories/auth_repository.dart';


@injectable
class LoginUsecase {
  final AuthRepository _repository;

  LoginUsecase(this._repository);

  Future<Either<Failure, AuthResponseEntity>> execute(
    LoginParamEntity params,
  ) async {
    return await _repository.login(params);
  }
}
