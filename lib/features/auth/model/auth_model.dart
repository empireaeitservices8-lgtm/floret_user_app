class UserModel {
  final String phone;
  final String name;
  final String? email;
  final String? token;

  const UserModel({
    required this.phone,
    required this.name,
    this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        if (email != null) 'email': email,
        if (token != null) 'token': token,
      };
}

class LoginRequestModel {
  final String phone;

  const LoginRequestModel({required this.phone});

  Map<String, dynamic> toJson() => {
        'phone': phone,
      };
}

class OtpVerifyRequestModel {
  final String phone;
  final String otp;

  const OtpVerifyRequestModel({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}

class AuthResponseModel {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  const AuthResponseModel({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }
}
