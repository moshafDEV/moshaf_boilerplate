import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:example_app/core/error/failure.dart';
import 'package:example_app/domain/entities/profile/profile_entity.dart';
import 'package:example_app/domain/repositories/profile_repository.dart';

@injectable
class ProfileUsecase {
  final ProfileRepository _repository;

  ProfileUsecase(this._repository);

  Future<Either<Failure, ProfileEntity>> execute() async {
    return await _repository.myProfile();
  }
}
