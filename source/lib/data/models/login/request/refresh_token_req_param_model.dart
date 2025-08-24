class RefreshTokenReqParamModel {
  final String refreshToken;

  RefreshTokenReqParamModel({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}
