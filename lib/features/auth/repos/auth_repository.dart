import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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
      debugPrint('🚀 [API REQUEST] Verifying OTP: $otp for mobile: $mobileNumber');
      await Future.delayed(const Duration(milliseconds: 600));
      final user = UserModel(
        phone: mobileNumber,
        name: 'nicy nicy',
        token: 'auth_token_$mobileNumber',
      );

      await SpHelper.saveString(sp_keys.keyToken, user.token!);
      await SpHelper.saveString(sp_keys.keyUserName, user.name);
      await SpHelper.saveString(sp_keys.keyUseMobile, user.phone);
      await _webAPIService.initTokenToHeader();

      debugPrint('✅ [API RESPONSE] OTP verified successfully for: $mobileNumber');
      return AuthResponseModel(
        success: true,
        message: 'OTP verified successfully',
        user: user,
        token: user.token,
      );
    } catch (e) {
      debugPrint('❌ [API ERROR] Verify OTP error: $e');
      return AuthResponseModel(
        success: false,
        message: e.toString(),
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
        final name = signupResponse.username ??
            '${request.firstName} ${request.lastName}'.trim();
        await SpHelper.saveString(sp_keys.keyUseMobile, phone);
        await SpHelper.saveString(sp_keys.keyUserName, name);

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

  Future<String?> getSavedMobile() async {
    return await SpHelper.getString(sp_keys.keyUseMobile);
  }

  Future<void> logout() async {
    await SpHelper.clearAll();
  }
}
