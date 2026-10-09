import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';
import '../models/send_otp_model.dart';
import '../models/verify_otp_model.dart';
import '../services/api_service.dart';
import '../services/web_api_services.dart';

import '../helpers/sp_helper.dart';
import '../utils/sp_keys.dart' as sp_keys;

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
    debugPrint('   MOU Document Uploaded: ${loginModel.mouDocumentUploaded}');
    debugPrint('   Can Access App: ${loginModel.canAccessApp}');
    debugPrint('   Token: ${loginModel.token}');

    // 4. Save session and pass token to headers
    await saveLoginSession(loginModel);

    return loginModel;
  }

  /// Saves login session and initializes token headers
  Future<void> saveLoginSession(LoginModel loginModel) async {
    if (loginModel.token.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyToken, loginModel.token);
      await SpHelper.saveString('token', loginModel.token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sp_keys.keyToken, loginModel.token);
      await prefs.setString('token', loginModel.token);
    }
    await SpHelper.saveString(sp_keys.keyUserName, loginModel.username);
    await SpHelper.saveString(sp_keys.keyUseMobile, loginModel.phoneNumber);
    if (loginModel.userId > 0) {
      await SpHelper.saveString(sp_keys.keyUserId, loginModel.userId.toString());
    }
    if (loginModel.accountType.isNotEmpty) {
      await SpHelper.saveString('account_type', loginModel.accountType);
    }
    if (loginModel.mouStatus.isNotEmpty) {
      await SpHelper.saveString('mou_status', loginModel.mouStatus);
    }
    await SpHelper.saveBoolean('can_access_app', loginModel.canAccessApp);

    final prefs = await SharedPreferences.getInstance();
    if (loginModel.userId > 0) {
      await prefs.setInt('user_id', loginModel.userId);
    }
    await prefs.setString('username', loginModel.username);
    await prefs.setString('phone_number', loginModel.phoneNumber);
    if (loginModel.accountType.isNotEmpty) {
      await prefs.setString('account_type', loginModel.accountType);
    }
    if (loginModel.mouStatus.isNotEmpty) {
      await prefs.setString('mou_status', loginModel.mouStatus);
    }
    await prefs.setBool('mou_document_uploaded', loginModel.mouDocumentUploaded);
    await prefs.setBool('can_access_app', loginModel.canAccessApp);

    await WebAPIService().initTokenToHeader();
    debugPrint('💾 [AUTH REPOSITORY] Stored login token and configured API headers: ${loginModel.token}');
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
    if (sendOtpModel.otp != null) {
      debugPrint('   OTP: ${sendOtpModel.otp}');
    }

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

    // 3. Convert JSON Map to VerifyOtpModel
    final verifyOtpModel = VerifyOtpModel.fromJson(jsonMap);
    debugPrint('📦 [AUTH REPOSITORY] Successfully mapped to VerifyOtpModel:');
    debugPrint('   Message: ${verifyOtpModel.message}');
    debugPrint('   Phone Number: ${verifyOtpModel.phoneNumber}');
    debugPrint('   Is Registered: ${verifyOtpModel.isRegistered}');

    // 4. If the user is registered, call /api/login/ to retrieve and persist the token
    if (verifyOtpModel.isRegistered == true) {
      try {
        await login(
          phoneNumber: phoneNumber,
          otp: otp,
        );
      } catch (loginError) {
        debugPrint('⚠️ [AUTH REPOSITORY] Auto login after OTP verification error: $loginError');
      }
    }

    return verifyOtpModel;
  }

  /// Retrieves the saved token from SpHelper or SharedPreferences
  Future<String?> getSavedToken() async {
    final spToken = await SpHelper.getString(sp_keys.keyToken);
    if (spToken != null && spToken.trim().isNotEmpty) {
      return spToken.trim();
    }
    final spTokenAlt = await SpHelper.getString('token');
    if (spTokenAlt != null && spTokenAlt.trim().isNotEmpty) {
      return spTokenAlt.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    final prefKeyToken = prefs.getString(sp_keys.keyToken);
    if (prefKeyToken != null && prefKeyToken.trim().isNotEmpty) {
      return prefKeyToken.trim();
    }
    final prefToken = prefs.getString('token');
    if (prefToken != null && prefToken.trim().isNotEmpty) {
      return prefToken.trim();
    }
    return null;
  }

  /// Clears stored authentication credentials when logging out or session expires
  Future<void> clearSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sp_keys.keyToken);
    await prefs.remove(sp_keys.keyUserName);
    await prefs.remove(sp_keys.keyUseMobile);
    await prefs.remove(sp_keys.keyEmail);
    await prefs.remove(sp_keys.keyUserId);
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('phone_number');
    await prefs.remove('account_type');
    await prefs.remove('mou_status');
    await prefs.remove('can_access_app');
    await SpHelper.clearAll();
    debugPrint('🧹 [AUTH REPOSITORY] Cleared local authentication cache.');
  }

  /// Verifies whether a valid user session exists.
  /// If a token is available in SharedPreferences or SpHelper, initializes API headers and returns true.
  /// If no token is found, returns false to direct the user to Login.
  Future<bool> checkAuthStatus() async {
    final token = await getSavedToken();
    if (token == null || token.trim().isEmpty) {
      debugPrint('🔒 [AUTH REPOSITORY] No auth token found. User is unauthenticated.');
      return false;
    }

    debugPrint('🔑 [AUTH REPOSITORY] Stored token found ($token). Initializing API headers...');
    try {
      // Ensure the token is set in SpHelper and SharedPreferences for all modules
      await SpHelper.saveString(sp_keys.keyToken, token);
      await SpHelper.saveString('token', token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sp_keys.keyToken, token);
      await prefs.setString('token', token);

      // Initialize API headers with the authentication token
      await WebAPIService().initTokenToHeader();
    } catch (e) {
      debugPrint('⚠️ [AUTH REPOSITORY] Token header initialization warning: $e');
    }

    return true;
  }
}
