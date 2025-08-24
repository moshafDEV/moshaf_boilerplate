import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ProjectName/domain/entities/auth/auth_response_entity.dart';

part 'token_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TokenData {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;

  TokenData({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  Map<String, dynamic> toJson() => _$TokenDataToJson(this);

  factory TokenData.fromJson(Map<String, dynamic> json) => TokenData(
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
    tokenType: json['token_type'],
    expiresIn: json['expires_in'],
  );

  AuthResponseEntity toDomain() {
    return AuthResponseEntity(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      refreshToken: refreshToken,
    );
  }
}
