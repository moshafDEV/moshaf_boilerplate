import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ProjectName/domain/entities/login_param/login_param_entity.dart';

part 'login_req_param_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LoginReqParamModel {
  final String email;
  final String password;
  final int? forceLogin;

  LoginReqParamModel({
    required this.email,
    required this.password,
    this.forceLogin,
  });

  Map<String, dynamic> toJson() => _$LoginReqParamModelToJson(this);

  factory LoginReqParamModel.fromDomain(LoginParamEntity domain) =>
      LoginReqParamModel(
        email: domain.email,
        password: domain.password,
        forceLogin: domain.forceLogin,
      );
}
