import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/services/api_endpoints.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/services/api_service.dart';
import '../../profile/model/order_model.dart';
import '../../profile/model/address_model.dart';
import '../../../services/address_storage_service.dart';
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
      final message =
          resData['message']?.toString() ?? 'OTP sent successfully.';

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

      debugPrint(
          '🚀 [API REQUEST] Verifying OTP / Logging in with phone: $formattedPhone');
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

      debugPrint(
          '✅ [API RESPONSE] Successfully authenticated with real server token: $token');
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
      final filePath = request.mouDocumentPath;
      final bool hasMouFile = filePath != null && filePath.isNotEmpty;

      if (hasMouFile) {
        final filename = request.mouDocumentName ??
            filePath.split(RegExp(r'[/\\]')).last;

        // mou_document is expected as a String on the backend serializer.
        requestData['mou_document'] = filename;
        requestData.remove('mou_file');

        final formData = FormData.fromMap(requestData);

        // Upload the actual document under 'mou_file'
        try {
          formData.files.add(
            MapEntry(
              'mou_file',
              await MultipartFile.fromFile(
                filePath,
                filename: filename,
              ),
            ),
          );
        } catch (fileErr) {
          debugPrint(
              '⚠️ [AUTH REPOSITORY] Could not read file from path $filePath: $fileErr');
        }

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
        final phone = (signupResponse.phoneNumber != null &&
                signupResponse.phoneNumber!.isNotEmpty)
            ? signupResponse.phoneNumber!
            : (request.phone.startsWith('+')
                ? request.phone
                : (request.phone.startsWith('91') && request.phone.length == 12
                    ? '+${request.phone}'
                    : '+91${request.phone}'));
        final firstName = request.firstName.trim();
        final lastName = request.lastName.trim();
        final fullName = '$firstName $lastName'.trim();
        final primaryName = firstName.isNotEmpty
            ? firstName
            : (signupResponse.username ?? fullName);

        debugPrint(
            '[RegisterProvider] Registration successful.');

        String retrievedToken = signupResponse.token ?? '';
        String retrievedUserId = signupResponse.userId?.toString() ??
            resData['user_id']?.toString() ??
            '';
        if (retrievedUserId.isEmpty && resData['data'] is Map) {
          retrievedUserId = (resData['data'] as Map)['user_id']?.toString() ??
              (resData['data'] as Map)['id']?.toString() ??
              '';
        }
        if (retrievedUserId.isEmpty && resData['user'] is Map) {
          retrievedUserId = (resData['user'] as Map)['user_id']?.toString() ??
              (resData['user'] as Map)['id']?.toString() ??
              '';
        }
        String retrievedUsername = signupResponse.username ?? primaryName;
        String retrievedAccountType =
            signupResponse.accountType ?? request.accountType;
        String retrievedMouStatus = '';
        bool canAccessApp = true;

        // Save session credentials
        if (retrievedToken.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyToken, retrievedToken);
          await SpHelper.saveString('token', retrievedToken);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(sp_keys.keyToken, retrievedToken);
          await prefs.setString('token', retrievedToken);
          await _webAPIService.initTokenToHeader();
          debugPrint(
              '💾 [SIGNUP] Saved authentication token to SharedPreferences & SpHelper: $retrievedToken');
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

        // Save registration address to SpHelper, SharedPreferences and AddressStorageService
        final regStreet = request.streetAddress.trim();
        final regCity = request.city.trim();
        final regState =
            request.state.trim().isNotEmpty ? request.state.trim() : 'Kerala';
        final regDistrict = request.district.trim();
        final regLocalBody = request.localBody.trim();
        final regWard = request.ward.trim();
        final regZip = request.zipCode.trim();

        if (regStreet.isNotEmpty || regCity.isNotEmpty) {
          final regParts = [
            regStreet,
            regWard,
            regLocalBody,
            regCity,
            regDistrict,
            regState,
            regZip,
          ].where((s) => s.isNotEmpty).toList();
          final formattedReg = regParts.join(', ');

          await SpHelper.saveString('registration_address', formattedReg);
          await SpHelper.saveString('registration_street', regStreet);
          await SpHelper.saveString('registration_city', regCity);
          await SpHelper.saveString('registration_state', regState);
          await SpHelper.saveString('registration_district', regDistrict);
          await SpHelper.saveString('registration_local_body', regLocalBody);
          await SpHelper.saveString('registration_ward', regWard);
          await SpHelper.saveString('registration_zip_code', regZip);

          await prefs.setString('registration_address', formattedReg);
          await prefs.setString('registration_street', regStreet);
          await prefs.setString('registration_city', regCity);
          await prefs.setString('registration_state', regState);
          await prefs.setString('registration_district', regDistrict);
          await prefs.setString('registration_local_body', regLocalBody);
          await prefs.setString('registration_ward', regWard);
          await prefs.setString('registration_zip_code', regZip);
          await prefs.setString('street', regStreet);
          await prefs.setString('city', regCity);
          await prefs.setString('pincode', regZip);
          await prefs.setString('zip_code', regZip);

          // Save as default address in AddressStorageService
          final defaultAddrModel = AddressModel(
            id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
            type: 'Home',
            addressLine: regStreet,
            city: regCity,
            district: regDistrict.isNotEmpty ? regDistrict : null,
            state: regState,
            localBody: regLocalBody.isNotEmpty ? regLocalBody : null,
            ward: regWard.isNotEmpty ? regWard : null,
            pincode: regZip,
            isDefault: true,
          );
          await AddressStorageService.addAddress(defaultAddrModel);
        }

        return signupResponse.copyWith(
          token:
              retrievedToken.isNotEmpty ? retrievedToken : signupResponse.token,
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
      debugPrint(
          '================================================================');
      debugPrint('❌ [REGISTRATION API ERROR]');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('Error Message: ${e.message}');
      debugPrint(
          '================================================================');

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
      debugPrint(
          '================================================================');
      debugPrint('❌ [REGISTRATION UNEXPECTED ERROR]: $e');
      debugPrint(
          '================================================================');
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
    final prefToken =
        prefs.getString(sp_keys.keyToken) ?? prefs.getString('token');
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
    final uid = await SpHelper.getString(sp_keys.keyUserId);
    if (uid != null && uid.isNotEmpty) {
      await AddressStorageService.loadForUser(uid);
    }
    return true;
  }

  Future<String?> getSavedMobile() async {
    return await SpHelper.getString(sp_keys.keyUseMobile);
  }

  Future<void> logout() async {
    await SpHelper.clearUserData();
    OrderStore.instance.resetForLogout();
    AddressStorageService.resetForLogout();
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
        endpoint =
            '${ApiEndpoints.wards}?local_body&local_body_id=2&local_body_id=3';
      } else if (localBodyId != null) {
        endpoint =
            '${ApiEndpoints.wards}?local_body&local_body_id=$localBodyId';
      }

      debugPrint(
          '🚀 [AUTH REPOSITORY] Fetching wards for $localBody from: $endpoint');
      final response =
          await ApiClient().get(endpoint).timeout(const Duration(seconds: 10));

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
          debugPrint(
              '✅ [AUTH REPOSITORY] Fetched ${list.length} wards for $localBody');
          return list;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [AUTH REPOSITORY] Error fetching wards: $e');
    }

    return [];
  }
}
