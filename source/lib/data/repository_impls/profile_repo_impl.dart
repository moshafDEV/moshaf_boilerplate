import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/data/datasources/remote/profile_remote_datasource.dart';
import 'package:ProjectName/data/models/profile/response/profile_reponse_model.dart';
import 'package:ProjectName/domain/entities/profile/profile_entity.dart';
import 'package:ProjectName/domain/repositories/profile_repository.dart';

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
