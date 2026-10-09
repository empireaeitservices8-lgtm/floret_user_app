import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import '../model/splash_model.dart';

class SplashRepository {
  final WebAPIService _webAPIService;

  SplashRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<SplashConfigModel> checkAuthStatus() async {
    final spToken = await SpHelper.getString(sp_keys.keyToken);
    final spTokenAlt = await SpHelper.getString('token');
    final prefs = await SharedPreferences.getInstance();
    final prefKeyToken = prefs.getString(sp_keys.keyToken);
    final prefToken = prefs.getString('token');

    final token = (spToken != null && spToken.trim().isNotEmpty)
        ? spToken.trim()
        : (spTokenAlt != null && spTokenAlt.trim().isNotEmpty)
            ? spTokenAlt.trim()
            : (prefKeyToken != null && prefKeyToken.trim().isNotEmpty)
                ? prefKeyToken.trim()
                : (prefToken != null && prefToken.trim().isNotEmpty)
                    ? prefToken.trim()
                    : null;

    final isAuth = token != null && token.isNotEmpty;
    if (isAuth) {
      await _webAPIService.initTokenToHeader();
    }
    return SplashConfigModel(
      isAuthenticated: isAuth,
      appVersion: '1.0.0+1',
    );
  }
}
