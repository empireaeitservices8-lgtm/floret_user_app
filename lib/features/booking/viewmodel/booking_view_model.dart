import 'package:floret_app/providers/view_model.dart';
import 'package:flutter/material.dart';
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
  }

  Future<void> _loadUserContact() async {
    try {
      final contact = await _repository.getUserContact();
      if (fullNameController.text.isEmpty && contact.fullName.isNotEmpty) {
        fullNameController.text = contact.fullName;
      }
      if (contactNumberController.text.isEmpty && contact.contactNumber.isNotEmpty) {
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

  String? _selectedState;
  String? get selectedState => _selectedState;

  String? _selectedDistrict;
  String? get selectedDistrict => _selectedDistrict;

  String? _selectedLocalBody;
  String? get selectedLocalBody => _selectedLocalBody;

  String? _selectedWard;
  String? get selectedWard => _selectedWard;

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
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(isSelected: selected);
      notifyListeners();
    }
  }

  void setAddressTab(int index) {
    _selectedAddressTab = index;
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
    notifyListeners();
  }

  void proceedToSchedule() {
    _currentStep = 2;
    _scheduleCompleted = true;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      if (step >= 1) _locationCompleted = true;
      if (step >= 2) _scheduleCompleted = true;
      notifyListeners();
    }
  }

  void goBackStep() {
    if (_currentStep > 0) {
      _currentStep--;
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
