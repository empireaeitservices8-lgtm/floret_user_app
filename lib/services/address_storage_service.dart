import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/profile/model/address_model.dart';
import '../features/profile/model/order_model.dart';
import '../helpers/sp_helper.dart';
import '../utils/sp_keys.dart' as sp_keys;

class AddressStorageService {
  static const String _kSavedAddressesKey = 'user_saved_addresses';
  static String? _activeUserId;

  /// Sets or clears the active user ID for scoping saved addresses.
  static void setActiveUserId(String? userId) {
    if (userId != null && userId.trim().isNotEmpty) {
      _activeUserId = userId.trim();
    } else {
      _activeUserId = null;
    }
  }

  /// Clears active user ID during logout without deleting stored addresses.
  static void resetForLogout() {
    _activeUserId = null;
  }

  /// Resolves the current user ID from memory, SpHelper, SharedPreferences, or OrderStore.
  static Future<String> _resolveCurrentUserId([String? explicitUserId]) async {
    if (explicitUserId != null && explicitUserId.trim().isNotEmpty) {
      _activeUserId = explicitUserId.trim();
      return explicitUserId.trim();
    }
    final uid = await SpHelper.getString(sp_keys.keyUserId);
    if (uid != null && uid.trim().isNotEmpty) {
      _activeUserId = uid.trim();
      return uid.trim();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefUid = prefs.getString(sp_keys.keyUserId) ??
          prefs.getString('user_id') ??
          prefs.getInt('user_id')?.toString();
      if (prefUid != null && prefUid.trim().isNotEmpty) {
        _activeUserId = prefUid.trim();
        return prefUid.trim();
      }
    } catch (_) {}
    if (OrderStore.instance.currentUserId.isNotEmpty) {
      _activeUserId = OrderStore.instance.currentUserId;
      return _activeUserId!;
    }
    if (_activeUserId != null && _activeUserId!.isNotEmpty) {
      return _activeUserId!;
    }
    final phone = await SpHelper.getString(sp_keys.keyUseMobile) ??
        await SpHelper.getString('phone_number');
    if (phone != null && phone.trim().isNotEmpty) {
      return phone.trim();
    }
    final uname = await SpHelper.getString(sp_keys.keyUserName) ??
        await SpHelper.getString('username');
    if (uname != null &&
        uname.trim().isNotEmpty &&
        uname.trim().toLowerCase() != 'user') {
      return uname.trim();
    }
    return '';
  }

  static String _storageKeyForUser(String uid) {
    if (uid.isNotEmpty) {
      return '${_kSavedAddressesKey}_$uid';
    }
    return _kSavedAddressesKey;
  }

  /// Explicitly reloads saved addresses for a specific authenticated user.
  static Future<List<AddressModel>> loadForUser(String userId) async {
    setActiveUserId(userId);
    return await getSavedAddresses(userId: userId);
  }

  /// Retrieves saved addresses from SharedPreferences for the active user.
  /// If no addresses exist for this user, it initializes with user's registration address or default seeds.
  static Future<List<AddressModel>> getSavedAddresses({String? userId}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final uid = await _resolveCurrentUserId(userId);
      final userKey = _storageKeyForUser(uid);

      // Check for user's registration address in SharedPreferences
      final regStreet = sp.getString('registration_street') ??
          sp.getString('street') ??
          sp.getString('registration_address');
      AddressModel? regAddress;
      if (regStreet != null && regStreet.trim().isNotEmpty) {
        final regCity = sp.getString('registration_city') ??
            sp.getString('city') ??
            '';
        final regState = sp.getString('registration_state') ??
            sp.getString('state') ??
            'Kerala';
        final regDistrict = sp.getString('registration_district') ??
            sp.getString('district');
        final regLocalBody = sp.getString('registration_local_body') ??
            sp.getString('local_body');
        final regWard = sp.getString('registration_ward') ??
            sp.getString('ward');
        final regPin = sp.getString('registration_zip_code') ??
            sp.getString('pincode') ??
            sp.getString('zip_code') ??
            '';

        regAddress = AddressModel(
          id: 'reg_${uid.isNotEmpty ? uid : "user"}_addr',
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
      }

      List<AddressModel>? rawList;

      // 1. Check user-scoped key in SharedPreferences
      final raw = sp.getString(userKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List && decoded.isNotEmpty) {
          rawList = decoded
              .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      // 2. If user-scoped key is empty, check legacy _kSavedAddressesKey for migration
      if (rawList == null && uid.isNotEmpty && userKey != _kSavedAddressesKey) {
        final legacyRaw = sp.getString(_kSavedAddressesKey);
        if (legacyRaw != null && legacyRaw.trim().isNotEmpty) {
          final decoded = jsonDecode(legacyRaw);
          if (decoded is List && decoded.isNotEmpty) {
            rawList = decoded
                .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            await sp.remove(_kSavedAddressesKey);
          }
        }
      }

      // 3. If registration address exists, it MUST be the default address
      if (regAddress != null) {
        List<AddressModel> list =
            rawList != null ? List<AddressModel>.from(rawList) : [];
        // Remove dummy seeds if user has real registration address
        list.removeWhere((a) =>
            a.id == '1792210679721' ||
            (a.addressLine.toLowerCase() == 'sunset blvd' &&
                a.city.toLowerCase().contains('thiruvananthapuram corp')));

        final regNorm = regAddress.addressLine.trim().toLowerCase();
        final matchIndex = list.indexWhere((a) =>
            a.addressLine.trim().toLowerCase() == regNorm ||
            a.id == regAddress!.id ||
            a.id.startsWith('reg_') ||
            a.id.startsWith('profile_addr_'));

        if (matchIndex != -1) {
          final matched = list[matchIndex];
          final updatedReg = matched.copyWith(
            type: matched.type.isNotEmpty ? matched.type : 'Home',
            addressLine: regAddress.addressLine,
            city: regAddress.city.isNotEmpty ? regAddress.city : matched.city,
            state: regAddress.state ?? matched.state,
            district: regAddress.district ?? matched.district,
            localBody: regAddress.localBody ?? matched.localBody,
            ward: regAddress.ward ?? matched.ward,
            pincode: regAddress.pincode.isNotEmpty
                ? regAddress.pincode
                : matched.pincode,
            isDefault: true,
          );
          list.removeAt(matchIndex);
          list = list.map((a) => a.copyWith(isDefault: false)).toList();
          list.insert(0, updatedReg);
        } else {
          list = list.map((a) => a.copyWith(isDefault: false)).toList();
          list.insert(0, regAddress);
        }

        final dedup = deduplicateAddresses(list);
        await saveAddresses(dedup, userId: uid);
        return dedup;
      }

      // 4. If no registration address, return existing list if any
      if (rawList != null && rawList.isNotEmpty) {
        return deduplicateAddresses(rawList);
      }

      // 5. Default seed if no addresses and no registration address configured
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
      await saveAddresses(defaultSeeds, userId: uid);
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

  /// Saves the complete list of addresses to SharedPreferences for the active user.
  static Future<void> saveAddresses(List<AddressModel> addresses, {String? userId}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final uid = await _resolveCurrentUserId(userId);
      final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());

      if (uid.isNotEmpty) {
        final userKey = _storageKeyForUser(uid);
        await sp.setString(userKey, encoded);
        await SpHelper.saveString(userKey, encoded);
      } else {
        await sp.setString(_kSavedAddressesKey, encoded);
        await SpHelper.saveString(_kSavedAddressesKey, encoded);
      }
    } catch (_) {}
  }

  /// Adds a new address or updates existing one by ID or addressLine.
  static Future<AddressModel> addAddress(AddressModel newAddress, {String? userId}) async {
    final currentList = await getSavedAddresses(userId: userId);
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
      await saveAddresses(updatedList, userId: userId);
      return resolvedAddress;
    } else {
      updatedList.add(finalAddress);
      await saveAddresses(updatedList, userId: userId);
      return finalAddress;
    }
  }

  /// Deletes an address by ID and updates default if necessary.
  static Future<void> deleteAddress(String id, {String? userId}) async {
    final currentList = await getSavedAddresses(userId: userId);
    final updatedList = List<AddressModel>.from(currentList);

    final index = updatedList.indexWhere((a) => a.id == id);
    if (index != -1) {
      final wasDefault = updatedList[index].isDefault;
      updatedList.removeAt(index);
      if (wasDefault && updatedList.isNotEmpty) {
        updatedList[0] = updatedList[0].copyWith(isDefault: true);
      }
      await saveAddresses(updatedList, userId: userId);
    }
  }

  /// Sets the address with the given ID as default.
  static Future<void> setDefaultAddress(String id, {String? userId}) async {
    final currentList = await getSavedAddresses(userId: userId);
    final updatedList = List<AddressModel>.from(currentList);

    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(
        isDefault: updatedList[i].id == id,
      );
    }
    await saveAddresses(updatedList, userId: userId);
  }
}
