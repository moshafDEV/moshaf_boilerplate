import 'package:equatable/equatable.dart';

/// Feature flags owned by the auth module. Add new auth-only flags here —
/// no other module should read or know about these fields.
class AuthFeatureFlags extends Equatable {
  final bool forgotPasswordEnabled;

  const AuthFeatureFlags({required this.forgotPasswordEnabled});

  static const disabled = AuthFeatureFlags(forgotPasswordEnabled: false);

  factory AuthFeatureFlags.fromJson(Map<String, dynamic> json) {
    return AuthFeatureFlags(
      forgotPasswordEnabled: json['forgot_password_enabled'] as bool? ?? false,
    );
  }

  /// Mirrors fromJson's keys — the single source both the developer-tools
  /// "copy expected response" button and the Feature Flags UI derive from.
  Map<String, dynamic> toJson() => {
        'forgot_password_enabled': forgotPasswordEnabled,
      };

  @override
  List<Object?> get props => [forgotPasswordEnabled];
}
