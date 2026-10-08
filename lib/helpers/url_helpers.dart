import 'package:floret_app/config/app_config.dart';
import 'package:floret_app/utils/enums.dart';

class UrlHelpers {
  static EnumBuildEnvironment get server => AppConfig.server;

  static String get baseURL {
    return 'https://florettechuser.pythonanywhere.com/';
  }

  static String get key {
    return '';
  }

  static String get baseUrlApi {
    return 'https://florettechuser.pythonanywhere.com/api/';
  }
}
