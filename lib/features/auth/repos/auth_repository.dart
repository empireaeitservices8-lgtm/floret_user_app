import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import '../model/auth_model.dart';

class AuthRepository {
  final WebAPIService _webAPIService;

  AuthRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<AuthResponseModel> sendOtp(String mobileNumber) async {
    try {
      // Simulate network API request
      await Future.delayed(const Duration(milliseconds: 600));
      return const AuthResponseModel(
        success: true,
        message: 'OTP sent successfully',
      );
    } catch (e) {
      return AuthResponseModel(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponseModel> verifyOtp(String mobileNumber, String otp) async {
    try {
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

      return AuthResponseModel(
        success: true,
        message: 'OTP verified successfully',
        user: user,
        token: user.token,
      );
    } catch (e) {
      return AuthResponseModel(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<String?> getSavedMobile() async {
    return await SpHelper.getString(sp_keys.keyUseMobile);
  }

  Future<void> logout() async {
    await SpHelper.clearAll();
  }
}
