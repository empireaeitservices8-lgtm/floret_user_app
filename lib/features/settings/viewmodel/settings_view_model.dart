import 'package:floret_app/providers/view_model.dart';
import '../model/settings_model.dart';
import '../repos/settings_repository.dart';

class SettingsViewModel extends ViewModel {
  final SettingsRepository _repository;

  SettingsViewModel({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository() {
    loadSettings();
  }

  NotificationPreferencesModel _preferences = const NotificationPreferencesModel();
  List<FaqItemModel> _faqs = [];

  NotificationPreferencesModel get preferences => _preferences;
  List<FaqItemModel> get faqs => _faqs;

  Future<void> loadSettings() async {
    showLoading();
    try {
      _preferences = await _repository.getNotificationPreferences();
      _faqs = await _repository.fetchFaqs();
      notifyListeners();
    } finally {
      hideLoading();
    }
  }

  void updatePush(bool val) {
    _preferences = _preferences.copyWith(pushNotifications: val);
    _repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  void updateEmail(bool val) {
    _preferences = _preferences.copyWith(emailNotifications: val);
    _repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  void updateSms(bool val) {
    _preferences = _preferences.copyWith(smsAlerts: val);
    _repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  void updatePromo(bool val) {
    _preferences = _preferences.copyWith(promotionalUpdates: val);
    _repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  Future<void> logout() async {
    showLoading();
    try {
      await _repository.logout();
    } finally {
      hideLoading();
    }
  }
}
