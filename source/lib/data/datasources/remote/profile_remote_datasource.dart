import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/constants/api_path_constant.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/core/http_client/main_client.dart';
import 'package:ProjectName/data/models/profile/response/profile_reponse_model.dart';

abstract class ProfileRemoteDatasource {
  Future<Either<Failure, ProfileResponseModel>> myProfile();
}

@LazySingleton(as: ProfileRemoteDatasource)
class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final MainClient _client;
  ProfileRemoteDatasourceImpl(this._client);

  @override
  Future<Either<Failure, ProfileResponseModel>> myProfile() async {
    try {
      final Response response = await _client.post(ApiPath.UUserProfile);
      final ProfileResponseModel profileResponse =
          ProfileResponseModel.fromJson(response.data);
      return right(profileResponse);
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
