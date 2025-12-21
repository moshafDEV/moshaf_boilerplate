class ProfileModel {
  final String? profile;
  final String? name;
  final String? email;
  final String? phone;

  ProfileModel({this.profile, this.name, this.email, this.phone});

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    profile: json['profile'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
  );

  Map<String, dynamic> toJson() => {
    'profile': profile,
    'name': name,
    'email': email,
    'phone': phone,
  };
}
