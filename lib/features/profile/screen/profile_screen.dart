import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../auth/screen/safai_logo_widget.dart';
import '../../home/screen/home_screen.dart';
import '../../settings/screen/settings_screen.dart';
import '../../wallet/screen/wallet_screen.dart';
import 'order_history_screen.dart';
import 'my_account_screen.dart';
import 'contact_support_screen.dart';
import '../../../widgets/app_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';
  final bool showBottomNav;

  const ProfileScreen({
    super.key,
    this.showBottomNav = true,
  });

  void _onBottomNavTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          settings: const RouteSettings(name: HomeScreen.routeName),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 260),
        ),
      );
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
      // Already on profile
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    if (profileVm.profile == null &&
        !profileVm.isLoading &&
        profileVm.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<ProfileViewModel>().getProfile();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dark Midnight Blue Header
              _buildHeader(),

              const SizedBox(height: 24),

              // 2. Section: MY ACTIVITY & REWARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MY ACTIVITY & REWARDS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF717D96),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildActionItem(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF059669),
                        iconBgColor: const Color(0xFFE6F7F0),
                        title: 'Floret Wallet',
                        subtitle: 'Check points and earned bags',
                        onTap: () {
                          Navigator.pushNamed(context, WalletScreen.routeName);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Section: SUPPORT & ACCOUNT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SUPPORT & ACCOUNT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF717D96),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActionItem(
                            icon: Icons.history_rounded,
                            iconColor: const Color(0xFF0284C7),
                            iconBgColor: const Color(0xFFE0F2FE),
                            title: 'Order History',
                            subtitle:
                                'Track collection logs, view invoices & pay bills',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                OrderHistoryScreen.routeName,
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                            indent: 68,
                            endIndent: 16,
                          ),
                          _buildActionItem(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF0F766E),
                            iconBgColor: const Color(0xFFE6F4EA),
                            title: 'Account',
                            subtitle:
                                'View and edit your personal profile details',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                MyAccountScreen.routeName,
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                            indent: 68,
                            endIndent: 16,
                          ),
                          _buildActionItem(
                            icon: Icons.call_outlined,
                            iconColor: const Color(0xFFEA580C),
                            iconBgColor: const Color(0xFFFFF3E0),
                            title: 'Contact Us',
                            subtitle:
                                'Get in touch with customer care or leave feedback',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ContactSupportScreen.routeName,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // 4. Bottom Branding
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Safai 365',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E242F),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Powered by Floret Technologies',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF757D8A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context) : null,
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning 🌅';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening 🌆';
    } else {
      return 'Good night 🌙';
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 50, 18, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1527),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // User Row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SafaiLogoWidget(height: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Consumer<ProfileViewModel>(
                      builder: (context, vm, child) {
                        final displayName = vm.profile?.firstName ??
                            vm.profile?.fullName ??
                            '';
                        return Text(
                          displayName.isNotEmpty ? displayName : 'My Profile',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2E3E58),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3-Column Metrics Card (Carbon Saved, Points, Pickups)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2438),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF28364F),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Col 1: Carbon Saved
                Expanded(
                  child: _buildMetricColumn(
                    icon: Icons.forest_rounded,
                    iconColor: const Color(0xFF4ADE80),
                    value: '0.0 kg',
                    label: 'Carbon Saved',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFF2E3D56),
                ),
                // Col 2: Points
                Expanded(
                  child: _buildMetricColumn(
                    icon: Icons.stars_rounded,
                    iconColor: const Color(0xFFFBBF24),
                    value: '0 pts',
                    label: 'Points',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFF2E3D56),
                ),
                // Col 3: Pickups
                Expanded(
                  child: _buildMetricColumn(
                    icon: Icons.local_shipping_rounded,
                    iconColor: const Color(0xFF60A5FA),
                    value: '0',
                    label: 'Pickups',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8C96A6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0B7C3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNavigationBar(
      currentIndex: 2,
      onTap: (index) => _onBottomNavTapped(context, index),
    );
  }
}
