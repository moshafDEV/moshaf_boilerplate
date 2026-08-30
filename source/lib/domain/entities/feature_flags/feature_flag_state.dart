import 'package:equatable/equatable.dart';
import 'package:ProjectName/domain/entities/feature_flags/auth_feature_flags.dart';
import 'package:ProjectName/domain/entities/feature_flags/profile_feature_flags.dart';

/// Global, immutable snapshot of every module's feature flags. To add a new
/// module: create its own `<Module>FeatureFlags` entity, add a field for it
/// here, and add its key under `features` in fromJson — existing modules are
/// untouched.
class FeatureFlagState extends Equatable {
  final AuthFeatureFlags auth;
  final ProfileFeatureFlags profile;

  const FeatureFlagState({
    required this.auth,
    required this.profile,
  });

  static const disabled = FeatureFlagState(
    auth: AuthFeatureFlags.disabled,
    profile: ProfileFeatureFlags.disabled,
  );

  /// Each module is parsed independently, so one module's malformed data
  /// falls back to disabled without dragging the others down with it.
  factory FeatureFlagState.fromJson(Map<String, dynamic> json) {
    final features = json['features'] as Map<String, dynamic>? ?? {};
    return FeatureFlagState(
      auth: features['auth'] is Map<String, dynamic>
          ? AuthFeatureFlags.fromJson(features['auth'] as Map<String, dynamic>)
          : AuthFeatureFlags.disabled,
      profile: features['profile'] is Map<String, dynamic>
          ? ProfileFeatureFlags.fromJson(
              features['profile'] as Map<String, dynamic>)
          : ProfileFeatureFlags.disabled,
    );
  }

  /// Mirrors fromJson's shape exactly — this is what a working backend
  /// endpoint should return. Single source for both the "copy expected
  /// response" button and the on-screen list in the Feature Flags dialog
  /// (see feature_flags_dialog.dart) — add a module here once, both update.
  Map<String, dynamic> toJson() => {
        'features': {
          'auth': auth.toJson(),
          'profile': profile.toJson(),
        },
      };

  @override
  List<Object?> get props => [auth, profile];
}
