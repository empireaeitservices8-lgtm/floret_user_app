import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileViewModel({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isUnauthorized = false;
  ProfileModel? _profile;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUnauthorized => _isUnauthorized;
  ProfileModel? get profile => _profile;
  bool get hasProfile => _profile != null;

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
      _errorMessage = null;
      _isUnauthorized = false;
      debugPrint('================================================================');
      debugPrint('🎉 [PROFILE VIEWMODEL] Profile fetched & stored successfully:');
      debugPrint('   User: ${_profile?.fullName}');
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
      await prefs.remove('token');
      await prefs.remove('user_id');
      await prefs.remove('username');
      await prefs.remove('phone_number');
      await prefs.remove('account_type');
      await prefs.remove('mou_status');
      await prefs.remove('can_access_app');
      debugPrint('🧹 [PROFILE VIEWMODEL] Local authentication cache cleared.');
    } catch (e) {
      debugPrint('⚠️ [PROFILE VIEWMODEL] Error clearing shared preferences: $e');
    }
  }

  /// Explicit logout action
  Future<void> logout() async {
    await _clearSavedAuth();
    _profile = null;
    _errorMessage = null;
    _isUnauthorized = false;
    notifyListeners();
  }
}
