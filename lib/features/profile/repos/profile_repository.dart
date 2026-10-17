import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/services/address_storage_service.dart';
import '../model/address_model.dart';
import '../model/order_model.dart';
import '../model/profile_model.dart';

class ProfileRepository {
  final WebAPIService _webAPIService;
  final ApiService _apiService;

  ProfileRepository({
    WebAPIService? webAPIService,
    ApiService? apiService,
  })  : _webAPIService = webAPIService ?? WebAPIService(),
        _apiService = apiService ?? ApiService();

  WebAPIService get webAPIService => _webAPIService;
  ApiService get apiService => _apiService;

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
    return await AddressStorageService.getSavedAddresses();
  }

  Future<bool> saveAddress(AddressModel address) async {
    await AddressStorageService.addAddress(address);
    return true;
  }

  Future<bool> deleteAddress(String id) async {
    await AddressStorageService.deleteAddress(id);
    return true;
  }

  /// Fetches the authenticated user's pickup bookings from GET /api/pickups/
  Future<List<OrderModel>> fetchOrderHistory({String? token}) async {
    // 1. Resolve authentication token
    final authToken = token ??
        await SpHelper.getString(sp_keys.keyToken) ??
        await SpHelper.getString('token') ??
        (await SharedPreferences.getInstance()).getString('token') ??
        (await SharedPreferences.getInstance()).getString(sp_keys.keyToken);

    if (authToken == null || authToken.trim().isEmpty) {
      return [];
    }

    // 2. Resolve authenticated user's ID
    String uid = await SpHelper.getString(sp_keys.keyUserId) ??
        await SpHelper.getString('user_id') ??
        (await SharedPreferences.getInstance()).getString(sp_keys.keyUserId) ??
        (await SharedPreferences.getInstance()).getString('user_id') ??
        (await SharedPreferences.getInstance()).getInt('user_id')?.toString() ??
        '';

    // 3. Perform authenticated GET request to /api/pickups/
    final response = await _apiService.getPickups(token: authToken);

    List rawList = [];
    if (response.data is List) {
      rawList = response.data as List;
    } else if (response.data is Map) {
      final map = response.data as Map;
      if (map['results'] is List) {
        rawList = map['results'] as List;
      } else if (map['pickups'] is List) {
        rawList = map['pickups'] as List;
      } else if (map['data'] is List) {
        rawList = map['data'] as List;
      }
    }

    final List<OrderModel> orders = [];
    for (final item in rawList) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      // Verify that this pickup record belongs to the signed-in user
      final dynamic rawUser = map['user'] ?? map['user_id'] ?? map['userId'];
      final String? itemUserId = rawUser is Map
          ? (rawUser['id'] ?? rawUser['user_id'])?.toString()
          : rawUser?.toString().trim();

      if (itemUserId != null && itemUserId.isNotEmpty) {
        if (uid.isNotEmpty && itemUserId != uid) {
          // Belongs to another user - strictly do not show
          continue;
        }
        if (uid.isEmpty) {
          // Cache the resolved user ID from authenticated session
          uid = itemUserId;
          SpHelper.saveString(sp_keys.keyUserId, itemUserId);
          OrderStore.instance.loadForUser(itemUserId);
        }
      }

      orders.add(OrderModel.fromBackendJson(map, defaultUserId: uid.isNotEmpty ? uid : null));
    }

    return orders;
  }

  /// Backward-compatible adapter for legacy OrderHistoryItemModel consumers
  Future<List<OrderHistoryItemModel>> fetchOrderHistoryItems({
    String? token,
  }) async {
    final list = await fetchOrderHistory(token: token);
    return list.map((o) => OrderHistoryItemModel.fromOrderModel(o)).toList();
  }

  Future<bool> submitSupportTicket({
    required String subject,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
