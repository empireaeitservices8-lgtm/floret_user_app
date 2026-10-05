import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import '../model/settings_model.dart';

class SettingsRepository {
  final WebAPIService _webAPIService;

  SettingsRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<NotificationPreferencesModel> getNotificationPreferences() async {
    final push = await SpHelper.getBoolean('pref_push') ?? true;
    final email = await SpHelper.getBoolean('pref_email') ?? true;
    final sms = await SpHelper.getBoolean('pref_sms') ?? false;
    final promo = await SpHelper.getBoolean('pref_promo') ?? false;

    return NotificationPreferencesModel(
      pushNotifications: push,
      emailNotifications: email,
      smsAlerts: sms,
      promotionalUpdates: promo,
    );
  }

  Future<bool> saveNotificationPreferences(NotificationPreferencesModel prefs) async {
    await SpHelper.saveBoolean('pref_push', prefs.pushNotifications);
    await SpHelper.saveBoolean('pref_email', prefs.emailNotifications);
    await SpHelper.saveBoolean('pref_sms', prefs.smsAlerts);
    await SpHelper.saveBoolean('pref_promo', prefs.promotionalUpdates);
    return true;
  }

  Future<List<FaqItemModel>> fetchFaqs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      FaqItemModel(
        question: 'What items are accepted for collection?',
        answer: 'We accept dry recyclables including plastics, paper, cardboard, glass, metals, and e-waste.',
      ),
      FaqItemModel(
        question: 'How do I reschedule a collection pickup?',
        answer: 'Navigate to Order History, tap on your active order, and select "Reschedule Pickup".',
      ),
      FaqItemModel(
        question: 'How are Eco Rewards calculated?',
        answer: 'Points are awarded based on weight and cleanliness of your segregated dry waste.',
      ),
    ];
  }

  Future<void> logout() async {
    await SpHelper.clearAll();
  }
}
