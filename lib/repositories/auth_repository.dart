import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/login_model.dart';
import '../models/send_otp_model.dart';
import '../models/verify_otp_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Authenticates user credentials via ApiService and transforms response into LoginModel
  Future<LoginModel> login({
    required String phoneNumber,
    required String otp,
  }) async {
    // 1. Delegate network call to ApiService
    final response = await _apiService.login(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    // 2. Parse response data safely
    final dynamic responseData = response.data;
    final Map<String, dynamic> jsonMap;

    if (responseData is Map<String, dynamic>) {
      jsonMap = responseData;
    } else if (responseData is Map) {
      jsonMap = Map<String, dynamic>.from(responseData);
    } else if (responseData is String) {
      jsonMap = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      debugPrint('❌ [AUTH REPOSITORY ERROR] Invalid response format received from server.');
      throw Exception('Invalid response format received from server.');
    }

    // 3. Convert JSON Map to LoginModel and return to ViewModel
    final loginModel = LoginModel.fromJson(jsonMap);
    debugPrint('📦 [AUTH REPOSITORY] Successfully mapped to LoginModel:');
    debugPrint('   User ID: ${loginModel.userId}');
    debugPrint('   Username: ${loginModel.username}');
    debugPrint('   Phone: ${loginModel.phoneNumber}');
    debugPrint('   Account Type: ${loginModel.accountType}');
    debugPrint('   MOU Status: ${loginModel.mouStatus}');
    debugPrint('   Can Access App: ${loginModel.canAccessApp}');
    debugPrint('   Token: ${loginModel.token.isNotEmpty ? "${loginModel.token.substring(0, 10)}..." : "Empty"}');

    return loginModel;
  }

  /// Sends OTP to the provided phone number via ApiService and converts response to SendOtpModel
  Future<SendOtpModel> sendOtp(String phoneNumber) async {
    // 1. Call ApiService.sendOtp
    final response = await _apiService.sendOtp(phoneNumber);

    // 2. Safely parse response data
    final dynamic responseData = response.data;
    final Map<String, dynamic> jsonMap;

    if (responseData is Map<String, dynamic>) {
      jsonMap = responseData;
    } else if (responseData is Map) {
      jsonMap = Map<String, dynamic>.from(responseData);
    } else if (responseData is String) {
      jsonMap = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      debugPrint('❌ [AUTH REPOSITORY ERROR] Invalid response format for sendOtp');
      throw Exception('Invalid response format received from server.');
    }

    // 3. Convert JSON to SendOtpModel and return to ViewModel
    final sendOtpModel = SendOtpModel.fromJson(jsonMap);
    debugPrint('📦 [AUTH REPOSITORY] Successfully mapped to SendOtpModel:');
    debugPrint('   Message: ${sendOtpModel.message}');
    // Security: Do not log or print the raw OTP

    return sendOtpModel;
  }

  /// Verifies OTP for the given phone number via ApiService and converts response to VerifyOtpModel
  Future<VerifyOtpModel> verifyOtp(String phoneNumber, String otp) async {
    // 1. Delegate network call to ApiService
    final response = await _apiService.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    // 2. Parse response data safely
    final dynamic responseData = response.data;
    final Map<String, dynamic> jsonMap;

    if (responseData is Map<String, dynamic>) {
      jsonMap = responseData;
    } else if (responseData is Map) {
      jsonMap = Map<String, dynamic>.from(responseData);
    } else if (responseData is String) {
      jsonMap = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      debugPrint('❌ [AUTH REPOSITORY ERROR] Invalid response format for verifyOtp');
      throw Exception('Invalid response format received from server.');
    }

    // 3. Convert JSON Map to VerifyOtpModel and return to ViewModel
    final verifyOtpModel = VerifyOtpModel.fromJson(jsonMap);
    debugPrint('📦 [AUTH REPOSITORY] Successfully mapped to VerifyOtpModel:');
    debugPrint('   Message: ${verifyOtpModel.message}');
    debugPrint('   Phone Number: ${verifyOtpModel.phoneNumber}');
    debugPrint('   Is Registered: ${verifyOtpModel.isRegistered}');

    return verifyOtpModel;
  }
}
