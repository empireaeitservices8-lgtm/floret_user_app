import 'package:flutter/material.dart';
import 'package:floret_app/providers/view_model.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';
import '../repos/profile_repository.dart';

class MyAccountViewModel extends ViewModel {
  final ProfileRepository _repository;

  bool _isEditing = false;
  String _fullName = 'nicy nicy';
  String _phoneNumber = '+919995723146';

  final int _totalPickups = 0;
  final double _wasteCollected = 0.0;
  final int _treesEquiv = 0;

  final String _defaultAddress = 'No saved address. Tap Manage to add.';
  final String _city = '—';
  final String _pincode = '—';

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  MyAccountViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository() {
    nameController = TextEditingController(text: _fullName);
    phoneController = TextEditingController(text: _phoneNumber);
  }

  bool get isEditing => _isEditing;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  int get totalPickups => _totalPickups;
  double get wasteCollected => _wasteCollected;
  int get treesEquiv => _treesEquiv;
  String get defaultAddress => _defaultAddress;
  String get city => _city;
  String get pincode => _pincode;

  String get avatarInitial {
    if (_fullName.trim().isEmpty) return 'N';
    return _fullName.trim()[0].toUpperCase();
  }

  void toggleEdit() {
    if (_isEditing) {
      // Save changes
      if (nameController.text.trim().isNotEmpty) {
        _fullName = nameController.text.trim();
      }
      if (phoneController.text.trim().isNotEmpty) {
        _phoneNumber = phoneController.text.trim();
      }
      _repository.updateProfile(
        name: _fullName,
        mobileNumber: _phoneNumber,
        email: 'user@gmail.com',
      );
      _isEditing = false;
      notifyListeners();
    } else {
      nameController.text = _fullName;
      phoneController.text = _phoneNumber;
      _isEditing = true;
      notifyListeners();
    }
  }

  void cancelEdit() {
    nameController.text = _fullName;
    phoneController.text = _phoneNumber;
    _isEditing = false;
    notifyListeners();
  }

  Future<void> deleteAccount(BuildContext context) async {
    showLoading();
    await Future.delayed(const Duration(milliseconds: 600));
    hideLoading();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully.'),
          backgroundColor: Color(0xFFDE202B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
