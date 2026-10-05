import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'top_up_bottom_sheet.dart';
import 'auto_top_up_bottom_sheet.dart';
import 'e_mandate_bottom_sheet.dart';
import 'redeem_rewards_bottom_sheet.dart';

class WalletScreen extends StatefulWidget {
  static const String routeName = '/wallet';
  final int initialPoints;

  const WalletScreen({super.key, this.initialPoints = 0});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedActivityTab = 0; // 0: Wallet Activity, 1: Eco Rewards
  bool _isAutoTopUpActive = false;
  double _autoTopUpThreshold = 100.0;
  double _autoTopUpAmount = 500.0;
  double _walletBalance = 0.0;
  late int _safaiPoints;

  @override
  void initState() {
    super.initState();
    _safaiPoints = widget.initialPoints;
  }

  @override
  void didUpdateWidget(WalletScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPoints != widget.initialPoints) {
      _safaiPoints = widget.initialPoints;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF1E242F),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Floret Wallet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E242F),
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // 1. Green Gradient Wallet Balance Card
            _buildWalletBalanceCard(),

            const SizedBox(height: 16),

            // 2. 3 Action Cards (Top Up, Auto Top-Up, E-Mandate)
            _buildActionCards(),

            const SizedBox(height: 18),

            // 3. Tab Switcher (Wallet Activity / Eco Rewards)
            _buildTabSwitcher(),

            const SizedBox(height: 16),

            // 4. Activity Content (Wallet Activity or Eco Rewards)
            _selectedActivityTab == 0
                ? _buildWalletActivityView()
                : _buildEcoRewardsView(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 1. Wallet Balance Card with Green Gradient
  Widget _buildWalletBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F7A47),
            Color(0xFF0EA358),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F7A47).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              children: [
                // Top Row: WALLETS BALANCE + Auto Top-Up OFF pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WALLETS BALANCE',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.6,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final res = await AutoTopUpBottomSheet.show(
                          context,
                          isEnabled: _isAutoTopUpActive,
                          threshold: _autoTopUpThreshold,
                          reloadAmount: _autoTopUpAmount,
                        );
                        if (res != null) {
                          setState(() {
                            _isAutoTopUpActive = res.isEnabled;
                            _autoTopUpThreshold = res.threshold;
                            _autoTopUpAmount = res.reloadAmount;
                            if (_isAutoTopUpActive) {
                              _walletBalance = 1500.0;
                            }
                          });
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isAutoTopUpActive
                                  ? Icons.sync_rounded
                                  : Icons.power_settings_new_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isAutoTopUpActive
                                  ? 'Auto Top-Up ON'
                                  : 'Auto Top-Up OFF',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Middle Row: ₹ 0.00 / Dynamic balance + Top Up Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹ ${_walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => TopUpBottomSheet.show(context),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Color(0xFF1E242F),
                      ),
                      label: const Text(
                        'Top Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242F),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E242F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Inner Capsule: E-Mandate Pending
          GestureDetector(
            onTap: () => EMandateBottomSheet.show(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFFD4E157),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'E-Mandate Pending',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Authorize >',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  // 2. 3 Action Cards (Top Up, Auto Top-Up, E-Mandate)
  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSingleActionCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF1E293B),
            iconBgColor: const Color(0xFFE2E8F0),
            title: 'Top Up',
            subtitle: 'Add Funds',
            onTap: () => TopUpBottomSheet.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleActionCard(
            icon: Icons.sync_rounded,
            iconColor: const Color(0xFFD97706),
            iconBgColor: const Color(0xFFFEF3C7),
            title: 'Auto Top-Up',
            subtitle: _isAutoTopUpActive
                ? '₹${_autoTopUpThreshold.toInt()} limit'
                : 'Configure',
            onTap: () async {
              final res = await AutoTopUpBottomSheet.show(
                context,
                isEnabled: _isAutoTopUpActive,
                threshold: _autoTopUpThreshold,
                reloadAmount: _autoTopUpAmount,
              );
              if (res != null) {
                setState(() {
                  _isAutoTopUpActive = res.isEnabled;
                  _autoTopUpThreshold = res.threshold;
                  _autoTopUpAmount = res.reloadAmount;
                  if (_isAutoTopUpActive) {
                    _walletBalance = 1500.0;
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleActionCard(
            icon: Icons.shield_rounded,
            iconColor: const Color(0xFF9333EA),
            iconBgColor: const Color(0xFFF3E8FF),
            title: 'E-Mandate',
            subtitle: 'Authorize',
            onTap: () => EMandateBottomSheet.show(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF0F3F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242F),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8C95A6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 3. Tab Switcher (Segmented Control: Wallet Activity / Eco Rewards)
  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedActivityTab = 0;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedActivityTab == 0
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedActivityTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Wallet Activity',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: _selectedActivityTab == 0
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedActivityTab == 0
                        ? const Color(0xFF1E242F)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedActivityTab = 1;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedActivityTab == 1
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedActivityTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Eco Rewards',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: _selectedActivityTab == 1
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedActivityTab == 1
                        ? const Color(0xFF1E242F)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4A. View for "Wallet Activity" (Image 1 & Updated Activity)
  Widget _buildWalletActivityView() {
    if (_isAutoTopUpActive || _walletBalance > 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.south_west_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual wallet top-up',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '03 Oct 2026, 04:13 PM',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '+₹1500.00',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'razorpay • COMPLETED',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF0F3F6),
          width: 1,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dotted Clock Icon
          const _DottedClockWidget(),

          const SizedBox(height: 18),

          const Text(
            'No wallet transactions found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              TopUpBottomSheet.show(context);
            },
            icon: const Icon(
              Icons.add_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              'Make a Top-Up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF182236),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4B. View for "Eco Rewards" (Image 2)
  Widget _buildEcoRewardsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Available Safai Points Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF0F3F6),
              width: 1,
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
            children: [
              // Top Row: Available Safai Points & 0 pts + Redeem Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Safai Points',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8C95A6),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$_safaiPoints pts',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E242F),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_safaiPoints < 100) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFFFF5252),
                            behavior: SnackBarBehavior.fixed,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            content: Text(
                              'Insufficient points! You need at least 100 eco-points to redeem.',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        RedeemRewardsBottomSheet.show(context);
                      }
                    },
                    icon: const Icon(
                      Icons.stars_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Redeem',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF182236),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // 3 Stats Row (Earned, Redeemed, Expired)
              Row(
                children: [
                  Expanded(
                    child: _buildRewardStatItem(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: 'Earned',
                      value: '0',
                      valueColor: const Color(0xFF10B981),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFF1F5F9),
                  ),
                  Expanded(
                    child: _buildRewardStatItem(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xFFD97706),
                      label: 'Redeemed',
                      value: '0',
                      valueColor: const Color(0xFFD97706),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFF1F5F9),
                  ),
                  Expanded(
                    child: _buildRewardStatItem(
                      icon: Icons.block_rounded,
                      iconColor: const Color(0xFFEF4444),
                      label: 'Expired',
                      value: '0',
                      valueColor: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Safai Points Rule Green Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD1F2DE),
              width: 1,
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Color(0xFF166534),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Safai Points Rule: Earn 1 point per ₹100 spent • 1 Point = ₹0.25 redemption value',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. Section Title: Reward Points Transaction History
        const Text(
          'Reward Points Transaction History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 12),

        // 4. Empty Reward Points History Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF0F3F6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'No reward points history found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8C95A6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// Widget representing the dotted circle with clock hands matching image 2
class _DottedClockWidget extends StatelessWidget {
  const _DottedClockWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(
        painter: _DottedCirclePainter(),
        child: const Center(
          child: Icon(
            Icons.access_time_rounded,
            size: 24,
            color: Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dotCount = 12;
    const dotRadius = 1.6;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi) / dotCount;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
