import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_entity.freezed.dart';

@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({
    required String name,
    required String email,
    required String phone,
    required String profile,
  }) = _ProfileEntity;

  factory ProfileEntity.initial() =>
      const ProfileEntity(name: '', email: '', phone: '', profile: '');
}
