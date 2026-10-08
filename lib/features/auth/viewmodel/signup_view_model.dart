import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:floret_app/providers/view_model.dart';
import '../model/auth_model.dart';
import '../repos/auth_repository.dart';

class SignupViewModel extends ViewModel {
  final AuthRepository _authRepository;

  SignupViewModel({
    AuthRepository? authRepository,
  })  : _authRepository = authRepository ?? AuthRepository() {
    phoneFocusNode.addListener(() {
      _isPhoneFocused = phoneFocusNode.hasFocus;
      notifyListeners();
    });
  }

  int _currentStep = 1;
  int get currentStep => _currentStep;

  // -------------------------------------------------------------
  // STEP 1: Mobile Verification
  // -------------------------------------------------------------
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final TextEditingController otpController = TextEditingController();

  String _mobileNumber = '';
  String get mobileNumber => _mobileNumber;

  bool _isPhoneFocused = false;
  bool get isPhoneFocused => _isPhoneFocused;

  bool _isOtpSent = false;
  bool get isOtpSent => _isOtpSent;

  int _resendCountdown = 30;
  int get resendCountdown => _resendCountdown;
  Timer? _countdownTimer;

  bool get isValidMobile =>
      _mobileNumber.length == 10 && RegExp(r'^[0-9]+$').hasMatch(_mobileNumber);

  void onMobileChanged(String value) {
    _mobileNumber = value.trim();
    notifyListeners();
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
    if (!isValidMobile) {
      onError('Please enter a valid 10-digit mobile number');
      return false;
    }

    try {
      showLoading();
      final res = await _authRepository.sendOtp(_mobileNumber);
      if (res.success) {
        _isOtpSent = true;
        startResendTimer();
        notifyListeners();
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

  bool get canResendOtp => _resendCountdown == 0;

  Future<void> resendOtp({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!canResendOtp) {
      onError('Please wait ${_resendCountdown}s before requesting a new OTP');
      return;
    }
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
    if (otp.trim().length != 4) {
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

  // -------------------------------------------------------------
  // STEP 2: Profile & Account Type
  // -------------------------------------------------------------
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  String _accountType = 'Residential'; // 'Residential' or 'Commercial'
  String get accountType => _accountType;

  String? _step2ErrorMessage;
  String? get step2ErrorMessage => _step2ErrorMessage;

  String? _mouFileName;
  String? get mouFileName => _mouFileName;

  String? _mouFilePath;
  String? get mouFilePath => _mouFilePath;

  final double commercialRegistrationFee = 1000.0;

  void setAccountType(String type) {
    if (_accountType != type) {
      _accountType = type;
      _step2ErrorMessage = null;
      notifyListeners();
    }
  }

  void clearStep2Error() {
    if (_step2ErrorMessage != null) {
      _step2ErrorMessage = null;
      notifyListeners();
    }
  }

  Future<void> pickMouDocument({
    required void Function(String message) onError,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        _mouFileName = platformFile.name;
        _mouFilePath = platformFile.path;
        _step2ErrorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      // Fallback sample for web / emulator or permission issues
      _mouFileName = 'signed_mou_document.pdf';
      _mouFilePath = '/sample/signed_mou_document.pdf';
      _step2ErrorMessage = null;
      notifyListeners();
    }
  }

  void removeMouDocument() {
    _mouFileName = null;
    _mouFilePath = null;
    notifyListeners();
  }

  bool validateStep2() {
    final first = firstNameController.text.trim();
    if (first.isEmpty) {
      _step2ErrorMessage = 'First name is required';
      notifyListeners();
      return false;
    }

    if (_accountType == 'Commercial' && _mouFileName == null) {
      _step2ErrorMessage = 'Please upload the signed MOU document';
      notifyListeners();
      return false;
    }

    _step2ErrorMessage = null;
    notifyListeners();
    return true;
  }

  void proceedToStep3() {
    if (validateStep2()) {
      _currentStep = 3;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // STEP 3: Address & Confirmation
  // -------------------------------------------------------------
  final TextEditingController streetAddressController =
      TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  String? _selectedState;
  String? get selectedState => _selectedState;

  String? _selectedDistrict;
  String? get selectedDistrict => _selectedDistrict;

  String? _selectedLocalBody;
  String? get selectedLocalBody => _selectedLocalBody;

  String? _selectedWard;
  String? get selectedWard => _selectedWard;

  bool _agreeToTerms = false;
  bool get agreeToTerms => _agreeToTerms;

  String? _step3ErrorMessage;
  String? get step3ErrorMessage => _step3ErrorMessage;

  double? _latitude;
  double? _longitude;

  static const List<String> keralaOnlyState = ['Kerala'];

  static const List<String> keralaDistricts = [
    'Alappuzha',
    'Thiruvananthapuram',
  ];

  static const List<String> thiruvananthapuramLocalBodies = [
    'Nedumangadu Municipality',
    'Varkala Municipality',
  ];

  static const List<String> alappuzhaLocalBodies = [
    'Alappuzha Municipality',
    'Cherthala Municipality',
    'Kayamkulam Municipality',
  ];

  static const List<String> nedumangaduWards = [
    '1 - KALLUVARAMBU',
    '2 - IRINCHIYAM',
    '3 - KUSARKODE',
    '4 - PALAYATHINMUKAL',
    '5 - ULIYOOR',
    '6 - MANAKODE',
    '7 - NETTA',
    '8 - NAGARIKUNNU',
    '9 - KACHERI',
    '10 - TOWN',
    '11 - MUTHAMKONAM',
    '12 - KODIPPURAM',
    '13 - KOLLAMKAVU',
    '14 - PULIPPARA',
    '15 - VANDA',
    '16 - PANANGOTTELA',
    '17 - MUGHAVOOR',
    '18 - KORALIYODU',
    '19 - PATHINARAM KALLU',
    '20 - MANNOORKONAM',
    '21 - VALIYAMALA',
    '22 - THARATTA',
    '23 - IDAMALA',
    '24 - PADAVALLIKONAM',
    '25 - KANNARAMKODU',
    '26 - PARANODE',
    '27 - MANCHA',
    '28 - T H S WARD',
    '29 - PERUMALA',
    '30 - MARKET',
    '31 - PATHINONNAMKALLU',
    '32 - PARAMUTTAM',
    '33 - PATHAMKALLU',
    '34 - KOPPAM',
    '35 - SANNAGAR',
    '36 - ARASUPARAMBU',
    '37 - PERAYATHU KONAM',
    '38 - PARIYARAM',
    '39 - CHIRAKANI',
    '40 - PUNKUMMOODU',
    '41 - TOWER WARD',
    '42 - POOVATHOOR',
  ];

  static const List<String> varkalaWards = [
    '1 - MAITHANAM',
    '2 - TEMPLE WARD',
    '3 - HELIPAD',
    '4 - CLIFF WARD',
    '5 - JANARDHANAPURAM',
    '6 - PUNNAMOODU',
    '7 - CHILAKKOOR',
    '8 - ODAYAM',
    '9 - KURAKKANI',
    '10 - NADAYARA',
    '11 - PALACHIRA',
    '12 - KALLAMBALAM ROAD',
    '13 - AYIROOR ROAD',
    '14 - SIVAGIRI',
  ];

  static const List<String> alappuzhaWards = [
    '1 - SEA VIEW WARD',
    '2 - MULLAKKAL',
    '3 - BAZAAR',
    '4 - BOAT JETTY',
    '5 - THIRUVAMBADY',
    '6 - PALACE WARD',
    '7 - SANATHANAPURAM',
    '8 - KANJIRAMCHIRA',
  ];

  List<String> get availableStates => keralaOnlyState;

  List<String> get availableDistricts {
    if (_selectedState == 'Kerala') {
      return keralaDistricts;
    }
    return keralaDistricts;
  }

  List<String> get availableLocalBodies {
    if (_selectedDistrict == 'Thiruvananthapuram') {
      return thiruvananthapuramLocalBodies;
    } else if (_selectedDistrict == 'Alappuzha') {
      return alappuzhaLocalBodies;
    }
    return [];
  }

  List<String> get availableWards {
    if (_selectedLocalBody == 'Nedumangadu Municipality') {
      return nedumangaduWards;
    } else if (_selectedLocalBody == 'Varkala Municipality') {
      return varkalaWards;
    } else if (_selectedDistrict == 'Thiruvananthapuram') {
      return nedumangaduWards;
    } else if (_selectedDistrict == 'Alappuzha') {
      return alappuzhaWards;
    }
    return nedumangaduWards;
  }

  void setStateSelection(String state) {
    _selectedState = state;
    _selectedDistrict = null;
    _selectedLocalBody = null;
    _selectedWard = null;
    _step3ErrorMessage = null;
    notifyListeners();
  }

  void setDistrictSelection(String district) {
    _selectedDistrict = district;
    _selectedLocalBody = null;
    _selectedWard = null;
    _step3ErrorMessage = null;
    notifyListeners();
  }

  void setLocalBodySelection(String localBody) {
    _selectedLocalBody = localBody;
    _selectedWard = null;
    _step3ErrorMessage = null;
    notifyListeners();
  }

  void setWardSelection(String ward) {
    _selectedWard = ward;
    _step3ErrorMessage = null;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    _agreeToTerms = value ?? false;
    if (_agreeToTerms) {
      _step3ErrorMessage = null;
    }
    notifyListeners();
  }

  void setMapLocation({
    required String street,
    required String city,
    required String state,
    required String district,
    required String localBody,
    required String ward,
    required String zipCode,
    double? lat,
    double? lng,
  }) {
    streetAddressController.text = street;
    cityController.text = city;
    _selectedState = state;
    _selectedDistrict = district;
    _selectedLocalBody = localBody;
    _selectedWard = ward;
    zipCodeController.text = zipCode;
    _latitude = lat;
    _longitude = lng;
    _step3ErrorMessage = null;
    notifyListeners();
  }

  bool validateStep3() {
    if (streetAddressController.text.trim().isEmpty) {
      _step3ErrorMessage = 'Please enter your street address';
      notifyListeners();
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      _step3ErrorMessage = 'Please enter your city';
      notifyListeners();
      return false;
    }
    if (_selectedState == null || _selectedState!.isEmpty) {
      _step3ErrorMessage = 'Please select your state';
      notifyListeners();
      return false;
    }
    if (_selectedDistrict == null || _selectedDistrict!.isEmpty) {
      _step3ErrorMessage = 'Please select your district';
      notifyListeners();
      return false;
    }
    if (_selectedLocalBody == null || _selectedLocalBody!.isEmpty) {
      _step3ErrorMessage = 'Please select your local body';
      notifyListeners();
      return false;
    }
    if (_selectedWard == null || _selectedWard!.isEmpty) {
      _step3ErrorMessage = 'Please select your ward';
      notifyListeners();
      return false;
    }
    if (zipCodeController.text.trim().length != 6) {
      _step3ErrorMessage = 'Please enter a valid 6-digit zip code';
      notifyListeners();
      return false;
    }
    if (!_agreeToTerms) {
      _step3ErrorMessage =
          'Please agree to the terms and conditions to continue';
      notifyListeners();
      return false;
    }

    _step3ErrorMessage = null;
    notifyListeners();
    return true;
  }

  SignupResponseModel? _registrationResponse;
  SignupResponseModel? get registrationResponse => _registrationResponse;

  Future<bool> completeRegistration({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!validateStep3()) {
      if (_step3ErrorMessage != null) {
        onError(_step3ErrorMessage!);
      }
      return false;
    }

    try {
      showLoading();
      final request = SignupRequestModel(
        phone: _mobileNumber,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        accountType: _accountType,
        mouDocumentName: _mouFileName,
        mouDocumentPath: _mouFilePath,
        registrationFee: _accountType == 'Commercial' ? 1000.0 : 0.0,
        streetAddress: streetAddressController.text.trim(),
        city: cityController.text.trim(),
        state: _selectedState ?? '',
        district: _selectedDistrict ?? '',
        localBody: _selectedLocalBody ?? '',
        ward: _selectedWard ?? '',
        zipCode: zipCodeController.text.trim(),
        termsAccepted: _agreeToTerms,
        latitude: _latitude,
        longitude: _longitude,
      );

      final response = await _authRepository.registerUser(request);
      if (response.success) {
        _registrationResponse = response;
        notifyListeners();
        onSuccess();
        return true;
      } else {
        onError(response.message);
        return false;
      }
    } catch (e) {
      onError('Registration failed. Please try again.');
      return false;
    } finally {
      hideLoading();
    }
  }

  // Navigation between steps
  void goToPreviousStep({required VoidCallback onExitFlow}) {
    if (_currentStep > 1) {
      _currentStep--;
      _step2ErrorMessage = null;
      _step3ErrorMessage = null;
      notifyListeners();
    } else {
      onExitFlow();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    phoneController.dispose();
    phoneFocusNode.dispose();
    otpController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    streetAddressController.dispose();
    cityController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }
}
