class LoginModel {
  final String token;
  final int userId;
  final String username;
  final String phoneNumber;
  final String accountType;
  final String mouStatus;
  final bool canAccessApp;

  const LoginModel({
    required this.token,
    required this.userId,
    required this.username,
    required this.phoneNumber,
    required this.accountType,
    required this.mouStatus,
    required this.canAccessApp,
  });

  /// Factory constructor to create a LoginModel instance from a JSON map
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'] as String? ?? '',
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      accountType: json['account_type'] as String? ?? '',
      mouStatus: json['mou_status'] as String? ?? '',
      canAccessApp: json['can_access_app'] as bool? ?? false,
    );
  }

  /// Converts the LoginModel instance back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_id': userId,
      'username': username,
      'phone_number': phoneNumber,
      'account_type': accountType,
      'mou_status': mouStatus,
      'can_access_app': canAccessApp,
    };
  }

  @override
  String toString() {
    return 'LoginModel(token: $token, userId: $userId, username: $username, phoneNumber: $phoneNumber, accountType: $accountType, mouStatus: $mouStatus, canAccessApp: $canAccessApp)';
  }
}
