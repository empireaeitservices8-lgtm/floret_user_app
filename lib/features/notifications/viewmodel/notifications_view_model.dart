import 'package:floret_app/providers/view_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
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
    final currentUserId = OrderStore.instance.currentUserId;
    final allOrders = OrderStore.instance.orders.value;

    // Isolate notifications by authenticated user
    final orders = allOrders.where((order) {
      if (currentUserId.isNotEmpty) {
        return order.userId == currentUserId;
      }
      return true;
    }).toList();

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String formatDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';

    _notifications = orders.map((order) {
      final isCancelled = order.status == OrderStatus.cancelled;
      final isUpcoming = !isCancelled &&
          (order.status == OrderStatus.pending ||
              order.status == OrderStatus.reschedule);
      final isDelivered =
          !isCancelled && !isUpcoming && order.status == OrderStatus.completed;

      final category = isCancelled
          ? 'Cancelled'
          : isUpcoming
              ? 'Upcoming'
              : 'Delivered';

      // Scheduled pickup date (preserved for upcoming and cancelled)
      final scheduledDateStr = formatDate(order.pickupDate);

      // Actual completion date (for delivered notifications, use actual completedDate if available; safely fall back to pickupDate)
      final actualDate = isDelivered
          ? (order.completedDate ?? order.pickupDate)
          : order.pickupDate;
      final actualDateStr = formatDate(actualDate);

      final title = isCancelled
          ? 'Pickup Cancelled • ${order.bookingId}'
          : isUpcoming
              ? 'Pickup Scheduled • ${order.bookingId}'
              : 'Pickup Delivered • ${order.bookingId}';

      final description = isCancelled
          ? 'Your ${order.wasteType} pickup scheduled for $scheduledDateStr was cancelled.'
          : isUpcoming
              ? 'Your ${order.wasteType} pickup is scheduled for $scheduledDateStr. '
                'Address: ${order.address}.'
              : 'Your ${order.wasteType} pickup on $actualDateStr has been delivered. '
                'Thank you for recycling!';

      return NotificationItemModel(
        id: order.bookingId,
        title: title,
        description: description,
        time: actualDateStr,
        category: category,
        isRead: order.status == OrderStatus.completed ||
            order.status == OrderStatus.cancelled,
        userId: order.userId,
      );
    }).toList();
  }

  Future<void> loadNotifications() async {
    showLoading();
    try {
      // Build from local OrderStore (real bookings for authenticated user)
      _buildNotificationsFromOrders();

      // Optionally merge with remote notifications
      final remote = await _repository.fetchNotifications();
      if (remote.isNotEmpty) {
        final uid = OrderStore.instance.currentUserId.isNotEmpty
            ? OrderStore.instance.currentUserId
            : (await SpHelper.getString(sp_keys.keyUserId) ?? '');
        final userRemote = remote.where((n) {
          if (uid.isNotEmpty) {
            return n.userId == uid;
          }
          return true;
        }).toList();
        _notifications = [..._notifications, ...userRemote];
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
        userId: old.userId,
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
