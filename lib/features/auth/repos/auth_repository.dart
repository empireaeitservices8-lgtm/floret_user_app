import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/services/api_endpoints.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/services/api_service.dart';
import '../model/auth_model.dart';

class AuthRepository {
  final WebAPIService _webAPIService;
  final ApiService _apiService;

  AuthRepository({WebAPIService? webAPIService, ApiService? apiService})
      : _webAPIService = webAPIService ?? WebAPIService(),
        _apiService = apiService ?? ApiService();

  WebAPIService get webAPIService => _webAPIService;
  ApiService get apiService => _apiService;

  Future<AuthResponseModel> sendOtp(String mobileNumber) async {
    try {
      final formattedPhone = mobileNumber.startsWith('+')
          ? mobileNumber
          : (mobileNumber.startsWith('91') && mobileNumber.length == 12
              ? '+$mobileNumber'
              : '+91$mobileNumber');

      final response = await _apiService.sendOtp(formattedPhone);
      final resData = response.data is Map ? response.data as Map : {};
      final message = resData['message']?.toString() ?? 'OTP sent successfully.';

      return AuthResponseModel(
        success: true,
        message: message,
      );
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      return AuthResponseModel(
        success: false,
        message: errorMsg,
      );
    }
  }

  Future<AuthResponseModel> verifyOtp(String mobileNumber, String otp) async {
    try {
      final formattedPhone = mobileNumber.startsWith('+')
          ? mobileNumber
          : (mobileNumber.startsWith('91') && mobileNumber.length == 12
              ? '+$mobileNumber'
              : '+91$mobileNumber');

      debugPrint('🚀 [API REQUEST] Verifying OTP / Logging in with phone: $formattedPhone');
      final response = await _apiService.login(
        phoneNumber: formattedPhone,
        otp: otp,
      );

      final resData = response.data is Map ? response.data as Map : {};
      final token = resData['token']?.toString() ?? '';
      final username = resData['username']?.toString() ?? mobileNumber;
      final userId = resData['user_id']?.toString() ?? '';
      final accountType = resData['account_type']?.toString() ?? '';
      final mouStatus = resData['mou_status']?.toString() ?? '';
      final canAccessApp = resData['can_access_app'] == true;

      final user = UserModel(
        phone: formattedPhone,
        name: username,
        token: token,
      );

      if (token.isNotEmpty) {
        await SpHelper.saveString(sp_keys.keyToken, token);
        await SpHelper.saveString('token', token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(sp_keys.keyToken, token);
        await prefs.setString('token', token);
      }
      await SpHelper.saveString(sp_keys.keyUserName, username);
      await SpHelper.saveString(sp_keys.keyUseMobile, formattedPhone);
      if (userId.isNotEmpty) {
        await SpHelper.saveString(sp_keys.keyUserId, userId);
      }
      if (accountType.isNotEmpty) {
        await SpHelper.saveString('account_type', accountType);
      }
      if (mouStatus.isNotEmpty) {
        await SpHelper.saveString('mou_status', mouStatus);
      }
      await SpHelper.saveBoolean('can_access_app', canAccessApp);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone_number', formattedPhone);
      await prefs.setString('username', username);
      if (userId.isNotEmpty) {
        await prefs.setString('user_id', userId);
      }
      if (accountType.isNotEmpty) {
        await prefs.setString('account_type', accountType);
      }
      if (mouStatus.isNotEmpty) {
        await prefs.setString('mou_status', mouStatus);
      }
      await prefs.setBool('can_access_app', canAccessApp);
      await _webAPIService.initTokenToHeader();

      debugPrint('✅ [API RESPONSE] Successfully authenticated with real server token: $token');
      return AuthResponseModel(
        success: true,
        message: 'OTP verified successfully',
        user: user,
        token: token,
      );
    } catch (e) {
      debugPrint('❌ [API ERROR] Verify OTP error: $e');
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      return AuthResponseModel(
        success: false,
        message: errorMsg,
      );
    }
  }

  Future<SignupResponseModel> registerUser(SignupRequestModel request) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            "Accept": "application/json",
          },
        ),
      );

      final fullUrl = '${ApiEndpoints.baseUrl}${ApiEndpoints.register}';
      final requestData = request.toJson();

      debugPrint('================================================================');
      debugPrint('🚀 [REGISTRATION API REQUEST]');
      debugPrint('URL: $fullUrl');
      debugPrint('Method: POST');
      debugPrint('Headers: {"Accept": "application/json", "Content-Type": "application/json"}');
      debugPrint('Payload:');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(requestData));
      } catch (_) {
        debugPrint('$requestData');
      }
      debugPrint('================================================================');

      final Response response;
      if (request.mouDocumentPath != null &&
          request.mouDocumentPath!.isNotEmpty) {
        final formData = FormData.fromMap(requestData);
        try {
          final multipartFile = await MultipartFile.fromFile(
            request.mouDocumentPath!,
            filename: request.mouDocumentName ??
                request.mouDocumentPath!.split(RegExp(r'[/\\]')).last,
          );
          formData.files.add(MapEntry('mou_document', multipartFile));
          formData.files.add(MapEntry('mou_file', multipartFile));
        } catch (_) {}
        response = await dio.post(
          ApiEndpoints.register,
          data: formData,
        );
      } else {
        response = await dio.post(
          ApiEndpoints.register,
          data: requestData,
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
        );
      }

      debugPrint('================================================================');
      debugPrint('✅ [REGISTRATION API RESPONSE]');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data:');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      } catch (_) {
        debugPrint('${response.data}');
      }
      debugPrint('================================================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final signupResponse = SignupResponseModel.fromJson(resData);

        final phone = signupResponse.phoneNumber ?? request.phone;
        final firstName = request.firstName.trim();
        final lastName = request.lastName.trim();
        final fullName = '$firstName $lastName'.trim();
        final primaryName = firstName.isNotEmpty ? firstName : (signupResponse.username ?? fullName);
        final token = signupResponse.token ??
            resData['token']?.toString() ??
            resData['access_token']?.toString() ??
            resData['access']?.toString() ??
            resData['key']?.toString() ??
            resData['auth_token']?.toString() ??
            '';
        final userId = signupResponse.userId?.toString() ??
            resData['user_id']?.toString() ??
            resData['id']?.toString() ??
            '';

        if (token.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyToken, token);
          await SpHelper.saveString('token', token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(sp_keys.keyToken, token);
          await prefs.setString('token', token);
          await _webAPIService.initTokenToHeader();
          debugPrint('💾 [SIGNUP] Saved authentication token to SharedPreferences & SpHelper: $token');
        }
        await SpHelper.saveString(sp_keys.keyUseMobile, phone);
        await SpHelper.saveString(sp_keys.keyUserName, primaryName);
        await SpHelper.saveString('first_name', firstName);
        await SpHelper.saveString('last_name', lastName);
        await SpHelper.saveString('username', primaryName);
        await SpHelper.saveString('user_name', primaryName);
        await SpHelper.saveString('home_username', primaryName);
        if (userId.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyUserId, userId);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone_number', phone);
        await prefs.setString('username', primaryName);
        await prefs.setString('first_name', firstName);
        await prefs.setString('last_name', lastName);
        await prefs.setString('user_name', primaryName);
        if (userId.isNotEmpty) {
          await prefs.setString('user_id', userId);
        }
        await prefs.setString('account_type', request.accountType);

        return signupResponse;
      } else {
        return SignupResponseModel.fromError(
          'Registration failed with status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('================================================================');
      debugPrint('❌ [REGISTRATION API ERROR]');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('================================================================');

      String errorMessage = 'Registration failed. Please try again.';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          final data = e.response!.data as Map;
          if (data.containsKey('message')) {
            errorMessage = data['message'].toString();
          } else if (data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          } else if (data.isNotEmpty) {
            final firstKey = data.keys.first;
            final val = data[firstKey];
            if (val is List && val.isNotEmpty) {
              errorMessage = '$firstKey: ${val.first}';
            } else {
              errorMessage = '$firstKey: $val';
            }
          }
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        }
      }
      return SignupResponseModel.fromError(errorMessage);
    } catch (e) {
      debugPrint('================================================================');
      debugPrint('❌ [REGISTRATION UNEXPECTED ERROR]: $e');
      debugPrint('================================================================');
      return SignupResponseModel.fromError(e.toString());
    }
  }

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
    final prefToken = prefs.getString(sp_keys.keyToken) ?? prefs.getString('token');
    if (prefToken != null && prefToken.trim().isNotEmpty) {
      return prefToken.trim();
    }
    return null;
  }

  Future<bool> checkAuthStatus() async {
    final token = await getSavedToken();
    if (token == null || token.trim().isEmpty) {
      return false;
    }
    await _webAPIService.initTokenToHeader();
    return true;
  }

  Future<String?> getSavedMobile() async {
    return await SpHelper.getString(sp_keys.keyUseMobile);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sp_keys.keyToken);
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('phone_number');
    await prefs.remove('account_type');
    await SpHelper.clearAll();
  }
}
