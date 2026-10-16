import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpHelper {
  static SharedPreferences? _sp;
  static FlutterSecureStorage? _ss;

  static Future<SharedPreferences> getSP() async {
    final sp = _sp ?? await SharedPreferences.getInstance();
    _sp = sp;
    try {
      await sp.reload();
    } catch (_) {}
    return sp;
  }

  static FlutterSecureStorage _secureInstance() {
    return _ss ??= const FlutterSecureStorage();
  }

  ///
  ///## Save string in shared pref
  ///[key] name to save.
  ///can retreave saved string using [key]
  ///[secure] set true if you want to save string in secure storage.
  static Future<bool> saveString(String key, String value,
      {bool secure = false}) async {
    if (secure) {
      await _secureInstance().write(key: key, value: value);
      return true;
    }
    final sp = await getSP();
    return await sp.setString(key, value);
  }

  static Future<bool?> clearAll() async {
    final sp = await getSP();
    try {
      await _secureInstance().deleteAll();
    } catch (_) {}
    return await sp.clear();
  }

  ///
  ///## Read saved String
  ///[key] name given to save.
  ///[secure] true if String saved as secure.
  static Future<String?> getString(String key, {bool secure = false}) async {
    if (secure) {
      return await _secureInstance().read(key: key);
    }
    final sp = await getSP();
    return sp.getString(key);
  }

  ///
  ///## Read saved boolean
  ///[key] name given to save.
  static Future<bool?> getBoolean(String key) async {
    final sp = await getSP();
    return sp.getBool(key);
  }

  ///
  ///
  static Future<bool> saveBoolean(
    String key,
    bool value,
  ) async {
    final sp = await getSP();
    return await sp.setBool(key, value);
  }

  /// Saves the authenticated user's name across all standard preference keys
  static Future<void> saveUserName(String name) async {
    final clean = name.trim();
    if (clean.isEmpty ||
        clean.toLowerCase() == 'user' ||
        clean.toLowerCase() == 'null' ||
        clean.toLowerCase() == 'none') {
      return;
    }
    final keys = [
      'first_name',
      'username',
      'user_name',
      'home_username',
      'full_name',
      'KEY_USER_NAME',
    ];
    for (final k in keys) {
      await saveString(k, clean);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in keys) {
        await prefs.setString(k, clean);
      }
    } catch (_) {}
  }

  /// Retrieves the authenticated user's name from SharedPreferences
  static Future<String> getUserName() async {
    final keys = [
      'first_name',
      'KEY_USER_NAME',
      'user_name',
      'username',
      'home_username',
      'full_name',
    ];
    for (final k in keys) {
      final val = await getString(k);
      if (val != null && _isValidName(val)) return _formatName(val);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && _isValidName(val)) return _formatName(val);
      }
    } catch (_) {}
    return '';
  }

  static bool _isValidName(String? name) {
    if (name == null) return false;
    final t = name.trim();
    if (t.isEmpty) return false;
    final lower = t.toLowerCase();
    if (lower == 'user' || lower == 'null' || lower == 'none') return false;
    if (t.startsWith('+') || RegExp(r'^[0-9]+$').hasMatch(t)) return false;
    return true;
  }

  static String _formatName(String name) {
    final t = name.trim();
    if (t.length > 1) {
      return t[0].toUpperCase() + t.substring(1);
    }
    return t.toUpperCase();
  }

  /// Completely clears all user preferences, secure storage, and cached instances
  static Future<void> clearUserData() async {
    await clearAll();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}

extension RememberBool on bool {
  Future rememberMe(String name) async {
    await SpHelper.saveBoolean(name, this);
  }

  Future<bool> getMeBack(String name) async {
    return await SpHelper.getBoolean(name) ?? this;
  }
}

extension RememberString on String {
  rememberMe(String name) async {
    await SpHelper.saveString(name, this);
  }

  Future<String> getMeBack(String name) async {
    return await SpHelper.getString(name) ?? this;
  }
}
