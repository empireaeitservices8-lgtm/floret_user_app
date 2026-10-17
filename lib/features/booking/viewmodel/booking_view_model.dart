import 'package:floret_app/providers/view_model.dart';
import 'package:flutter/material.dart';
import '../../profile/model/address_model.dart';
import '../../../services/address_storage_service.dart';
import '../model/booking_model.dart';
import '../repos/booking_repository.dart';

class BookingViewModel extends ViewModel {
  final BookingRepository _repository;

  BookingViewModel({BookingRepository? repository})
      : _repository = repository ?? BookingRepository() {
    _categories = _repository.getDefaultCategories();
    fullNameController = TextEditingController();
    contactNumberController = TextEditingController();
    pickupAddressController = TextEditingController();
    cityController = TextEditingController();
    zipCodeController = TextEditingController();
    _loadUserContact();
    loadSavedAddresses();
  }

  Future<void> _loadUserContact() async {
    try {
      final contact = await _repository.getUserContact();
      if (fullNameController.text.isEmpty && contact.fullName.isNotEmpty) {
        fullNameController.text = contact.fullName;
      }
      if (contactNumberController.text.isEmpty &&
          contact.contactNumber.isNotEmpty) {
        contactNumberController.text = contact.contactNumber;
      }
      notifyListeners();
    } catch (_) {}
  }

  late final TextEditingController fullNameController;
  late final TextEditingController contactNumberController;
  late final TextEditingController pickupAddressController;
  late final TextEditingController cityController;
  late final TextEditingController zipCodeController;

  List<WasteCategoryItem> _categories = [];
  List<WasteCategoryItem> get categories => _categories;

  String _pickupOption = 'Residential Pickup';
  String get pickupOption => _pickupOption;

  void setPickupOption(String option) {
    if (_pickupOption != option) {
      _pickupOption = option;
      notifyListeners();
    }
  }

  // Stepper state
  int _currentStep = 0; // 0: Contact, 1: Location, 2: Schedule
  int get currentStep => _currentStep;

  final bool _contactCompleted = true; // Image 3 shows tick mark on Contact
  bool get contactCompleted => _contactCompleted;

  bool _locationCompleted = false; // Becomes true on Image 4
  bool get locationCompleted => _locationCompleted;

  bool _scheduleCompleted = false;
  bool get scheduleCompleted => _scheduleCompleted;

  // Tab: 0 = Saved Addresses, 1 = New Address (Image 4 defaults to New Address)
  int _selectedAddressTab = 1;
  int get selectedAddressTab => _selectedAddressTab;

  List<AddressModel> _savedAddresses = [];
  List<AddressModel> get savedAddresses => _savedAddresses;

  AddressModel? _selectedSavedAddress;
  AddressModel? get selectedSavedAddress => _selectedSavedAddress;

  Future<void> loadSavedAddresses() async {
    _savedAddresses = await AddressStorageService.getSavedAddresses();
    if (_savedAddresses.isNotEmpty) {
      if (_selectedSavedAddress == null ||
          !_savedAddresses.any((a) => a.id == _selectedSavedAddress!.id)) {
        _selectedSavedAddress = _savedAddresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _savedAddresses.first,
        );
      }
      if (_selectedAddressTab == 0 && _selectedSavedAddress != null) {
        _applyAddressToControllers(_selectedSavedAddress!);
      }
    }
    notifyListeners();
  }

  void selectSavedAddress(AddressModel address) {
    _selectedSavedAddress = address;
    _applyAddressToControllers(address);
    notifyListeners();
  }

  void _applyAddressToControllers(AddressModel address) {
    pickupAddressController.text = address.addressLine;
    cityController.text = address.city;
    zipCodeController.text = address.pincode;
    _selectedState = address.state ?? 'Kerala';
    _selectedDistrict = address.district;
    _selectedLocalBody = address.localBody;
    _selectedWard = address.ward;
  }

  Future<AddressModel?> saveCurrentAddressToProfile({String? type}) async {
    final addr = pickupAddressController.text.trim();
    final city = cityController.text.trim();
    final zip = zipCodeController.text.trim();
    if (addr.isEmpty || city.isEmpty) return null;

    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type ?? (_savedAddresses.isEmpty ? 'Home' : 'Address #${DateTime.now().millisecondsSinceEpoch}'),
      addressLine: addr,
      city: city,
      pincode: zip.isNotEmpty ? zip : '695001',
      state: _selectedState ?? 'Kerala',
      district: _selectedDistrict,
      localBody: _selectedLocalBody,
      ward: _selectedWard,
      isDefault: _savedAddresses.isEmpty,
    );

    await AddressStorageService.addAddress(newAddress);
    await loadSavedAddresses();
    _selectedSavedAddress = newAddress;
    notifyListeners();
    return newAddress;
  }

  String? _selectedState;
  String? get selectedState => _selectedState;

  String? _selectedDistrict;
  String? get selectedDistrict => _selectedDistrict;

  String? _selectedLocalBody;
  String? get selectedLocalBody => _selectedLocalBody;

  String? _selectedWard;
  String? get selectedWard => _selectedWard;

  double? _latitude;
  double? get latitude => _latitude;

  double? _longitude;
  double? get longitude => _longitude;

  void setMapLocation({
    required String address,
    required String city,
    String? state,
    String? district,
    String? localBody,
    String? ward,
    String? zipCode,
    double? lat,
    double? lng,
  }) {
    if (address.isNotEmpty) {
      pickupAddressController.text = address;
    }
    if (city.isNotEmpty) {
      cityController.text = city;
    }
    if (state != null && state.isNotEmpty) {
      _selectedState = state;
    }
    if (district != null && district.isNotEmpty) {
      _selectedDistrict = district;
    }
    if (localBody != null && localBody.isNotEmpty) {
      _selectedLocalBody = localBody;
    }
    if (ward != null && ward.isNotEmpty) {
      _selectedWard = ward;
    }
    if (zipCode != null && zipCode.isNotEmpty) {
      zipCodeController.text = zipCode;
    }
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  bool _saveToProfile = true; // Image 5 shows switch ON
  bool get saveToProfile => _saveToProfile;

  bool get hasSelectedCategory => _categories.any((c) => c.isSelected);

  bool get isSanitarySelected =>
      _categories.any((c) => c.id == 'sanitary' && c.isSelected);

  double get totalCarbonOffset {
    double total = 0.0;
    for (final cat in _categories) {
      if (cat.isSelected) {
        total += cat.carbonOffsetKg;
      }
    }
    return total;
  }

  int get totalPointsXP {
    int total = 0;
    for (final cat in _categories) {
      if (cat.isSelected) {
        total += cat.pointsXP;
      }
    }
    return total;
  }

  String get carbonOffsetFormatted {
    if (!hasSelectedCategory) return '0.0 kg';
    return '-${totalCarbonOffset.toStringAsFixed(1)} kg';
  }

  String get pointsXPFormatted {
    if (!hasSelectedCategory) return '+0 XP';
    return '+$totalPointsXP XP';
  }

  void toggleCategory(String id, bool selected) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;

    if (index == 0) {
      _categories[0] = _categories[0].copyWith(isSelected: selected);
    }
    for (int i = 1; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(isSelected: false);
    }
    notifyListeners();
  }

  void setAddressTab(int index) {
    _selectedAddressTab = index;
    if (index == 0 && _selectedSavedAddress != null) {
      _applyAddressToControllers(_selectedSavedAddress!);
    }
    notifyListeners();
  }

  void setStateSelection(String? state) {
    _selectedState = state;
    _selectedDistrict = null;
    _selectedLocalBody = null;
    _selectedWard = null;
    notifyListeners();
  }

  void setDistrictSelection(String? district) {
    _selectedDistrict = district;
    _selectedLocalBody = null;
    _selectedWard = null;
    notifyListeners();
  }

  void setLocalBodySelection(String? localBody) {
    _selectedLocalBody = localBody;
    _selectedWard = null;
    notifyListeners();
  }

  void setWardSelection(String? ward) {
    _selectedWard = ward;
    notifyListeners();
  }

  void setSaveToProfile(bool value) {
    _saveToProfile = value;
    notifyListeners();
  }

  void proceedToLocation() {
    _currentStep = 1;
    _locationCompleted = true; // Tick mark on Location as requested
    _scheduleCompleted = false;
    notifyListeners();
  }

  void proceedToSchedule() {
    _currentStep = 2;
    _locationCompleted = true;
    _scheduleCompleted = true;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      _locationCompleted = step >= 1;
      _scheduleCompleted = step >= 2;
      notifyListeners();
    }
  }

  void goBackStep() {
    if (_currentStep > 0) {
      _currentStep--;
      if (_currentStep < 2) _scheduleCompleted = false;
      if (_currentStep < 1) _locationCompleted = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    contactNumberController.dispose();
    pickupAddressController.dispose();
    cityController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }
}
