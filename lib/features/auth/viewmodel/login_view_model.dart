import 'dart:async';

import 'package:flutter/material.dart';
import 'package:floret_app/providers/view_model.dart';
import '../repos/auth_repository.dart';

class LoginViewModel extends ViewModel {

  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      :  _authRepository = authRepository ?? AuthRepository();

  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final TextEditingController otpController = TextEditingController();
  int _currentStep = 1;
  int get currentStep => _currentStep;

  String _mobileNumber = '';
  bool _isValidMobile = false;
  bool _isOtpSent = false;
  bool get isOtpSent => _isOtpSent;

  String get mobileNumber => _mobileNumber;
  bool get isValidMobile => _isValidMobile;
  int _resendCountdown = 30;
  int get resendCountdown => _resendCountdown;
  Timer? _countdownTimer;

  void onMobileChanged(String value) {
    _mobileNumber = value.trim();
    final bool valid = _mobileNumber.length == 10 &&
        RegExp(r'^[0-9]+$').hasMatch(_mobileNumber);
    if (_isValidMobile != valid) {
      _isValidMobile = valid;
      notifyListeners();
    }
  }

  void startResendTimer() {
    _resendCountdown = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<bool> sendOtp({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!_isValidMobile) {
      onError('Please enter a valid 10-digit mobile number');
      return false;
    }

    try {
      showLoading();
      final res = await _authRepository.sendOtp(_mobileNumber);
      if (res.success) {
        onSuccess();
        return true;
      } else {
        onError(res.message);
        return false;
      }
    } catch (e) {
      onError('Failed to send OTP. Please try again.');
      return false;
    } finally {
      hideLoading();
    }
  }

  String? _step1ErrorMessage;
  String? get step1ErrorMessage => _step1ErrorMessage;

  void clearStep1Error() {
    if (_step1ErrorMessage != null) {
      _step1ErrorMessage = null;
      notifyListeners();
    }
  }

  void resetOtpState() {
    _isOtpSent = false;
    otpController.clear();
    _step1ErrorMessage = null;
    _countdownTimer?.cancel();
    _resendCountdown = 30;
    notifyListeners();
  }

  Future<void> resendOtp({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    otpController.clear();
    _step1ErrorMessage = null;
    startResendTimer();
    try {
      final res = await _authRepository.sendOtp(_mobileNumber);
      if (res.success) {
        onSuccess();
      } else {
        onError(res.message);
      }
    } catch (e) {
      onError('Failed to resend OTP. Please try again.');
    }
  }

  Future<bool> verifyOtp({
    required String otp,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (otp.trim().length < 4) {
      _step1ErrorMessage = 'Please enter a valid 4-digit OTP';
      notifyListeners();
      onError('Please enter a valid 4-digit OTP');
      return false;
    }

    try {
      showLoading();
      await Future.delayed(const Duration(milliseconds: 500));
      _step1ErrorMessage = null;
      _currentStep = 2;
      notifyListeners();
      onSuccess();
      return true;
    } catch (e) {
      _step1ErrorMessage = 'OTP verification failed';
      notifyListeners();
      onError('OTP verification failed');
      return false;
    } finally {
      hideLoading();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}
