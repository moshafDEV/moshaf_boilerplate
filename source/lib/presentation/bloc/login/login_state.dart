part of 'login_bloc.dart';

@freezed
abstract class LoginState with _$LoginState {
  factory LoginState({
    required TextInputFieldEntity email,
    required TextInputFieldEntity password,
    @Default(false) bool isLoading,
    @Default(false) bool successLogin,
    @Default('') String errorResponseMessage,
  }) = _LoginState;

  factory LoginState.initial() => LoginState(
    email: TextInputFieldEntity.initial(),
    password: TextInputFieldEntity.initial(),
    isLoading: false,
    successLogin: false,
    errorResponseMessage: '',
  );
}
