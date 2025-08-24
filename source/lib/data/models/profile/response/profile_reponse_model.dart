import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ProjectName/data/models/profile/response/profile_model.dart';
import 'package:ProjectName/domain/entities/profile/profile_entity.dart';

part 'profile_reponse_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ProfileResponseModel {
  final int? code;
  final String? message;
  final ProfileModel? data;

  ProfileResponseModel({required this.code, required this.message, this.data});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      ProfileResponseModel(
        code: json['code'],
        message: json['message'],
        data: json['data'] == null ? null : ProfileModel.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);

  factory ProfileResponseModel.fromDomain(ProfileEntity domain) =>
      ProfileResponseModel(
        code: 200,
        message: 'Success',
        data: ProfileModel(
          name: domain.name,
          email: domain.email,
          phone: domain.phone,
          profile: domain.profile,
        ),
      );

  ProfileEntity toDomain() => ProfileEntity(
    name: data?.name ?? '',
    email: data?.email ?? '',
    phone: data?.phone ?? '',
    profile: data?.profile ?? '',
  );
}
