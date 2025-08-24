import 'package:ProjectName/data/models/login/response/token_model.dart';
import 'package:ProjectName/domain/entities/auth/auth_response_entity.dart';

class AuthResponseModel {
  final int? code;
  final String? message;
  final TokenData? data;
  final Map<String, dynamic>? error;

  AuthResponseModel({this.code, this.message, this.data, this.error});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        code: json['code'],
        message: json['message'],
        data: json['data'] == null ? null : TokenData.fromJson(json['data']),
        error: json['error'],
      );

  AuthResponseEntity toDomain() {
    return AuthResponseEntity(
      accessToken: data?.accessToken ?? '',
      tokenType: data?.tokenType ?? '',
      expiresIn: data?.expiresIn ?? 0,
      refreshToken: data?.refreshToken,
    );
  }

  factory AuthResponseModel.fromDomain(AuthResponseEntity domain) =>
      AuthResponseModel(
        code: 200,
        message: 'Success',
        data: TokenData(
          accessToken: domain.accessToken,
          tokenType: domain.tokenType,
          expiresIn: domain.expiresIn,
          refreshToken: domain.refreshToken,
        ),
        error: null,
      );
}
