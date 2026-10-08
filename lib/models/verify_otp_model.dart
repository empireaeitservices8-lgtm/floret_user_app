class VerifyOtpModel {
  final String? message;
  final String? phoneNumber;
  final bool? isRegistered;

  const VerifyOtpModel({
    this.message,
    this.phoneNumber,
    this.isRegistered,
  });

  /// Factory constructor to deserialize JSON into VerifyOtpModel
  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      message: json['message'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isRegistered: json['is_registered'] as bool?,
    );
  }

  /// Converts VerifyOtpModel back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (message != null) 'message': message,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (isRegistered != null) 'is_registered': isRegistered,
    };
  }

  @override
  String toString() {
    return 'VerifyOtpModel(message: $message, phoneNumber: $phoneNumber, isRegistered: $isRegistered)';
  }
}
