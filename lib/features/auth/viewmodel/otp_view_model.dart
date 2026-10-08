import 'dart:async';
import 'package:flutter/material.dart';
import 'package:floret_app/providers/view_model.dart';
import '../repos/auth_repository.dart';

class OtpViewModel extends ViewModel {
  final AuthRepository _repository;

  OtpViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  int _resendCountdown = 30;
  Timer? _timer;
  bool _isOtpFocused = false;

  int get resendCountdown => _resendCountdown;
  bool get isOtpFocused => _isOtpFocused;
  bool get canResend => _resendCountdown == 0;

  void init() {
    startTimer();
    otpFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    _isOtpFocused = otpFocusNode.hasFocus;
    notifyListeners();
  }

  void startTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  Future<bool> verifyOtp({
    required String mobileNumber,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    final otp = otpController.text.trim();
    if (otp.length != 4) {
      onError('Please enter a valid 4-digit OTP');
      return false;
    }

    try {
      showLoading();
      final res = await _repository.verifyOtp(mobileNumber, otp);
      if (res.success) {
        onSuccess();
        return true;
      } else {
        onError(res.message);
        return false;
      }
    } catch (e) {
      onError('Verification failed. Please try again.');
      return false;
    } finally {
      hideLoading();
    }
  }

  Future<void> resendOtp({
    required String mobileNumber,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!canResend) return;

    try {
      showLoading();
      final res = await _repository.sendOtp(mobileNumber);
      if (res.success) {
        startTimer();
        onSuccess();
      } else {
        onError(res.message);
      }
    } catch (e) {
      onError('Failed to resend OTP.');
    } finally {
      hideLoading();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpFocusNode.removeListener(_onFocusChange);
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }
}
