import 'package:dartz/dartz.dart';
import 'package:example_app/core/error/failure.dart';
import 'package:example_app/domain/entities/profile/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> myProfile();
}
