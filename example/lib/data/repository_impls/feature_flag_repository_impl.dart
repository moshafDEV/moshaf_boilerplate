import 'package:injectable/injectable.dart';
import 'package:example/core/feature_flags/feature_flag_api.dart';
import 'package:example/domain/entities/feature_flags/feature_flag_state.dart';
import 'package:example/domain/repositories/feature_flag_repository.dart';

@LazySingleton(as: FeatureFlagRepository)
class FeatureFlagRepositoryImpl implements FeatureFlagRepository {
  final FeatureFlagApi _api;

  FeatureFlagRepositoryImpl(this._api);

  @override
  Future<FeatureFlagState> getFeatureFlags() async {
    try {
      final json = await _api.fetchFeatureFlags();
      return FeatureFlagState.fromJson(json);
    } catch (_) {
      // Network error, timeout, or malformed response — every flag off is
      // the only safe default, since it always matches already-shipped
      // behavior.
      return FeatureFlagState.disabled;
    }
  }
}
