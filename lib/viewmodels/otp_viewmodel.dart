import 'package:flutter/foundation.dart';
import '../models/send_otp_model.dart';
import '../models/verify_otp_model.dart';
import '../repositories/auth_repository.dart';

class OtpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  OtpViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _otp;

  // Verify OTP state
  bool _isVerifyingOtp = false;
  String? _verifyErrorMessage;
  VerifyOtpModel? _verifyOtpResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get otp => _otp;

  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get verifyErrorMessage => _verifyErrorMessage;
  VerifyOtpModel? get verifyOtpResponse => _verifyOtpResponse;

  /// Helper to format phone number to international E.164 standard (e.g., +919995723146)
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('91') && cleaned.length == 12) {
        cleaned = '+$cleaned';
      } else {
        cleaned = '+91$cleaned';
      }
    }
    return cleaned;
  }

  /// Sends OTP to the provided phone number
  Future<bool> sendOtp(String phoneNumber) async {
    final String cleanPhone = phoneNumber.trim();

    // Validation: Check if empty
    if (cleanPhone.isEmpty) {
      _errorMessage = 'Please enter your phone number.';
      notifyListeners();
      return false;
    }

    final String formattedPhone = formatPhoneNumber(cleanPhone);

    // Validation: Check phone length and format (+ followed by 10 to 15 digits)
    final RegExp phoneRegex = RegExp(r'^\+[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(formattedPhone)) {
      _errorMessage = 'Please enter a valid phone number with country code.';
      notifyListeners();
      return false;
    }

    // Step 1: Clear previous error and success messages
    _errorMessage = null;
    _successMessage = null;

    // Step 2: Set loading to true and notify listeners
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📱 [OTP VIEWMODEL] Requesting OTP for: $formattedPhone');

      // Step 3: Call the repository
      final SendOtpModel response =
          await _authRepository.sendOtp(formattedPhone);

      // Step 4: Store response data
      _successMessage = response.message ?? 'OTP sent successfully.';
      _otp = response.otp; // Kept in memory for development/testing only

      debugPrint('🎉 [OTP VIEWMODEL] OTP sent successfully');
      // Step 6: Return true on success
      return true;
    } catch (e) {
      // Handle error cleanly without exposing raw technical exceptions
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ [OTP VIEWMODEL] Error sending OTP: $_errorMessage');
      // Return false on failure
      return false;
    } finally {
      // Step 5: Ensure isLoading is false even when an exception occurs
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies OTP for the given phone number
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final String cleanPhone = phoneNumber.trim();
    final String cleanOtp = otp.trim();

    // Validation: OTP not empty
    if (cleanOtp.isEmpty) {
      _verifyErrorMessage = 'Please enter the OTP.';
      notifyListeners();
      return false;
    }

    // Validation: OTP format/length
    if (cleanOtp.length < 4) {
      _verifyErrorMessage = 'Please enter a valid 4-digit OTP.';
      notifyListeners();
      return false;
    }

    // Validation: Phone not empty
    if (cleanPhone.isEmpty) {
      _verifyErrorMessage = 'Phone number is missing. Please request a new OTP.';
      notifyListeners();
      return false;
    }

    final String formattedPhone = formatPhoneNumber(cleanPhone);

    // Step 1: Clear previous error
    _verifyErrorMessage = null;

    // Step 2: Set loading to true and notify listeners
    _isVerifyingOtp = true;
    notifyListeners();

    try {
      debugPrint('📱 [OTP VIEWMODEL] Verifying OTP for: $formattedPhone');

      // Step 3: Call repository
      final response = await _authRepository.verifyOtp(
        formattedPhone,
        cleanOtp,
      );

      // Step 4: Store response
      _verifyOtpResponse = response;

      debugPrint('🎉 [OTP VIEWMODEL] OTP verification successful! is_registered = ${response.isRegistered}');
      // Step 6: Return true on success
      return true;
    } catch (e) {
      _verifyErrorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ [OTP VIEWMODEL] OTP verification error: $_verifyErrorMessage');
      // Step 6: Return false on failure
      return false;
    } finally {
      // Step 5: Always set loading to false and notify listeners
      _isVerifyingOtp = false;
      notifyListeners();
    }
  }

  /// Clears current messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _verifyErrorMessage = null;
    notifyListeners();
  }
}
