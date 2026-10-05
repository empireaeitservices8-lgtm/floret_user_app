import 'package:flutter/material.dart';
import '../../home/screen/home_screen.dart';
import '../../settings/screen/settings_screen.dart';
import 'profile_screen.dart';
import '../../../widgets/app_bottom_nav_bar.dart';

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

          // 3. Center Empty State: "No orders found"
          Expanded(
            child: _buildEmptyState(),
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

  // 4. Bottom Navigation Bar matching Profile
  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 2,
      onTap: (index) => _onBottomNavTapped(context, index),
    );
  }
}
