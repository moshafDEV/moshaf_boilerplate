import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:example/domain/entities/feature_flags/feature_flag_state.dart';
import 'package:example/domain/repositories/feature_flag_repository.dart';

/// Single global instance (registered via @lazySingleton, exposed to the
/// widget tree with a single ChangeNotifierProvider.value in main.dart) —
/// every module reads its own slice off `state`, nobody fetches on its own.
@lazySingleton
class FeatureFlagNotifier extends ChangeNotifier {
  final FeatureFlagRepository _repository;

  FeatureFlagNotifier(this._repository);

  FeatureFlagState _state = FeatureFlagState.disabled;
  FeatureFlagState get state => _state;

  Future<void> initialize() async {
    _state = await _repository.getFeatureFlags();
    notifyListeners();
  }
}
