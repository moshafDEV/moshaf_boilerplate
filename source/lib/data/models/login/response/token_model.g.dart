// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenData _$TokenDataFromJson(Map<String, dynamic> json) => TokenData(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String?,
  tokenType: json['token_type'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$TokenDataToJson(TokenData instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  if (instance.refreshToken case final value?) 'refresh_token': value,
  'token_type': instance.tokenType,
  'expires_in': instance.expiresIn,
};
