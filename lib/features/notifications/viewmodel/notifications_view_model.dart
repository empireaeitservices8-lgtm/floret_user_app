import 'package:floret_app/providers/view_model.dart';
import '../model/notification_model.dart';
import '../repos/notification_repository.dart';

class NotificationsViewModel extends ViewModel {
  final NotificationRepository _repository;

  NotificationsViewModel({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository() {
    loadNotifications();
  }

  int _selectedTabIndex = 0;
  final List<String> tabs = const ['All', 'Upcoming', 'Delivered'];
  List<NotificationItemModel> _notifications = [];

  int get selectedTabIndex => _selectedTabIndex;
  List<NotificationItemModel> get notifications => _notifications;

  List<NotificationItemModel> get filteredNotifications {
    if (_selectedTabIndex == 0) return _notifications;
    final tabName = tabs[_selectedTabIndex];
    return _notifications.where((n) => n.category == tabName).toList();
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    showLoading();
    try {
      _notifications = await _repository.fetchNotifications();
    } finally {
      hideLoading();
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final old = _notifications[idx];
      _notifications[idx] = NotificationItemModel(
        id: old.id,
        title: old.title,
        description: old.description,
        time: old.time,
        category: old.category,
        isRead: true,
      );
      notifyListeners();
    }
  }
}
