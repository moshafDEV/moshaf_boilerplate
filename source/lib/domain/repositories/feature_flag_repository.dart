import 'package:ProjectName/domain/entities/feature_flags/feature_flag_state.dart';

/// Deliberately does not return `Either<Failure, T>` like the other
/// repositories in this codebase: a broken flags endpoint should never
/// surface as a user-facing error, only degrade every flag to off. The
/// fallback is the implementation's responsibility, not the caller's.
abstract class FeatureFlagRepository {
  Future<FeatureFlagState> getFeatureFlags();
}
