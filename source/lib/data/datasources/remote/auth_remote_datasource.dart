import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/constants/api_path_constant.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/core/http_client/main_client.dart';
import 'package:ProjectName/data/models/login/request/login_req_param_model.dart';
import 'package:ProjectName/data/models/login/response/auth_response_model.dart';
import 'package:ProjectName/data/models/login/response/token_model.dart';

abstract class AuthRemoteDatasource {
  Future<Either<Failure, TokenData>> login(LoginReqParamModel loginParam);
  Future<Either<Failure, AuthResponseModel>> logout();
}

@LazySingleton(as: AuthRemoteDatasource)
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final MainClient _client;
  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<Either<Failure, TokenData>> login(
    LoginReqParamModel loginParam,
  ) async {
    try {
      final response = await _client.post(
        ApiPath.ULogin,
        data: loginParam.toJson(),
      );
      final TokenData loginResponse = TokenData.fromJson(response.data);
      return right(loginResponse);
    } on DioException catch (e) {
      return left(
        ServerFailure(
          e.response?.data['message'] ?? 'Something went wrong',
          e.response?.statusCode,
        ),
      );
    } catch (e) {
      return left(ServerFailure('Unexpected error', e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> logout() async {
    try {
      final Response response = await _client.post(ApiPath.ULogout);
      final AuthResponseModel logoutResponse = AuthResponseModel.fromJson(
        response.data,
      );
      return right(logoutResponse);
    } on DioException catch (e) {
      return left(
        ServerFailure(
          e.response?.data['message'] ?? 'Something went wrong',
          e.response?.statusCode,
        ),
      );
    } catch (e) {
      return left(ServerFailure('Unexpected error', e.toString()));
    }
  }
}
