import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_param_entity.freezed.dart';

@freezed
abstract class LoginParamEntity with _$LoginParamEntity {
  const factory LoginParamEntity({
    required String email,
    required String password,
    int? forceLogin,
  }) = _LoginParamEntity;

  factory LoginParamEntity.initial() =>
      const LoginParamEntity(email: '', password: '', forceLogin: null);
}
