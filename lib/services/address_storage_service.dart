import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/profile/model/address_model.dart';

class AddressStorageService {
  static const String _kSavedAddressesKey = 'user_saved_addresses';

  static List<AddressModel> get _defaultSeedAddresses => [
        AddressModel(
          id: '1792210679721',
          type: 'Address #1792210679721',
          addressLine: 'lll',
          city: 'yy',
          state: 'Kerala',
          pincode: '123456',
          isDefault: false,
        ),
        AddressModel(
          id: '1792210679722',
          type: 'Home',
          addressLine: 'Sunset Blvd',
          city: 'Thiruvananthapuram',
          district: 'Thiruvananthapuram',
          state: 'Kerala',
          localBody: 'Thiruvananthapuram Corp',
          ward: 'Ward 1',
          pincode: '695001',
          isDefault: true,
        ),
      ];

  /// Retrieves saved addresses from SharedPreferences.
  /// If no addresses exist, it initializes with default seed data.
  static Future<List<AddressModel>> getSavedAddresses() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_kSavedAddressesKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      // If empty or never set, populate with default seed
      final seeds = _defaultSeedAddresses;
      await saveAddresses(seeds);
      return seeds;
    } catch (_) {
      return _defaultSeedAddresses;
    }
  }

  /// Saves the complete list of addresses to SharedPreferences.
  static Future<void> saveAddresses(List<AddressModel> addresses) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
      await sp.setString(_kSavedAddressesKey, encoded);
    } catch (_) {}
  }

  /// Adds a new address or updates existing one by ID or addressLine.
  static Future<AddressModel> addAddress(AddressModel newAddress) async {
    final currentList = await getSavedAddresses();
    final updatedList = List<AddressModel>.from(currentList);

    final bool shouldMakeDefault = newAddress.isDefault || updatedList.isEmpty;

    if (shouldMakeDefault) {
      for (int i = 0; i < updatedList.length; i++) {
        updatedList[i] = updatedList[i].copyWith(isDefault: false);
      }
    }

    final finalAddress = newAddress.copyWith(isDefault: shouldMakeDefault);

    // If matching id exists, replace it
    final existingIndex = updatedList.indexWhere((a) => a.id == finalAddress.id);
    if (existingIndex != -1) {
      updatedList[existingIndex] = finalAddress;
    } else {
      updatedList.add(finalAddress);
    }

    await saveAddresses(updatedList);
    return finalAddress;
  }

  /// Deletes an address by ID and updates default if necessary.
  static Future<void> deleteAddress(String id) async {
    final currentList = await getSavedAddresses();
    final updatedList = List<AddressModel>.from(currentList);

    final index = updatedList.indexWhere((a) => a.id == id);
    if (index != -1) {
      final wasDefault = updatedList[index].isDefault;
      updatedList.removeAt(index);
      if (wasDefault && updatedList.isNotEmpty) {
        updatedList[0] = updatedList[0].copyWith(isDefault: true);
      }
      await saveAddresses(updatedList);
    }
  }

  /// Sets the address with the given ID as default.
  static Future<void> setDefaultAddress(String id) async {
    final currentList = await getSavedAddresses();
    final updatedList = List<AddressModel>.from(currentList);

    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(
        isDefault: updatedList[i].id == id,
      );
    }
    await saveAddresses(updatedList);
  }
}
