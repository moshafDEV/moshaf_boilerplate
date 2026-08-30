import 'package:equatable/equatable.dart';

/// Feature flags owned by the profile module.
class ProfileFeatureFlags extends Equatable {
  final bool profileV2Enabled;

  const ProfileFeatureFlags({required this.profileV2Enabled});

  static const disabled = ProfileFeatureFlags(profileV2Enabled: false);

  factory ProfileFeatureFlags.fromJson(Map<String, dynamic> json) {
    return ProfileFeatureFlags(
      profileV2Enabled: json['profile_v2_enabled'] as bool? ?? false,
    );
  }

  /// Mirrors fromJson's keys — the single source both the developer-tools
  /// "copy expected response" button and the Feature Flags UI derive from.
  Map<String, dynamic> toJson() => {
        'profile_v2_enabled': profileV2Enabled,
      };

  @override
  List<Object?> get props => [profileV2Enabled];
}
