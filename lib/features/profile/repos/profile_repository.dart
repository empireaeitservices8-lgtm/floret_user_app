import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import '../model/address_model.dart';
import '../model/profile_model.dart';

class ProfileRepository {
  final WebAPIService _webAPIService;

  ProfileRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<UserProfileModel> getUserProfile() async {
    final firstName = await SpHelper.getString('first_name');
    final storedName = await SpHelper.getString(sp_keys.keyUserName);
    final rawUname = await SpHelper.getString('username');
    final name = (firstName != null && firstName.trim().isNotEmpty && firstName.trim().toLowerCase() != 'user')
        ? firstName.trim()
        : (storedName != null && storedName.trim().isNotEmpty && storedName.trim().toLowerCase() != 'user')
            ? storedName.trim()
            : (rawUname != null && rawUname.trim().isNotEmpty && rawUname.trim().toLowerCase() != 'user')
                ? rawUname.trim()
                : '';
    final mobile = await SpHelper.getString(sp_keys.keyUseMobile) ??
        await SpHelper.getString('phone_number') ??
        '';
    final email = await SpHelper.getString(sp_keys.keyEmail) ??
        await SpHelper.getString('email') ??
        '';

    return UserProfileModel(
      name: name,
      mobileNumber: mobile,
      email: email,
      location: 'Kerala, India',
      totalCollections: 14,
      totalWeightKg: 42.5,
      ecoRewardPoints: 250,
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String mobileNumber,
    required String email,
  }) async {
    await SpHelper.saveString(sp_keys.keyUserName, name);
    await SpHelper.saveString(sp_keys.keyUseMobile, mobileNumber);
    await SpHelper.saveString(sp_keys.keyEmail, email);
    return true;
  }

  Future<List<AddressModel>> fetchAddresses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<bool> saveAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<List<OrderHistoryItemModel>> fetchOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }

  Future<bool> submitSupportTicket({
    required String subject,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
