import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/screen/safai_logo_widget.dart';
import '../../settings/screen/settings_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../notifications/screen/notifications_screen.dart';
import '../../wallet/screen/wallet_screen.dart';
import '../viewmodel/home_view_model.dart';
import 'select_pickup_bottom_sheet.dart';
import '../../../widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  final bool showBottomNav;

  const HomeScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F8FA),
              body: SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: () => vm.loadHomeData(isRefresh: true),
                  color: const Color(0xFFC5A059),
                  backgroundColor: const Color(0xFF0F172A),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Dark Midnight Blue Header
                        _buildHeader(vm),

                        const SizedBox(height: 16),

                        // 2. Metrics (Pending Bills & Active Pickups)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'Pending Bills',
                                  count: '${vm.pendingBillsCount}',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildMetricCard(
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Active Pickups',
                                  count: '${vm.activePickupsCount}',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3. Waste Categories Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Waste Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E242F),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCategoryCard(
                                      title: 'Sanitary Waste',
                                      subtitle: 'Diapers, hygiene',
                                      icon: Icons.baby_changing_station_rounded,
                                      iconColor: const Color(0xFFE11D48),
                                      iconBgColor: const Color(0xFFFFECEF),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCategoryCard(
                                      title: 'Scrap Waste',
                                      subtitle: 'Paper, metal, plast...',
                                      icon: Icons.recycling_rounded,
                                      iconColor: const Color(0xFF0284C7),
                                      iconBgColor: const Color(0xFFE0F2FE),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildCategoryCard(
                                      title: 'Glass Waste',
                                      subtitle: 'Bottles, jars, shards',
                                      icon: Icons.local_drink_rounded,
                                      iconColor: const Color(0xFF0D9488),
                                      iconBgColor: const Color(0xFFE6F7F0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 4. Eco Pickup Booking Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildEcoPickupBanner(),
                        ),

                        const SizedBox(height: 24),

                        // 5. Climate Impact Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Climate Impact',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E242F),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildImpactCard(
                                      badgeText: 'co2',
                                      isBadgePill: true,
                                      title: 'CO2 Reduced',
                                      value: '0.0 kg',
                                      gradientColors: const [
                                        Color(0xFF0F9B58),
                                        Color(0xFF0A753F),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _buildImpactCard(
                                      badgeText: r'$',
                                      isBadgePill: false,
                                      title: 'Eco Points',
                                      value: '${vm.ecoPoints} Pts',
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, WalletScreen.routeName);
                                      },
                                      gradientColors: const [
                                        Color(0xFFF59E0B),
                                        Color(0xFFEA580C),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 6. Recycle Progress Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildRecycleProgressCard(),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
            ),
          );
        },
      ),
    );
  }

  // 1. Dark Header Widget
  Widget _buildHeader(HomeViewModel vm) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 14,
        18,
        20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // User avatar + Greeting + Notification Bell
          Row(
            children: [
              // Avatar with Safai Logo
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SafaiLogoWidget(height: 28),
                ),
              ),
              const SizedBox(width: 14),
              // Greeting and Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.timeBasedGreeting,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Welcome back, ${vm.displayName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Notification Bell with Badge
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, NotificationsScreen.routeName);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      Positioned(
                        top: 1,
                        right: 2,
                        child: Container(
                          width: 8.5,
                          height: 8.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFA500),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Sustainability Score Card
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, WalletScreen.routeName);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2436),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF28364F),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Leaf Icon Circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF243046),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: Color(0xFFC5A059),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Sustainability Score',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF383528),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${vm.ecoPoints} pts',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFC5A059),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Level 1',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC5A059),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress bar capsule
                        Container(
                          width: 38,
                          height: 5.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF343E51),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 14,
                            height: 5.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A059),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Earn eco-points on pickups to level up! 🌱',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Metrics Card (Pending Bills / Active Pickups)
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF5A6275),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E242F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Category Card (Sanitary, Scrap, Glass)
  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBgColor,
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
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Eco Pickup Banner
  Widget _buildEcoPickupBanner() {
    return GestureDetector(
      onTap: () => SelectPickupBottomSheet.show(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2B44),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFFC8A246),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eco Pickup\nBooking',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Select from Residential or Commercial & Bulk pickup types.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8C97AC),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => SelectPickupBottomSheet.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29B38),
                foregroundColor: const Color(0xFF1E1E1E),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Impact Card (CO2 Reduced / Eco Points)
  Widget _buildImpactCard({
    required String badgeText,
    required bool isBadgePill,
    required String title,
    required String value,
    VoidCallback? onTap,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isBadgePill
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Recycle Progress Card
  Widget _buildRecycleProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + 0% Done Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recycle Progress',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '0% Done',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Target: 50kg monthly recycler',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 18),

          // Monthly Total
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Total',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E242F),
                ),
              ),
              Text(
                '0.0 kg / 50 kg',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal Progress Capsule
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 38,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF5A4D3B),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom indicators
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live sync active',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Keep going!',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 7. Bottom Navigation Bar
  Widget _buildBottomNav() {
    return AppBottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        if (index == 0) {
          setState(() {
            _selectedNavIndex = 0;
          });
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: const RouteSettings(name: SettingsScreen.routeName),
              pageBuilder: (_, __, ___) => const SettingsScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 260),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: const RouteSettings(name: ProfileScreen.routeName),
              pageBuilder: (_, __, ___) => const ProfileScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 260),
            ),
          );
        }
      },
    );
  }
}
