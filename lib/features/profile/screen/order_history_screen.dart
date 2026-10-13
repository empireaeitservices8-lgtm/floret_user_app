import 'package:flutter/material.dart';
import '../../home/screen/home_screen.dart';
import '../../settings/screen/settings_screen.dart';
import 'profile_screen.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../model/order_model.dart';
import '../../booking/screen/receipt_ticket_screen.dart';
import 'pickup_bill_bottom_sheet.dart';

class OrderHistoryScreen extends StatefulWidget {
  static const String routeName = '/order_history';

  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All',
    'Completed',
    'Pending',
    'Reschedule',
    'Cancelled',
  ];

  void _onBottomNavTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
    } else if (index == 2) {
      Navigator.popUntil(
        context,
        ModalRoute.withName(ProfileScreen.routeName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      body: Column(
        children: [
          // 1. Dark-to-Green Gradient Top Bar
          _buildHeader(),

          const SizedBox(height: 16),

          // 2. Horizontal Filter Pills (All, Completed, Pending, Reschedule)
          _buildFilterTabs(),

          // 3. Orders list, or empty state when there are none
          Expanded(
            child: ValueListenableBuilder<List<OrderModel>>(
              valueListenable: OrderStore.instance.orders,
              builder: (context, orders, _) {
                final filtered = _filterOrders(orders);
                if (filtered.isEmpty) return _buildEmptyState();
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _buildOrderCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // 1. Top Bar Widget with Gradient and Circular Back Button
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0F1E2E),
            Color(0xFF13362E),
            Color(0xFF186A3E),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              // Circular translucent back button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Title (centered)
              const Expanded(
                child: Center(
                  child: Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              // Balance spacing for centering
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Filter Pills
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  // Selected: black/dark background. Unselected: white background
                  color: isSelected ? const Color(0xFF182236) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(
                        alpha: isSelected ? 0.08 : 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 14.5,
                    // Selected: white font. Unselected: black/dark font
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF182236),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 3. Center Empty State: "No orders found"
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFB0B7C3).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.inbox_rounded,
                  color: Color(0xFF94A3B8),
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Schedule a pickup to see your orders here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B7C3),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    switch (_selectedFilterIndex) {
      case 1:
        return orders.where((o) => o.status == OrderStatus.completed).toList();
      case 2:
        return orders.where((o) => o.status == OrderStatus.pending).toList();
      case 3:
        return orders
            .where((o) => o.status == OrderStatus.reschedule)
            .toList();
      case 4:
        return orders
            .where((o) => o.status == OrderStatus.cancelled)
            .toList();
      default:
        return orders;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  String _formatLongDate(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${days[d.weekday - 1]}, ${_formatDate(d)}';
  }

  // Order card matching design
  Widget _buildOrderCard(OrderModel order) {
    final statusColor = order.status == OrderStatus.completed
        ? const Color(0xFF16A34A)
        : order.status == OrderStatus.reschedule
            ? const Color(0xFF2563EB)
            : order.status == OrderStatus.cancelled
                ? const Color(0xFFDC2626)
                : const Color(0xFFF59E0B);
    final statusLabel = order.status == OrderStatus.completed
        ? 'COMPLETED'
        : order.status == OrderStatus.reschedule
            ? 'RESCHEDULED'
            : order.status == OrderStatus.cancelled
                ? 'CANCELLED'
                : 'PENDING';
    final statusIcon = order.status == OrderStatus.completed
        ? Icons.check_circle_outline_rounded
        : order.status == OrderStatus.reschedule
            ? Icons.event_repeat_rounded
            : order.status == OrderStatus.cancelled
                ? Icons.cancel_outlined
                : Icons.hourglass_bottom_rounded;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openReceiptTicket(order),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEF0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    color: Color(0xFF1E242F),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.wasteType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E242F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.bookingId,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(order.pickupDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E242F),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: Color(0xFFF1F5F9)),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: Color(0xFFF1F5F9)),
                if (order.status != OrderStatus.completed &&
                    order.status != OrderStatus.cancelled) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        label: 'Cancel',
                        icon: Icons.cancel_outlined,
                        textColor: const Color(0xFFDC2626),
                        borderColor: const Color(0xFFFCA5A5),
                        onTap: () => _confirmCancel(order),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        label: 'Reschedule',
                        icon: Icons.edit_calendar_outlined,
                        textColor: const Color(0xFF1E242F),
                        borderColor: const Color(0xFF9CA3AF),
                        onTap: () => _reschedule(order),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      label: 'Track Order',
                      icon: Icons.map_rounded,
                      textColor: Colors.white,
                      backgroundColor: const Color(0xFF1E293B),
                      borderColor: const Color(0xFF1E293B),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Tracking for ${order.bookingId} will be available once a collector is assigned.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      label: 'View Bill',
                      icon: Icons.receipt_long_outlined,
                      textColor: const Color(0xFF4B5563),
                      backgroundColor: const Color(0xFFF3F4F6),
                      borderColor: const Color(0xFFD1D5DB),
                      onTap: () => showPickupBillBottomSheet(context, order),
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

  void _openReceiptTicket(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptTicketScreen(
          bookingId: order.bookingId,
          date: _formatLongDate(order.pickupDate),
          wasteType: order.wasteType,
          pickupAddress: order.fullAddress,
          contact: order.contact,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color borderColor,
    Color backgroundColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Pickup'),
        content: Text('Are you sure you want to cancel ${order.bookingId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      OrderStore.instance.updateStatus(
          order.bookingId, OrderStatus.cancelled);
    }
  }

  Future<void> _reschedule(OrderModel order) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: order.pickupDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        order.pickupDate = picked;
      });
      OrderStore.instance.updateStatus(order.bookingId, OrderStatus.reschedule);
    }
  }

  // 4. Bottom Navigation Bar matching Profile
  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 2,
      onTap: (index) => _onBottomNavTapped(context, index),
    );
  }
}
