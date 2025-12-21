part of 'login_bloc.dart';

@freezed
abstract class LoginEvent with _$LoginEvent {
  const factory LoginEvent.onEmailChanged(String fieldValue) = _OnEmailChanged;
  const factory LoginEvent.onPasswordChanged(
    String fieldValue, {
    bool? togglePasswordVisibility,
  }) = _OnPasswordChanged;
  const factory LoginEvent.onSubmit() = _OnSubmit;
  const factory LoginEvent.getInfoProfile() = _GetInfoProfile;
}
