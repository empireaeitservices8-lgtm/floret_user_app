import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/services/api_endpoints.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/services/api_service.dart';
import '../../profile/model/order_model.dart';
import '../model/auth_model.dart';
import 'package:floret_app/services/api_client.dart';

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
      await SpHelper.saveUserName(username);
      await SpHelper.saveString(sp_keys.keyUseMobile, formattedPhone);
      if (userId.isNotEmpty) {
        await SpHelper.saveString(sp_keys.keyUserId, userId);
        await OrderStore.instance.loadForUser(userId);
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
      final requestData = request.toJson();
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
        response = await _apiService.dio.post(
          ApiEndpoints.register,
          data: formData,
        );
      } else {
        response = await _apiService.register(
          requestData,
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final signupResponse = SignupResponseModel.fromJson(resData);
        final phone = (signupResponse.phoneNumber != null && signupResponse.phoneNumber!.isNotEmpty)
            ? signupResponse.phoneNumber!
            : (request.phone.startsWith('+')
                ? request.phone
                : (request.phone.startsWith('91') && request.phone.length == 12
                    ? '+${request.phone}'
                    : '+91${request.phone}'));
        final firstName = request.firstName.trim();
        final lastName = request.lastName.trim();
        final fullName = '$firstName $lastName'.trim();
        final primaryName = firstName.isNotEmpty ? firstName : (signupResponse.username ?? fullName);

        debugPrint('[RegisterProvider] Registration successful. Generated OTP: ');

        // Sequence of APIs after successful registration:
        // 1. POST /api/otp/send/
        // 2. POST /api/login/ with phone & returned otp
        // 3. GET /api/profile/ with obtained token
        String retrievedToken = signupResponse.token ?? '';
        String retrievedUserId = signupResponse.userId?.toString() ?? resData['user_id']?.toString() ?? '';
        String retrievedUsername = signupResponse.username ?? primaryName;
        String retrievedAccountType = signupResponse.accountType ?? request.accountType;
        String retrievedMouStatus = '';
        bool canAccessApp = true;

        try {
          final otpResponse = await _apiService.sendOtp(phone);
          final otpData = otpResponse.data is Map ? otpResponse.data as Map : {};
          final generatedOtp = otpData['otp']?.toString() ?? '';

          if (generatedOtp.isNotEmpty) {
            final loginResponse = await _apiService.login(
              phoneNumber: phone,
              otp: generatedOtp,
            );
            final loginData = loginResponse.data is Map ? loginResponse.data as Map : {};
            if (loginData['token'] != null && loginData['token'].toString().trim().isNotEmpty) {
              retrievedToken = loginData['token'].toString().trim();
            }
            if (loginData['user_id'] != null) {
              retrievedUserId = loginData['user_id'].toString();
            }
            if (loginData['username'] != null && loginData['username'].toString().trim().isNotEmpty) {
              retrievedUsername = loginData['username'].toString().trim();
            }
            if (loginData['account_type'] != null && loginData['account_type'].toString().trim().isNotEmpty) {
              retrievedAccountType = loginData['account_type'].toString().trim();
            }
            if (loginData['mou_status'] != null) {
              retrievedMouStatus = loginData['mou_status'].toString().trim();
            }
            if (loginData['can_access_app'] != null) {
              canAccessApp = loginData['can_access_app'] == true;
            }

            if (retrievedToken.isNotEmpty) {
              await SpHelper.saveString(sp_keys.keyToken, retrievedToken);
              await SpHelper.saveString('token', retrievedToken);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(sp_keys.keyToken, retrievedToken);
              await prefs.setString('token', retrievedToken);
              await _webAPIService.initTokenToHeader();

              try {
                await _apiService.getProfile(token: retrievedToken);
              } catch (profileErr) {
                debugPrint('⚠️ [SIGNUP] Profile fetch error (non-fatal): $profileErr');
              }
            }
          }
        } catch (chainErr) {
          debugPrint('⚠️ [SIGNUP] Post-registration OTP/Login sequence error: $chainErr');
        }

        // Save session credentials
        if (retrievedToken.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyToken, retrievedToken);
          await SpHelper.saveString('token', retrievedToken);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(sp_keys.keyToken, retrievedToken);
          await prefs.setString('token', retrievedToken);
          await _webAPIService.initTokenToHeader();
          debugPrint('💾 [SIGNUP] Saved authentication token to SharedPreferences & SpHelper: $retrievedToken');
        }
        await SpHelper.saveString(sp_keys.keyUseMobile, phone);
        await SpHelper.saveString(sp_keys.keyUserName, retrievedUsername);
        await SpHelper.saveString('first_name', firstName);
        await SpHelper.saveString('last_name', lastName);
        await SpHelper.saveString('username', retrievedUsername);
        await SpHelper.saveString('user_name', retrievedUsername);
        await SpHelper.saveString('home_username', retrievedUsername);
        if (retrievedUserId.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyUserId, retrievedUserId);
          await OrderStore.instance.loadForUser(retrievedUserId);
        }
        if (retrievedAccountType.isNotEmpty) {
          await SpHelper.saveString('account_type', retrievedAccountType);
        }
        if (retrievedMouStatus.isNotEmpty) {
          await SpHelper.saveString('mou_status', retrievedMouStatus);
        }
        await SpHelper.saveBoolean('can_access_app', canAccessApp);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone_number', phone);
        await prefs.setString('username', retrievedUsername);
        await prefs.setString('first_name', firstName);
        await prefs.setString('last_name', lastName);
        await prefs.setString('user_name', retrievedUsername);
        if (retrievedUserId.isNotEmpty) {
          await prefs.setString('user_id', retrievedUserId);
        }
        await prefs.setString('account_type', retrievedAccountType);

        return signupResponse.copyWith(
          token: retrievedToken.isNotEmpty ? retrievedToken : signupResponse.token,
          userId: int.tryParse(retrievedUserId) ?? signupResponse.userId,
          username: retrievedUsername,
          phoneNumber: phone,
          accountType: retrievedAccountType,
        );
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
    await SpHelper.clearUserData();
    OrderStore.instance.resetForLogout();
  }

  /// Fetches wards for a selected local body.
  /// For Varkala Municipality, calls /api/wards/?local_body&local_body_id=2&local_body_id=3
  Future<List<String>> fetchWards(String localBody) async {
    final lb = localBody.toLowerCase().trim();
    int? localBodyId;
    if (lb.contains('nedumangad')) {
      localBodyId = 2;
    } else if (lb.contains('varkala')) {
      localBodyId = 3;
    }

    try {
      String endpoint = '${ApiEndpoints.wards}?local_body';
      if (lb.contains('varkala')) {
        endpoint = '${ApiEndpoints.wards}?local_body&local_body_id=2&local_body_id=3';
      } else if (localBodyId != null) {
        endpoint = '${ApiEndpoints.wards}?local_body&local_body_id=$localBodyId';
      }

      debugPrint('🚀 [AUTH REPOSITORY] Fetching wards for $localBody from: $endpoint');
      final response = await ApiClient()
          .get(endpoint)
          .timeout(const Duration(seconds: 10));

      if (response.data is List) {
        final List<String> list = [];
        for (final item in response.data) {
          if (item is Map) {
            final wardNum = item['ward_number'];
            final wardName = item['ward_name'];
            if (wardNum != null && wardName != null) {
              list.add('$wardNum - $wardName');
            } else if (wardName != null) {
              list.add(wardName.toString());
            }
          }
        }
        if (list.isNotEmpty) {
          debugPrint('✅ [AUTH REPOSITORY] Fetched ${list.length} wards for $localBody');
          return list;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [AUTH REPOSITORY] Error fetching wards: $e');
    }

    return [];
  }
}
