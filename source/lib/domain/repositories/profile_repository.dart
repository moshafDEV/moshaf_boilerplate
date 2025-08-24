import 'package:dartz/dartz.dart';
import 'package:ProjectName/core/error/failure.dart';
import 'package:ProjectName/domain/entities/profile/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> myProfile();
}
