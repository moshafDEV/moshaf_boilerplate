// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_reponse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponseModel _$ProfileResponseModelFromJson(
  Map<String, dynamic> json,
) => ProfileResponseModel(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : ProfileModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileResponseModelToJson(
  ProfileResponseModel instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  if (instance.data?.toJson() case final value?) 'data': value,
};
