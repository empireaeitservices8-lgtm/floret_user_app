import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/notification_model.dart';
import '../viewmodel/notifications_view_model.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  final NotificationsViewModel? viewModel;

  const NotificationsScreen({super.key, this.viewModel});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsViewModel? _viewModel;
  bool _ownsViewModel = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      if (widget.viewModel != null) {
        _viewModel = widget.viewModel;
        _ownsViewModel = false;
      } else {
        try {
          _viewModel =
              Provider.of<NotificationsViewModel>(context, listen: false);
          _ownsViewModel = false;
        } catch (_) {
          _viewModel = NotificationsViewModel();
          _ownsViewModel = true;
        }
      }
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;
    return ChangeNotifierProvider<NotificationsViewModel>.value(
      value: vm,
      child: Consumer<NotificationsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFECE7F2),
            body: Column(
              children: [
                // 1. Dark Midnight Navy Header with Title and Evenly-Spaced Tabs
                _buildHeader(vm),

                // 2. Notification List or Empty State
                Expanded(
                  child: vm.filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationList(vm),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(NotificationsViewModel vm) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E2838),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar Row (Back Button + Title)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 24,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Tabs Row: All, Upcoming, Delivered (Distributed evenly in 3 columns)
            Row(
              children: List.generate(vm.tabs.length, (index) {
                final isSelected = vm.selectedTabIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      vm.setTabIndex(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            vm.tabs[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Active indicator underline
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          height: 3.5,
                          width: isSelected ? 32 : 0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bell with slash icon
            Icon(
              Icons.notifications_off_outlined,
              size: 72,
              color: const Color(0xFFA5A9B8).withValues(alpha: 0.85),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'No notifications found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A6275),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'Your notifications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(NotificationsViewModel vm) {
    final list = vm.filteredNotifications;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildNotificationCard(item, vm);
      },
    );
  }

  Widget _buildNotificationCard(
      NotificationItemModel item, NotificationsViewModel vm) {
    final isUpcoming = item.category == 'Upcoming';
    final iconColor =
        isUpcoming ? const Color(0xFF0284C7) : const Color(0xFF0F9B58);
    final iconBg = isUpcoming
        ? const Color(0xFFE0F2FE)
        : const Color(0xFFD1FAE5);
    final icon = isUpcoming
        ? Icons.local_shipping_outlined
        : Icons.check_circle_outline_rounded;

    return GestureDetector(
      onTap: () => vm.markAsRead(item.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: item.isRead
              ? null
              : Border.all(
                  color: iconColor.withValues(alpha: 0.35),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: item.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: const Color(0xFF1E2838),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Unread dot
                      if (!item.isRead)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: iconColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category chip + date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
