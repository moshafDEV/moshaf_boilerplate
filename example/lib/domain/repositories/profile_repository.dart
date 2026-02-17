import 'package:dartz/dartz.dart';
import 'package:example/core/error/failure.dart';
import 'package:example/domain/entities/profile/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> myProfile();
}
