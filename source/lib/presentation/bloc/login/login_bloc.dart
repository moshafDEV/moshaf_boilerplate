import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ProjectName/core/env/secure_storage_key.dart';
import 'package:ProjectName/core/utils/storage_data.dart';
import 'package:ProjectName/core/utils/validators.dart';
import 'package:ProjectName/data/models/login/response/auth_response_model.dart';
import 'package:ProjectName/data/models/profile/response/profile_reponse_model.dart';
import 'package:ProjectName/domain/entities/login_param/login_param_entity.dart';
import 'package:ProjectName/domain/entities/text_input_field/text_input_field_entity.dart';
import 'package:ProjectName/domain/usecase/login/login.dart';
import 'package:ProjectName/domain/usecase/login/profile.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;
  final ProfileUsecase profileUsecase;

  LoginBloc(this.loginUsecase, this.profileUsecase)
    : super(LoginState.initial()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<LoginState> emit) async {
    switch (event) {
      case _OnEmailChanged(:final String fieldValue):
        emit(
          state.copyWith(
            email: state.email.copyWith(
              value: fieldValue,
              // invalidMessage: Validators.checkEmailValidity(fieldValue), realtime validation
            ),
          ),
        );

      case _OnPasswordChanged(
        :final String fieldValue,
        :final bool? togglePasswordVisibility,
      ):
        if (togglePasswordVisibility != null) {
          emit(
            state.copyWith(
              password: state.password.copyWith(
                isVisiblePassword: togglePasswordVisibility,
              ),
            ),
          );
        }
        emit(
          state.copyWith(
            password: state.password.copyWith(
              value: fieldValue,
              // invalidMessage: Validators.isNotEmpty(
              //   fieldValue,
              //   fieldName: 'Password',
              // ), // realtime validation
            ),
          ),
        );

      case _OnSubmit():
        emit(state.copyWith(errorResponseMessage: ''));
        // if (state.isLoading) break;

        // Validate email and password before submission
        emit(
          state.copyWith(
            email: state.email.copyWith(
              invalidMessage: Validators.checkEmailValidity(state.email.value),
            ),
            password: state.password.copyWith(
              invalidMessage: Validators.isNotEmpty(
                state.password.value,
                fieldName: 'Password',
              ),
            ),
          ),
        );
        if (state.email.invalidMessage != null ||
            state.password.invalidMessage != null) {
          break;
        }

        emit(state.copyWith(isLoading: true));
        final result = await loginUsecase.execute(
          LoginParamEntity(
            email: state.email.value,
            password: state.password.value,
          ),
        );
        result.fold(
          (failure) => emit(
            state.copyWith(
              isLoading: false,
              errorResponseMessage: failure.message,
            ),
          ),
          (response) async {
            // Validate the response and store the token data
            final authJson = AuthResponseModel.fromDomain(
              response,
            ).data?.toJson();
            if (authJson == null) {
              emit(
                state.copyWith(
                  isLoading: false,
                  successLogin: false,
                  errorResponseMessage: 'Invalid response data',
                ),
              );
              return;
            }
            await SecureStorageUtils.setStorage(
              bearerToken,
              response.accessToken,
            );
            await SecureStorageUtils.setStorageJSON(authData, authJson);

            // Set the bearer token for the HTTP service
            // httpService.setLanguage('en');
            // httpService.setBearer(response.accessToken);
            // MainClient(null).addBearer(response.accessToken);

            // Fetch user profile information
            add(const LoginEvent.getInfoProfile());
          },
        );
      case _GetInfoProfile():
        final result = await profileUsecase.execute();
        result.fold(
          (failure) => emit(
            state.copyWith(
              isLoading: false,
              errorResponseMessage: failure.message,
            ),
          ),
          (response) async {
            // Store the profile data
            final profileJson = ProfileResponseModel.fromDomain(
              response,
            ).data?.toJson();
            if (profileJson == null) {
              emit(
                state.copyWith(
                  isLoading: false,
                  successLogin: false,
                  errorResponseMessage: 'Invalid response profile data',
                ),
              );
              return;
            }
            emit(state.copyWith(isLoading: false, successLogin: true));
            await SecureStorageUtils.setStorageJSON(userData, profileJson);
          },
        );
        break;
    }
    return Future.value();
  }
}
