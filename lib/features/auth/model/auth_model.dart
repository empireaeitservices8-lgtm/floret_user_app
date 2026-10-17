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

class SignupResponseModel {
  final bool success;
  final String message;
  final int? userId;
  final String? username;
  final String? phoneNumber;
  final String? accountType;
  final bool requiresPayment;
  final num totalAmount;
  final String? token;

  const SignupResponseModel({
    required this.success,
    required this.message,
    this.userId,
    this.username,
    this.phoneNumber,
    this.accountType,
    this.requiresPayment = false,
    this.totalAmount = 0,
    this.token,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    String? extractTokenFromMap(Map? map) {
      if (map == null) return null;
      final candidates = [
        map['token'],
        map['access_token'],
        map['accessToken'],
        map['access'],
        map['key'],
        map['auth_token'],
        map['authToken'],
        map['jwt'],
      ];
      for (final candidate in candidates) {
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          return candidate.toString().trim();
        }
      }
      return null;
    }

    String? extractedToken = extractTokenFromMap(json);

    if (extractedToken == null && json['data'] is Map) {
      extractedToken = extractTokenFromMap(json['data'] as Map);
    }
    if (extractedToken == null && json['user'] is Map) {
      extractedToken = extractTokenFromMap(json['user'] as Map);
    }
    if (extractedToken == null && json['tokens'] is Map) {
      extractedToken = extractTokenFromMap(json['tokens'] as Map);
    }
    if (extractedToken == null && json['result'] is Map) {
      extractedToken = extractTokenFromMap(json['result'] as Map);
    }
    if (extractedToken == null && json['response'] is Map) {
      extractedToken = extractTokenFromMap(json['response'] as Map);
    }
    if (extractedToken == null && json['auth'] is Map) {
      extractedToken = extractTokenFromMap(json['auth'] as Map);
    }

    return SignupResponseModel(
      success: true,
      message: json['message'] as String? ??
          'Registration completed successfully. Welcome to Safai 365!',
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ??
              json['id']?.toString() ??
              (json['data'] is Map ? json['data']['user_id']?.toString() ?? '' : '')),
      username: json['username'] as String? ??
          (json['data'] is Map ? json['data']['username']?.toString() : null),
      phoneNumber: json['phone_number'] as String? ??
          json['phone'] as String? ??
          (json['data'] is Map ? json['data']['phone_number']?.toString() : null),
      accountType: json['account_type'] as String?,
      requiresPayment: json['requires_payment'] as bool? ?? false,
      totalAmount: json['total_amount'] as num? ?? 0,
      token: extractedToken,
    );
  }

  SignupResponseModel copyWith({
    bool? success,
    String? message,
    int? userId,
    String? username,
    String? phoneNumber,
    String? accountType,
    bool? requiresPayment,
    num? totalAmount,
    String? token,
  }) {
    return SignupResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountType: accountType ?? this.accountType,
      requiresPayment: requiresPayment ?? this.requiresPayment,
      totalAmount: totalAmount ?? this.totalAmount,
      token: token ?? this.token,
    );
  }

  factory SignupResponseModel.fromError(String errorMessage) {
    return SignupResponseModel(
      success: false,
      message: errorMessage,
      requiresPayment: false,
      totalAmount: 0,
      token: null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'user_id': userId,
        'username': username,
        'phone_number': phoneNumber,
        'account_type': accountType,
        'requires_payment': requiresPayment,
        'total_amount': totalAmount,
        'token': token,
      };
}

class SignupRequestModel {
  final String phone;
  final String firstName;
  final String lastName;
  final String accountType; // Residential or Commercial
  final String? mouDocumentPath;
  final String? mouDocumentName;
  final double registrationFee;
  final String streetAddress;
  final String city;
  final String state;
  final String district;
  final String localBody;
  final String ward;
  final String zipCode;
  final bool termsAccepted;
  final double? latitude;
  final double? longitude;

  const SignupRequestModel({
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.accountType = 'Residential',
    this.mouDocumentPath,
    this.mouDocumentName,
    this.registrationFee = 0.0,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.district,
    required this.localBody,
    required this.ward,
    required this.zipCode,
    this.termsAccepted = true,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final cleanPhone = phone.startsWith('+')
        ? phone
        : (phone.startsWith('91') && phone.length == 12
            ? '+$phone'
            : '+91$phone');
    final fullName = '$firstName $lastName'.trim();
    final accType = accountType.toLowerCase();

    return {
      'username': cleanPhone,
      'email': '$cleanPhone@floret.com',
      'phone_number': cleanPhone,
      'password': cleanPhone,
      'phone': cleanPhone,
      'account_type': accType,
      'first_name': firstName,
      'last_name': lastName,
      'name': fullName,
      'street': streetAddress,
      'street_address': streetAddress,
      'address': streetAddress,
      'city': city,
      'state': state,
      'district': district,
      'local_body': localBody,
      'ward': ward,
      'zip_code': zipCode,
      'pincode': zipCode,
      'postal_code': zipCode,
      'otp': '',
      'mou_document': '',
      'terms_accepted': termsAccepted,
      'registration_fee': accType == 'commercial' ? 1000 : 0,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (mouDocumentName != null) 'mou_document_name': mouDocumentName,
      if (mouDocumentPath != null) 'mou_document_path': mouDocumentPath,
    };
  }
}
