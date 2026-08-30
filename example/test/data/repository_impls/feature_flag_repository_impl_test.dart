import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:example/core/feature_flags/feature_flag_api.dart';
import 'package:example/data/repository_impls/feature_flag_repository_impl.dart';
import 'package:example/domain/entities/feature_flags/feature_flag_state.dart';

class _MockFeatureFlagApi extends Mock implements FeatureFlagApi {}

void main() {
  late _MockFeatureFlagApi api;
  late FeatureFlagRepositoryImpl repository;

  setUp(() {
    api = _MockFeatureFlagApi();
    repository = FeatureFlagRepositoryImpl(api);
  });

  test('API success with flag true maps to enabled state', () async {
    when(() => api.fetchFeatureFlags()).thenAnswer((_) async => {
          'features': {
            'auth': {'forgot_password_enabled': true},
            'profile': {'profile_v2_enabled': false},
          },
        });

    final state = await repository.getFeatureFlags();

    expect(state.auth.forgotPasswordEnabled, isTrue);
  });

  test('API success with flag false maps to disabled state', () async {
    when(() => api.fetchFeatureFlags()).thenAnswer((_) async => {
          'features': {
            'auth': {'forgot_password_enabled': false},
            'profile': {'profile_v2_enabled': true},
          },
        });

    final state = await repository.getFeatureFlags();

    expect(state.auth.forgotPasswordEnabled, isFalse);
    expect(state.profile.profileV2Enabled, isTrue);
  });

  test('API timeout falls back to disabled', () async {
    when(() => api.fetchFeatureFlags()).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/v1/config/feature-flags'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final state = await repository.getFeatureFlags();

    expect(state, FeatureFlagState.disabled);
  });

  test('API generic failure falls back to disabled', () async {
    when(() => api.fetchFeatureFlags()).thenThrow(Exception('boom'));

    final state = await repository.getFeatureFlags();

    expect(state, FeatureFlagState.disabled);
  });

  test('malformed module payload falls back only for that module', () async {
    when(() => api.fetchFeatureFlags()).thenAnswer((_) async => {
          'features': {
            'auth': 'not-a-map',
            'profile': {'profile_v2_enabled': true},
          },
        });

    final state = await repository.getFeatureFlags();

    expect(state.auth.forgotPasswordEnabled, isFalse);
    expect(state.profile.profileV2Enabled, isTrue);
  });
}
