import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/sp_helper.dart';
import '../utils/sp_keys.dart' as sp_keys;
import '../models/profile_model.dart';
import '../features/profile/model/order_model.dart';
import '../features/profile/model/address_model.dart';
import '../services/address_storage_service.dart';
import '../services/api_service.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetches the user profile from the backend API and transforms it into ProfileModel
  Future<ProfileModel> getProfile({String? token}) async {
    // 1. Delegate network call to ApiService
    final response = await _apiService.getProfile(token: token);

    // 2. Parse response data safely
    final dynamic responseData = response.data;
    final Map<String, dynamic> jsonMap;

    if (responseData is Map<String, dynamic>) {
      jsonMap = responseData;
    } else if (responseData is Map) {
      jsonMap = Map<String, dynamic>.from(responseData);
    } else if (responseData is String) {
      jsonMap = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      debugPrint('❌ [PROFILE REPOSITORY ERROR] Invalid response format received from server.');
      throw Exception('Invalid response format received from server.');
    }

    // 3. Convert JSON Map into ProfileModel
    final profileModel = ProfileModel.fromJson(jsonMap);
    debugPrint('================================================================');
    debugPrint('👤 [PROFILE REPOSITORY] Successfully mapped to ProfileModel:');
    debugPrint('   Profile ID: ${profileModel.id}');
    debugPrint('   User ID: ${profileModel.user?.id}');
    debugPrint('   Username: ${profileModel.user?.username}');
    debugPrint('   Full Name: ${profileModel.fullName}');
    debugPrint('   Phone: ${profileModel.phoneNumber}');
    debugPrint('   Email: ${profileModel.displayEmail}');
    debugPrint('   Account Type: ${profileModel.accountType}');
    debugPrint('   MOU Status: ${profileModel.mouStatus}');
    debugPrint('   Address: ${profileModel.formattedAddress}');
    debugPrint('   City: ${profileModel.city}');
    debugPrint('   District: ${profileModel.district}');
    debugPrint('   State: ${profileModel.state}');
    debugPrint('   Zip Code: ${profileModel.zipCode}');
    debugPrint('   Registration Fee Paid: ${profileModel.registrationFeePaid}');
    debugPrint('================================================================');

    // 4. Cache user's first name and last name for persistent display across app
    final firstName = profileModel.displayFirstName;
    if (firstName.isNotEmpty) {
      await SpHelper.saveUserName(firstName);
    } else if (profileModel.fullName.isNotEmpty &&
        profileModel.fullName.toLowerCase() != 'user') {
      await SpHelper.saveUserName(profileModel.fullName);
    }
    final lastName = (profileModel.user?.lastName ?? profileModel.lastName ?? '').trim();
    if (lastName.isNotEmpty) {
      await SpHelper.saveString('last_name', lastName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_name', lastName);
    }

    final uId = profileModel.user?.id?.toString() ??
        (profileModel.id != null ? profileModel.id.toString() : '');
    if (uId.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyUserId, uId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sp_keys.keyUserId, uId);
      await prefs.setString('user_id', uId);
      await OrderStore.instance.loadForUser(uId);
      await AddressStorageService.loadForUser(uId);
    }
    if (profileModel.accountType != null && profileModel.accountType!.isNotEmpty) {
      await SpHelper.saveString('account_type', profileModel.accountType!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('account_type', profileModel.accountType!);
    }
    if (profileModel.registrationFeePaid != null) {
      await SpHelper.saveBoolean('commercial_fee_paid', profileModel.registrationFeePaid!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('commercial_fee_paid', profileModel.registrationFeePaid!);
    }

    // Persist registration/profile address for My Account and Saved Addresses
    final prefs = await SharedPreferences.getInstance();
    if (profileModel.formattedAddress.isNotEmpty &&
        profileModel.formattedAddress != 'Not provided') {
      await SpHelper.saveString('registration_address', profileModel.formattedAddress);
      await prefs.setString('registration_address', profileModel.formattedAddress);
    }
    if (profileModel.street != null && profileModel.street!.isNotEmpty) {
      await SpHelper.saveString('registration_street', profileModel.street!);
      await prefs.setString('registration_street', profileModel.street!);
      await prefs.setString('street', profileModel.street!);
    }
    if (profileModel.city != null && profileModel.city!.isNotEmpty) {
      await SpHelper.saveString('registration_city', profileModel.city!);
      await prefs.setString('registration_city', profileModel.city!);
      await prefs.setString('city', profileModel.city!);
    }
    if (profileModel.district != null && profileModel.district!.isNotEmpty) {
      await SpHelper.saveString('registration_district', profileModel.district!);
      await prefs.setString('registration_district', profileModel.district!);
      await prefs.setString('district', profileModel.district!);
    }
    if (profileModel.state != null && profileModel.state!.isNotEmpty) {
      await SpHelper.saveString('registration_state', profileModel.state!);
      await prefs.setString('registration_state', profileModel.state!);
      await prefs.setString('state', profileModel.state!);
    }
    if (profileModel.localBody != null && profileModel.localBody!.isNotEmpty) {
      await SpHelper.saveString('registration_local_body', profileModel.localBody!);
      await prefs.setString('registration_local_body', profileModel.localBody!);
      await prefs.setString('local_body', profileModel.localBody!);
    }
    if (profileModel.ward != null && profileModel.ward!.isNotEmpty) {
      await SpHelper.saveString('registration_ward', profileModel.ward!);
      await prefs.setString('registration_ward', profileModel.ward!);
      await prefs.setString('ward', profileModel.ward!);
    }
    if (profileModel.zipCode != null && profileModel.zipCode!.isNotEmpty) {
      await SpHelper.saveString('registration_zip_code', profileModel.zipCode!);
      await prefs.setString('registration_zip_code', profileModel.zipCode!);
      await prefs.setString('zip_code', profileModel.zipCode!);
      await prefs.setString('pincode', profileModel.zipCode!);
    }

    if ((profileModel.street != null && profileModel.street!.isNotEmpty) ||
        (profileModel.city != null && profileModel.city!.isNotEmpty)) {
      final regModel = AddressModel(
        id: 'profile_addr_${DateTime.now().millisecondsSinceEpoch}',
        type: 'Home',
        addressLine: profileModel.street?.trim().isNotEmpty == true
            ? profileModel.street!.trim()
            : (profileModel.formattedAddress.isNotEmpty
                ? profileModel.formattedAddress
                : 'Home Address'),
        city: profileModel.city?.trim() ?? '',
        district: profileModel.district?.trim(),
        state: profileModel.state?.trim() ?? 'Kerala',
        localBody: profileModel.localBody?.trim(),
        ward: profileModel.ward?.trim(),
        pincode: profileModel.zipCode?.trim() ?? '',
        isDefault: true,
      );
      await AddressStorageService.addAddress(regModel);
    }

    return profileModel;
  }

  /// Sends an authenticated DELETE request to /api/profile/ to delete user profile
  Future<void> deleteProfile({String? token}) async {
    await _apiService.deleteProfile(token: token);
  }
}
