import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:example_app/core/error/failure.dart';
import 'package:example_app/data/datasources/remote/profile_remote_datasource.dart';
import 'package:example_app/data/models/profile/response/profile_reponse_model.dart';
import 'package:example_app/domain/entities/profile/profile_entity.dart';
import 'package:example_app/domain/repositories/profile_repository.dart';

@Injectable(as: ProfileRepository)
class ProfileRemoteDatasourceImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDataSource;

  ProfileRemoteDatasourceImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> myProfile() async {
    final apiResult = await remoteDataSource.myProfile();
    if (apiResult.isLeft()) {
      return left((apiResult as Left).value);
    }
    final ProfileResponseModel response = (apiResult as Right).value;
    return right(response.toDomain());
  }
}
