import 'package:flutter/material.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/providers/view_model.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/viewmodels/profile_viewmodel.dart';
import 'package:floret_app/repositories/profile_repository.dart' as api_repo;
import '../repos/profile_repository.dart';

class MyAccountViewModel extends ViewModel {
  final ProfileRepository _repository;
  final api_repo.ProfileRepository _apiProfileRepository;

  bool _isEditing = false;
  String _fullName = '';
  String _firstName = '';
  String _phoneNumber = '';

  final int _totalPickups = 0;
  final double _wasteCollected = 0.0;
  final int _treesEquiv = 0;

  String _defaultAddress = 'No saved address. Tap Manage to add.';
  String _city = '—';
  String _pincode = '—';

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  MyAccountViewModel({
    ProfileRepository? repository,
    api_repo.ProfileRepository? apiProfileRepository,
  })  : _repository = repository ?? ProfileRepository(),
        _apiProfileRepository =
            apiProfileRepository ?? api_repo.ProfileRepository() {
    nameController = TextEditingController(text: _fullName);
    phoneController = TextEditingController(text: _phoneNumber);
    _loadFromCache();
    loadProfile();
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedFirst = await SpHelper.getString('first_name');
      final cachedFull = await SpHelper.getString(sp_keys.keyUserName);
      final cachedPhone = await SpHelper.getString(sp_keys.keyUseMobile) ??
          await SpHelper.getString('phone_number');
      if (cachedFirst != null &&
          cachedFirst.trim().isNotEmpty &&
          cachedFirst.trim().toLowerCase() != 'user' &&
          cachedFirst.trim().toLowerCase() != 'null') {
        _firstName = cachedFirst.trim();
      }
      if (cachedFull != null &&
          cachedFull.trim().isNotEmpty &&
          cachedFull.trim().toLowerCase() != 'user' &&
          cachedFull.trim().toLowerCase() != 'null') {
        _fullName = cachedFull.trim();
      }
      if (cachedPhone != null && cachedPhone.trim().isNotEmpty) {
        _phoneNumber = cachedPhone.trim();
      }
      if (!_isEditing) {
        nameController.text = _fullName.isNotEmpty ? _fullName : _firstName;
        phoneController.text = _phoneNumber;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadProfile() async {
    showLoading();
    try {
      final profile = await _apiProfileRepository.getProfile();
      final fName = profile.displayFirstName;
      if (fName.isNotEmpty) {
        _firstName = fName;
      }
      if (profile.fullName.trim().isNotEmpty &&
          profile.fullName.trim().toLowerCase() != 'user') {
        _fullName = profile.fullName;
      }
      if (profile.phoneNumber != null &&
          profile.phoneNumber!.trim().isNotEmpty) {
        _phoneNumber = profile.phoneNumber!;
      }
      if (!_isEditing) {
        nameController.text = _fullName.isNotEmpty ? _fullName : _firstName;
        phoneController.text = _phoneNumber;
      }
      if (profile.street != null && profile.street!.isNotEmpty) {
        _defaultAddress = profile.formattedAddress;
      }
      if (profile.city != null && profile.city!.isNotEmpty) {
        _city = profile.city!;
      }
      if (profile.zipCode != null && profile.zipCode!.isNotEmpty) {
        _pincode = profile.zipCode!;
      }
      notifyListeners();
    } catch (_) {
      try {
        final local = await _repository.getUserProfile();
        if (local.name.trim().isNotEmpty) {
          _fullName = local.name;
        }
        if (local.mobileNumber.trim().isNotEmpty) {
          _phoneNumber = local.mobileNumber;
        }
        if (!_isEditing) {
          nameController.text = _fullName;
          phoneController.text = _phoneNumber;
        }
        notifyListeners();
      } catch (_) {}
    } finally {
      hideLoading();
    }
  }

  bool get isEditing => _isEditing;
  String get fullName => _fullName.isNotEmpty ? _fullName : _firstName;
  String get firstName => _firstName.isNotEmpty
      ? _firstName
      : (_fullName
          .split(' ')
          .firstWhere((s) => s.isNotEmpty, orElse: () => 'User'));
  String get phoneNumber => _phoneNumber;
  int get totalPickups => _totalPickups;
  double get wasteCollected => _wasteCollected;
  int get treesEquiv => _treesEquiv;
  String get defaultAddress => _defaultAddress;
  String get city => _city;
  String get pincode => _pincode;

  String get avatarInitial {
    final name = _firstName.isNotEmpty ? _firstName : _fullName.trim();
    if (name.isEmpty || name.toLowerCase() == 'user') return 'User';
    return name[0].toUpperCase();
  }

  void toggleEdit() {
    if (_isEditing) {
      // Save changes
      if (nameController.text.trim().isNotEmpty) {
        _fullName = nameController.text.trim();
        final parts = _fullName.split(' ').where((s) => s.isNotEmpty).toList();
        _firstName = parts.isNotEmpty ? parts.first : _fullName;
        SpHelper.saveString('first_name', _firstName);
        SpHelper.saveString(sp_keys.keyUserName, _fullName);
      }
      if (phoneController.text.trim().isNotEmpty) {
        _phoneNumber = phoneController.text.trim();
        SpHelper.saveString(sp_keys.keyUseMobile, _phoneNumber);
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

  void clearProfile() {
    _fullName = '';
    _firstName = '';
    _phoneNumber = '';
    _defaultAddress = 'No saved address. Tap Manage to add.';
    _city = '—';
    _pincode = '—';
    nameController.text = '';
    phoneController.text = '';
    notifyListeners();
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
      try {
        await Provider.of<ProfileViewModel>(context, listen: false).logout();
      } catch (_) {}
      try {
        clearProfile();
        await SpHelper.clearAll();
      } catch (_) {}
      if (!context.mounted) return;
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
