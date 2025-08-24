import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response_entity.freezed.dart';

@freezed
abstract class AuthResponseEntity with _$AuthResponseEntity {
  const factory AuthResponseEntity({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    String? refreshToken,
  }) = _AuthResponseEntity;

  factory AuthResponseEntity.initial() => const AuthResponseEntity(
    accessToken: '',
    tokenType: '',
    expiresIn: 0,
    refreshToken: null,
  );
}
