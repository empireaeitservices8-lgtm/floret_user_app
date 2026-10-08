class SendOtpModel {
  final String? message;
  final String? otp;

  const SendOtpModel({
    this.message,
    this.otp,
  });

  /// Factory constructor to create SendOtpModel from JSON response
  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      message: json['message'] as String?,
      otp: json['otp']?.toString(),
    );
  }

  /// Converts SendOtpModel back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (message != null) 'message': message,
      if (otp != null) 'otp': otp,
    };
  }

  @override
  String toString() {
    // Redact OTP in toString for security
    return 'SendOtpModel(message: $message, otp: [REDACTED])';
  }
}
