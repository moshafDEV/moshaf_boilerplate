import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/error/failure.dart';
import 'package:example/domain/entities/profile/profile_entity.dart';
import 'package:example/domain/repositories/profile_repository.dart';

@injectable
class ProfileUsecase {
  final ProfileRepository _repository;

  ProfileUsecase(this._repository);

  Future<Either<Failure, ProfileEntity>> execute() async {
    return await _repository.myProfile();
  }
}
