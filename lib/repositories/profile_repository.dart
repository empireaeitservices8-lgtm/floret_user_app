import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/sp_helper.dart';
import '../utils/sp_keys.dart' as sp_keys;
import '../models/profile_model.dart';
import '../features/profile/model/order_model.dart';
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
    }

    return profileModel;
  }
}
