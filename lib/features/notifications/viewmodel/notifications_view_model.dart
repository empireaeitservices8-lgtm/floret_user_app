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
    _currentUserId = OrderStore.instance.currentUserId;
    loadNotifications();
    // Listen to OrderStore so new bookings auto-appear in notifications
    OrderStore.instance.orders.addListener(_onOrdersChanged);
  }

  int _selectedTabIndex = 0;
  final List<String> tabs = const ['All', 'Upcoming', 'Delivered'];
  List<NotificationItemModel> _notifications = [];
  String _currentUserId = '';

  int get selectedTabIndex => _selectedTabIndex;
  List<NotificationItemModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnreadNotifications => unreadCount > 0;

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

  final Set<String> _readIds = {};

  void _onOrdersChanged() {
    final newUserId = OrderStore.instance.currentUserId;
    if (_currentUserId != newUserId) {
      _currentUserId = newUserId;
      loadNotifications();
      return;
    }
    _buildNotificationsFromOrders(_readIds);
    notifyListeners();
  }

  /// Converts each booked order into a [NotificationItemModel].
  /// pending/reschedule → category 'Upcoming'
  /// completed          → category 'Delivered'
  void _buildNotificationsFromOrders([Set<String>? persistedReadIds]) {
    final currentUserId = OrderStore.instance.currentUserId.isNotEmpty
        ? OrderStore.instance.currentUserId
        : _currentUserId;
    final allOrders = OrderStore.instance.orders.value;

    // Isolate notifications by authenticated user
    final orders = allOrders.where((order) {
      if (currentUserId.isNotEmpty) {
        return order.userId == currentUserId;
      }
      return order.userId == null;
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
          : order.status == OrderStatus.reschedule
              ? 'Pickup Rescheduled • ${order.bookingId}'
              : isUpcoming
                  ? 'Pickup Scheduled • ${order.bookingId}'
                  : 'Pickup Delivered • ${order.bookingId}';

      final description = isCancelled
          ? 'Your ${order.wasteType} pickup scheduled for $scheduledDateStr was cancelled.'
          : order.status == OrderStatus.reschedule
              ? 'Your ${order.wasteType} pickup has been rescheduled for $scheduledDateStr. Address: ${order.address}.'
              : isUpcoming
                  ? 'Your ${order.wasteType} pickup is scheduled for $scheduledDateStr. '
                    'Address: ${order.address}.'
                  : 'Your ${order.wasteType} pickup on $actualDateStr has been delivered. '
                    'Thank you for recycling!';

      final isMarkedRead = (persistedReadIds != null &&
              persistedReadIds.contains(order.bookingId)) ||
          _readIds.contains(order.bookingId);

      return NotificationItemModel(
        id: order.bookingId,
        title: title,
        description: description,
        time: actualDateStr,
        category: category,
        isRead: isMarkedRead,
        userId: order.userId,
      );
    }).toList();
  }

  Future<void> loadNotifications() async {
    showLoading();
    try {
      _currentUserId = OrderStore.instance.currentUserId.isNotEmpty
          ? OrderStore.instance.currentUserId
          : (await SpHelper.getString(sp_keys.keyUserId) ?? '');
      _readIds.clear();
      final persisted = await _repository.getReadNotificationIds();
      _readIds.addAll(persisted);

      // Build from local OrderStore (real bookings for authenticated user)
      _buildNotificationsFromOrders(_readIds);

      // Optionally merge with remote notifications if provided
      final remote = await _repository.fetchNotifications();
      if (remote.isNotEmpty) {
        final uid = _currentUserId;
        final userRemote = remote.where((n) {
          if (uid.isNotEmpty) {
            return n.userId == uid;
          }
          return false;
        }).map((n) {
          final isRead = _readIds.contains(n.id) || n.isRead;
          return n.copyWith(isRead: isRead);
        }).toList();
        _notifications = [..._notifications, ...userRemote];
      }
    } finally {
      hideLoading();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    _readIds.add(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
    try {
      await _repository.markAsRead(id);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [NOTIFICATIONS VM] Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;
    final allIds = _notifications.map((n) => n.id).toList();
    _readIds.addAll(allIds);

    _notifications = _notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    notifyListeners();

    try {
      await _repository.markAllAsRead(allIds);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [NOTIFICATIONS VM] Error marking all as read: $e');
    }
  }

  @override
  void dispose() {
    OrderStore.instance.orders.removeListener(_onOrdersChanged);
    super.dispose();
  }
}
