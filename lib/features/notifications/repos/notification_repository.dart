import 'package:floret_app/services/web_api_services.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final WebAPIService _webAPIService;

  NotificationRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<List<NotificationItemModel>> fetchNotifications() async {
    return [];
  }

  Future<bool> markAsRead(String id) async {
    return true;
  }
}
