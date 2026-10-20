import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/profile/model/address_model.dart';

class AddressStorageService {
  static const String _kSavedAddressesKey = 'user_saved_addresses';


  /// Retrieves saved addresses from SharedPreferences.
  /// If no addresses exist, it initializes with user's registration address if available.
  static Future<List<AddressModel>> getSavedAddresses() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_kSavedAddressesKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List && decoded.isNotEmpty) {
          final list = decoded
              .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return deduplicateAddresses(list);
        }
      }

      // Check for user's registration address in SharedPreferences
      final regStreet = sp.getString('registration_street') ??
          sp.getString('street') ??
          sp.getString('registration_address');
      if (regStreet != null && regStreet.trim().isNotEmpty) {
        final regCity = sp.getString('registration_city') ?? sp.getString('city') ?? '';
        final regState = sp.getString('registration_state') ?? sp.getString('state') ?? 'Kerala';
        final regDistrict = sp.getString('registration_district') ?? sp.getString('district');
        final regLocalBody = sp.getString('registration_local_body') ?? sp.getString('local_body');
        final regWard = sp.getString('registration_ward') ?? sp.getString('ward');
        final regPin = sp.getString('registration_zip_code') ?? sp.getString('pincode') ?? sp.getString('zip_code') ?? '';

        final regAddress = AddressModel(
          id: 'reg_user_addr',
          type: 'Home',
          addressLine: regStreet.trim(),
          city: regCity.trim(),
          state: regState.trim(),
          district: regDistrict?.trim(),
          localBody: regLocalBody?.trim(),
          ward: regWard?.trim(),
          pincode: regPin.trim(),
          isDefault: true,
        );
        await saveAddresses([regAddress]);
        return [regAddress];
      }

      final defaultSeeds = [
        AddressModel(
          id: '1792210679721',
          type: 'Home',
          addressLine: 'Sunset Blvd',
          city: 'Thiruvananthapuram Corp',
          state: 'Kerala',
          district: 'Thiruvananthapuram',
          localBody: 'Thiruvananthapuram Corporation',
          ward: 'Ward 1',
          pincode: '695001',
          isDefault: true,
        ),
      ];
      await saveAddresses(defaultSeeds);
      return defaultSeeds;
    } catch (_) {
      return [];
    }
  }

  /// Deduplicates a list of addresses by addressLine (case-insensitive & trimmed),
  /// keeping only the latest one.
  static List<AddressModel> deduplicateAddresses(List<AddressModel> addresses) {
    if (addresses.isEmpty) return [];

    final Map<String, AddressModel> map = {};
    for (final addr in addresses) {
      final key = addr.addressLine.trim().toLowerCase();
      if (key.isNotEmpty) {
        final existing = map[key];
        if (existing != null) {
          final isDef = addr.isDefault || existing.isDefault;
          map[key] = addr.copyWith(isDefault: isDef);
        } else {
          map[key] = addr;
        }
      } else {
        map[addr.id] = addr;
      }
    }

    return map.values.toList();
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

    // If matching id or addressLine exists, replace it with the latest one
    final normLine = finalAddress.addressLine.trim().toLowerCase();
    final existingIndex = updatedList.indexWhere(
      (a) =>
          a.id == finalAddress.id ||
          (normLine.isNotEmpty &&
              a.addressLine.trim().toLowerCase() == normLine),
    );
    if (existingIndex != -1) {
      final wasDefault = updatedList[existingIndex].isDefault;
      final existingType = updatedList[existingIndex].type;
      final resolvedType = (finalAddress.type.startsWith('Address #') &&
              !existingType.startsWith('Address #'))
          ? existingType
          : finalAddress.type;
      final resolvedAddress = finalAddress.copyWith(
        id: updatedList[existingIndex].id,
        type: resolvedType,
        isDefault: wasDefault && !shouldMakeDefault ? true : shouldMakeDefault,
      );
      updatedList[existingIndex] = resolvedAddress;
      // Remove any other duplicates with the same addressLine
      if (normLine.isNotEmpty) {
        for (int i = updatedList.length - 1; i >= 0; i--) {
          if (i != existingIndex &&
              updatedList[i].addressLine.trim().toLowerCase() == normLine) {
            updatedList.removeAt(i);
          }
        }
      }
      await saveAddresses(updatedList);
      return resolvedAddress;
    } else {
      updatedList.add(finalAddress);
      await saveAddresses(updatedList);
      return finalAddress;
    }
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
