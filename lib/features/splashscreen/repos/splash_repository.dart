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
    final token = await SpHelper.getString(sp_keys.keyToken);
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
