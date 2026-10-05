import 'package:floret_app/providers/view_model.dart';
import '../model/splash_model.dart';
import '../repos/splash_repository.dart';

class SplashViewModel extends ViewModel {
  final SplashRepository _repository;

  SplashViewModel({SplashRepository? repository})
      : _repository = repository ?? SplashRepository();

  bool? _checkBoxVal;
  bool? _checkRadioButtonVal;
  SplashConfigModel? _config;

  bool? get checkBoxVal => _checkBoxVal;
  set checkBoxVal(bool? val) {
    _checkBoxVal = val;
    notifyListeners();
  }

  bool? get checkRadioButtonVal => _checkRadioButtonVal;
  set checkRadioButtonVal(bool? val) {
    _checkRadioButtonVal = val;
    notifyListeners();
  }

  SplashConfigModel? get config => _config;

  Future<SplashConfigModel> checkAuth() async {
    _config = await _repository.checkAuthStatus();
    notifyListeners();
    return _config!;
  }
}
