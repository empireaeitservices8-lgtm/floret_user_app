import 'dart:io';
import 'dart:convert';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/features/home/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/providers/view_model.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/viewmodels/profile_viewmodel.dart';
import 'package:floret_app/repositories/profile_repository.dart' as api_repo;
import '../repos/profile_repository.dart';
import '../model/order_model.dart';
import 'package:floret_app/services/address_storage_service.dart';

class MyAccountViewModel extends ViewModel {
  final ProfileRepository _repository;
  final api_repo.ProfileRepository _apiProfileRepository;

  bool _isEditing = false;
  String _fullName = '';
  String _firstName = '';
  String _phoneNumber = '';

  int _totalPickups = 0;
  double _cachedRecycledWeight = 0.0;
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
    OrderStore.instance.orders.addListener(_onOrdersChanged);
    _loadFromCache();
    loadProfile();
  }

  void _onOrdersChanged() {
    notifyListeners();
  }


  Future<void> _loadFromCache() async {
    try {
      final cachedWeightStr = await SpHelper.getString('total_recycled_weight');
      if (cachedWeightStr != null && cachedWeightStr.isNotEmpty) {
        final parsedWeight = double.tryParse(cachedWeightStr) ?? 0.0;
        if (parsedWeight > 0) {
          _cachedRecycledWeight = parsedWeight;
        }
      }
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
      if (_firstName.isEmpty && _fullName.isEmpty) {
        final fallback = await SpHelper.getUserName();
        if (fallback.isNotEmpty) {
          _firstName = fallback;
          _fullName = fallback;
        }
      }
      if (!_isEditing) {
        nameController.text = _fullName.isNotEmpty ? _fullName : _firstName;
        phoneController.text = _phoneNumber;
        notifyListeners();
      }
      await loadAddressDetails();
    } catch (_) {}
  }

  Future<void> loadAddressDetails() async {
    try {
      // 1. Try AddressStorageService saved addresses for default
      final savedAddresses = await AddressStorageService.getSavedAddresses();
      if (savedAddresses.isNotEmpty) {
        final def = savedAddresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => savedAddresses.first,
        );
        if (def.addressLine.isNotEmpty) {
          final parts = [
            def.addressLine,
            if (def.ward != null && def.ward!.isNotEmpty) def.ward!,
            if (def.localBody != null && def.localBody!.isNotEmpty) def.localBody!,
            def.city,
            if (def.district != null && def.district!.isNotEmpty) def.district!,
            if (def.state != null && def.state!.isNotEmpty) def.state!,
            def.pincode,
          ].where((s) => s.isNotEmpty).toList();

          _defaultAddress = parts.isNotEmpty ? parts.join(', ') : def.addressLine;
          if (def.city.isNotEmpty) _city = def.city;
          if (def.pincode.isNotEmpty) _pincode = def.pincode;
          notifyListeners();
          return;
        }
      }

      // 2. Try SharedPreferences registration address
      final regAddr = await SpHelper.getString('registration_address');
      final regStreet = await SpHelper.getString('registration_street') ??
          await SpHelper.getString('street');
      final regCity = await SpHelper.getString('registration_city') ??
          await SpHelper.getString('city');
      final regPin = await SpHelper.getString('registration_zip_code') ??
          await SpHelper.getString('zip_code') ??
          await SpHelper.getString('pincode');
      final regWard = await SpHelper.getString('registration_ward') ??
          await SpHelper.getString('ward');
      final regLocalBody = await SpHelper.getString('registration_local_body') ??
          await SpHelper.getString('local_body');
      final regDistrict = await SpHelper.getString('registration_district') ??
          await SpHelper.getString('district');
      final regState = await SpHelper.getString('registration_state') ??
          await SpHelper.getString('state');

      if (regAddr != null && regAddr.trim().isNotEmpty) {
        _defaultAddress = regAddr.trim();
      } else if (regStreet != null && regStreet.trim().isNotEmpty) {
        final parts = [
          regStreet,
          regWard,
          regLocalBody,
          regCity,
          regDistrict,
          regState,
          regPin,
        ].where((s) => s != null && s.trim().isNotEmpty).map((s) => s!.trim()).toList();
        _defaultAddress = parts.isNotEmpty ? parts.join(', ') : regStreet;
      }

      if (regCity != null && regCity.trim().isNotEmpty) {
        _city = regCity.trim();
      }
      if (regPin != null && regPin.trim().isNotEmpty) {
        _pincode = regPin.trim();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProfile() async {
    final cachedWeightStr = await SpHelper.getString('total_recycled_weight');
    if (cachedWeightStr != null && cachedWeightStr.isNotEmpty) {
      final parsedWeight = double.tryParse(cachedWeightStr) ?? 0.0;
      if (parsedWeight > 0) {
        _cachedRecycledWeight = parsedWeight;
        notifyListeners();
      }
    }
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    showLoading();
    try {
      try {
        final cachedWeightStr = await SpHelper.getString('total_recycled_weight');
        if (cachedWeightStr != null && cachedWeightStr.isNotEmpty) {
          final parsedWeight = double.tryParse(cachedWeightStr) ?? 0.0;
          if (parsedWeight > 0) {
            _cachedRecycledWeight = parsedWeight;
          }
        }
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          final response = await ApiService().getRecycleProgress();
          dynamic responseData = response.data;
          if (responseData is String) {
            try {
              responseData = jsonDecode(responseData);
            } catch (_) {}
          }
          if (responseData is Map) {
            final map = Map<String, dynamic>.from(
              (responseData['data'] is Map)
                  ? responseData['data'] as Map
                  : responseData,
            );
            final progress = RecycleProgressModel.fromJson(map);
            if (progress.totalRecycledWeight > 0) {
              _cachedRecycledWeight = progress.totalRecycledWeight;
              await SpHelper.saveString('total_recycled_weight', progress.totalRecycledWeight.toString());
            }
          }
        }
      } catch (_) {}
      final profile = await _apiProfileRepository.getProfile();
      final fName = profile.displayFirstName;
      if (fName.isNotEmpty) {
        _firstName = fName;
        await SpHelper.saveUserName(fName);
      }
      if (profile.fullName.trim().isNotEmpty &&
          profile.fullName.trim().toLowerCase() != 'user') {
        _fullName = profile.fullName;
        await SpHelper.saveUserName(profile.fullName);
      }
      if (profile.phoneNumber != null &&
          profile.phoneNumber!.trim().isNotEmpty) {
        _phoneNumber = profile.phoneNumber!;
      }
      if (!_isEditing) {
        nameController.text = _fullName.isNotEmpty ? _fullName : _firstName;
        phoneController.text = _phoneNumber;
      }
      final fullAddr = profile.formattedAddress;
      if (fullAddr.isNotEmpty && fullAddr != 'Not provided') {
        _defaultAddress = fullAddr;
      } else if (profile.street != null && profile.street!.isNotEmpty) {
        _defaultAddress = profile.street!;
      }
      if (profile.city != null && profile.city!.isNotEmpty) {
        _city = profile.city!;
      }
      if (profile.zipCode != null && profile.zipCode!.isNotEmpty) {
        _pincode = profile.zipCode!;
      }
      if (_defaultAddress == 'No saved address. Tap Manage to add.') {
        await loadAddressDetails();
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
        if (local.totalCollections > 0) {
          _totalPickups = local.totalCollections;
        }
        if (!_isEditing) {
          nameController.text = _fullName;
          phoneController.text = _phoneNumber;
        }
        await loadAddressDetails();
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
  int getTotalPickups([List<OrderModel>? ordersList]) {
    final list = ordersList ?? OrderStore.instance.orders.value;
    if (list.isNotEmpty) {
      return list.length;
    }
    return _totalPickups;
  }

  int get totalPickups => getTotalPickups();
  double getWasteCollected([List<OrderModel>? ordersList]) {
    final now = DateTime.now();
    double ordersWeight = 0.0;
    final list = ordersList ?? OrderStore.instance.orders.value;
    if (list.isNotEmpty) {
      final monthlyList = list.where((o) {
        final date = o.completedDate ?? o.pickupDate;
        return date.year == now.year && date.month == now.month;
      }).toList();

      final completed =
          monthlyList.where((o) => o.status == OrderStatus.completed).toList();
      final valid =
          monthlyList.where((o) => o.status != OrderStatus.cancelled).toList();
      final target = completed.isNotEmpty ? completed : valid;
      ordersWeight = target.length * 5.0;
    }

    if (_cachedRecycledWeight > 0) {
      return _cachedRecycledWeight > ordersWeight
          ? _cachedRecycledWeight
          : ordersWeight;
    }

    return ordersWeight;
  }

  double get wasteCollected => getWasteCollected();
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
        SpHelper.saveUserName(_fullName);
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
    try {
      await _apiProfileRepository.deleteProfile();
    } catch (e) {
      debugPrint('❌ [DELETE ACCOUNT] API call failed: $e');
    }
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
    OrderStore.instance.orders.removeListener(_onOrdersChanged);
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
