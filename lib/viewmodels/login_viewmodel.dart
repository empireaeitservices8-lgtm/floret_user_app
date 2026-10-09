import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';
import '../repositories/auth_repository.dart';
import '../helpers/sp_helper.dart';
import '../services/web_api_services.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  LoginModel? _loginResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginModel? get loginResponse => _loginResponse;

  /// Performs user login with phone number and OTP
  Future<bool> login(String phoneNumber, String otp) async {
    debugPrint('📱 [LOGIN VIEWMODEL] Initiating login for phone: $phoneNumber');

    // 1. Set loading state and clear any previous error
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. Call repository
      final response = await _authRepository.login(
        phoneNumber: phoneNumber.trim(),
        otp: otp.trim(),
      );

      // 3. Store successful response in state
      _loginResponse = response;

      // 4. Save authentication token and user info to SharedPreferences and SpHelper
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setString('KEY_TOKEN', response.token);
      await prefs.setInt('user_id', response.userId);
      await prefs.setString('username', response.username);
      await prefs.setString('phone_number', response.phoneNumber);
      await prefs.setString('account_type', response.accountType);
      await prefs.setString('mou_status', response.mouStatus);
      await prefs.setBool('can_access_app', response.canAccessApp);
      await SpHelper.saveString('KEY_TOKEN', response.token);
      await SpHelper.saveString('token', response.token);
      await WebAPIService().initTokenToHeader();
      debugPrint('💾 [LOGIN VIEWMODEL] User details & token successfully persisted to SharedPreferences');

      // 5. Complete loading and notify listeners
      _isLoading = false;
      notifyListeners();
      debugPrint('🎉 [LOGIN VIEWMODEL] Login successful! can_access_app = ${response.canAccessApp}');
      return true;
    } catch (e) {
      // 6. Handle errors and store message
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ [LOGIN VIEWMODEL] Login failed with error: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears the current error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
