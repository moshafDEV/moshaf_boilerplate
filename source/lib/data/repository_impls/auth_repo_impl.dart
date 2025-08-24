import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/data/datasources/remote/auth_remote_datasource.dart';
import 'package:ProjectName/data/models/login/request/login_req_param_model.dart';
import 'package:ProjectName/data/models/login/response/auth_response_model.dart';
import 'package:ProjectName/data/models/login/response/token_model.dart';
import 'package:ProjectName/domain/entities/auth/auth_response_entity.dart';
import 'package:ProjectName/domain/entities/login_param/login_param_entity.dart';
import 'package:ProjectName/domain/repositories/auth_repository.dart';

@Injectable(as: AuthRepository)
class AuthRemoteDatasourceImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;

  AuthRemoteDatasourceImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthResponseEntity>> login(
    LoginParamEntity params,
  ) async {
    final body = LoginReqParamModel.fromDomain(params);

    final apiResult = await remoteDataSource.login(body);
    if (apiResult.isLeft()) {
      return left((apiResult as Left).value);
    }
    final TokenData response = (apiResult as Right).value;
    return right(response.toDomain());
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> logout() async {
    final apiResult = await remoteDataSource.logout();
    if (apiResult.isLeft()) {
      return left((apiResult as Left).value);
    }
    final AuthResponseModel response = (apiResult as Right).value;
    return right(response.toDomain());
  }
}
