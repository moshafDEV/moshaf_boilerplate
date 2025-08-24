// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_req_param_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginReqParamModel _$LoginReqParamModelFromJson(Map<String, dynamic> json) =>
    LoginReqParamModel(
      email: json['email'] as String,
      password: json['password'] as String,
      forceLogin: (json['force_login'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LoginReqParamModelToJson(LoginReqParamModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      if (instance.forceLogin case final value?) 'force_login': value,
    };
