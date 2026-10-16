import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/sp_helper.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

import '../features/profile/model/order_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileViewModel({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository() {
    _loadCachedFirstName();
  }

  bool _isLoading = false;
  String? _errorMessage;
  bool _isUnauthorized = false;
  ProfileModel? _profile;
  String _cachedFirstName = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUnauthorized => _isUnauthorized;
  ProfileModel? get profile => _profile;
  bool get hasProfile => _profile != null;

  /// Returns authenticated user's first name, with caching support
  String get firstName {
    final name = (_profile?.displayFirstName.isNotEmpty == true)
        ? _profile!.displayFirstName
        : _cachedFirstName;
    if (name.isNotEmpty &&
        name.toLowerCase() != 'user' &&
        name.toLowerCase() != 'null') {
      return name;
    }
    return '';
  }

  /// Loads cached first name from SpHelper
  Future<void> _loadCachedFirstName() async {
    try {
      final cached = await SpHelper.getString('first_name');
      if (cached != null &&
          cached.trim().isNotEmpty &&
          cached.trim().toLowerCase() != 'user' &&
          cached.trim().toLowerCase() != 'null') {
        _cachedFirstName = cached.trim();
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Public method to reload cached data
  Future<void> loadCachedData() async {
    await _loadCachedFirstName();
  }

  /// Fetches the authenticated user profile
  Future<bool> getProfile({VoidCallback? onUnauthorized}) async {
    _isLoading = true;
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();

    debugPrint('🔄 [PROFILE VIEWMODEL] getProfile() initiated. Loading state set to true.');

    try {
      final fetchedProfile = await _profileRepository.getProfile();
      _profile = fetchedProfile;
      final fName = fetchedProfile.displayFirstName;
      if (fName.isNotEmpty) {
        _cachedFirstName = fName;
      }
      _errorMessage = null;
      _isUnauthorized = false;
      debugPrint('================================================================');
      debugPrint('🎉 [PROFILE VIEWMODEL] Profile fetched & stored successfully:');
      debugPrint('   User: ${_profile?.fullName}');
      debugPrint('   First Name: ${_profile?.displayFirstName}');
      debugPrint('   Phone: ${_profile?.phoneNumber}');
      debugPrint('   Email: ${_profile?.displayEmail}');
      debugPrint('   Address: ${_profile?.formattedAddress}');
      debugPrint('================================================================');
      return true;
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        _isUnauthorized = true;
        _errorMessage = 'Session expired. Please log in again.';
        debugPrint('⚠️ [PROFILE VIEWMODEL] 401 Unauthorized received. Clearing local session.');
        await _clearSavedAuth();
        if (onUnauthorized != null) {
          onUnauthorized();
        }
      } else {
        _errorMessage = dioError.message ?? 'Failed to load profile. Please try again.';
        debugPrint('❌ [PROFILE VIEWMODEL] DioException: $_errorMessage');
      }
      return false;
    } catch (e) {
      final errorString = e.toString().replaceFirst('Exception: ', '');
      if (errorString.toLowerCase().contains('401') ||
          errorString.toLowerCase().contains('unauthorized')) {
        _isUnauthorized = true;
        _errorMessage = 'Session expired. Please log in again.';
        await _clearSavedAuth();
        if (onUnauthorized != null) {
          onUnauthorized();
        }
      } else {
        _errorMessage = errorString;
      }
      debugPrint('❌ [PROFILE VIEWMODEL] Error loading profile: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears saved authentication credentials upon 401 or logout
  Future<void> _clearSavedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await SpHelper.clearAll();
      OrderStore.instance.resetForLogout();
      debugPrint('🧹 [PROFILE VIEWMODEL] SharedPreferences completely cleared.');
    } catch (e) {
      debugPrint('⚠️ [PROFILE VIEWMODEL] Error clearing shared preferences: $e');
    }
  }

  /// Clears the loaded profile section data
  void clearProfile() {
    _profile = null;
    _cachedFirstName = '';
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();
  }

  /// Explicit logout action
  Future<void> logout() async {
    await _clearSavedAuth();
    _profile = null;
    _cachedFirstName = '';
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();
  }
}
