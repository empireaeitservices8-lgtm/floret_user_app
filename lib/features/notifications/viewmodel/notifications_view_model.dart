import 'package:floret_app/providers/view_model.dart';
import '../model/notification_model.dart';
import '../repos/notification_repository.dart';
import '../../profile/model/order_model.dart';

class NotificationsViewModel extends ViewModel {
  final NotificationRepository _repository;

  NotificationsViewModel({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository() {
    loadNotifications();
    // Listen to OrderStore so new bookings auto-appear in notifications
    OrderStore.instance.orders.addListener(_onOrdersChanged);
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

  void _onOrdersChanged() {
    _buildNotificationsFromOrders();
    notifyListeners();
  }

  /// Converts each booked order into a [NotificationItemModel].
  /// pending  → category 'Upcoming'
  /// completed → category 'Delivered'
  void _buildNotificationsFromOrders() {
    final orders = OrderStore.instance.orders.value;
    _notifications = orders.map((order) {
      final isCancelled = order.status == OrderStatus.cancelled;
      final isUpcoming = !isCancelled &&
          (order.status == OrderStatus.pending ||
              order.status == OrderStatus.reschedule);
      final category = isCancelled
          ? 'Cancelled'
          : isUpcoming
              ? 'Upcoming'
              : 'Delivered';

      // Format date: dd MMM yyyy
      final d = order.pickupDate;
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final dateStr =
          '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';

      final title = isCancelled
          ? 'Pickup Cancelled • ${order.bookingId}'
          : isUpcoming
              ? 'Pickup Scheduled • ${order.bookingId}'
              : 'Pickup Delivered • ${order.bookingId}';

      final description = isCancelled
          ? 'Your ${order.wasteType} pickup scheduled for $dateStr was cancelled.'
          : isUpcoming
              ? 'Your ${order.wasteType} pickup is scheduled for $dateStr. '
                'Address: ${order.address}.'
              : 'Your ${order.wasteType} pickup on $dateStr has been delivered. '
                'Thank you for recycling!';

      return NotificationItemModel(
        id: order.bookingId,
        title: title,
        description: description,
        time: dateStr,
        category: category,
        isRead: order.status == OrderStatus.completed ||
            order.status == OrderStatus.cancelled,
      );
    }).toList();
  }

  Future<void> loadNotifications() async {
    showLoading();
    try {
      // Build from local OrderStore (real bookings)
      _buildNotificationsFromOrders();
      // Optionally merge with remote notifications
      final remote = await _repository.fetchNotifications();
      if (remote.isNotEmpty) {
        _notifications = [..._notifications, ...remote];
      }
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

  @override
  void dispose() {
    OrderStore.instance.orders.removeListener(_onOrdersChanged);
    super.dispose();
  }
}
