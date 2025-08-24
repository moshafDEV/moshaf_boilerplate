import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/domain/entities/profile/profile_entity.dart';
import 'package:ProjectName/domain/repositories/profile_repository.dart';

@injectable
class ProfileUsecase {
  final ProfileRepository _repository;

  ProfileUsecase(this._repository);

  Future<Either<Failure, ProfileEntity>> execute() async {
    return await _repository.myProfile();
  }
}
