import 'package:flutter/material.dart';
import 'package:floret_app/providers/view_model.dart';
import '../repos/auth_repository.dart';

class LoginViewModel extends ViewModel {
  final AuthRepository _repository;

  LoginViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  String _mobileNumber = '';
  bool _isValidMobile = false;

  String get mobileNumber => _mobileNumber;
  bool get isValidMobile => _isValidMobile;

  void onMobileChanged(String value) {
    _mobileNumber = value.trim();
    final bool valid =
        _mobileNumber.length == 10 && RegExp(r'^[0-9]+$').hasMatch(_mobileNumber);
    if (_isValidMobile != valid) {
      _isValidMobile = valid;
      notifyListeners();
    }
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
      final res = await _repository.sendOtp(_mobileNumber);
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

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}
