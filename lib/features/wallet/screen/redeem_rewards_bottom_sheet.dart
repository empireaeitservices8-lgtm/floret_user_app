import 'package:flutter/material.dart';

class RedeemRewardsBottomSheet extends StatefulWidget {
  final int availablePoints;
  final ValueChanged<int>? onConfirmRedeem;

  const RedeemRewardsBottomSheet({
    super.key,
    this.availablePoints = 0,
    this.onConfirmRedeem,
  });

  static Future<void> show(
    BuildContext context, {
    int availablePoints = 0,
    ValueChanged<int>? onConfirmRedeem,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RedeemRewardsBottomSheet(
        availablePoints: availablePoints,
        onConfirmRedeem: onConfirmRedeem,
      ),
    );
  }

  @override
  State<RedeemRewardsBottomSheet> createState() =>
      _RedeemRewardsBottomSheetState();
}

class _RedeemRewardsBottomSheetState extends State<RedeemRewardsBottomSheet> {
  int _selectedOptionIndex = 0; // 0: Wallet Credit, 1: Floret Reusable Bag
  late final TextEditingController _pointsController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(text: '100');
    _descriptionController =
        TextEditingController(text: 'Redeem for wallet credit');
    _pointsController.addListener(_onPointsChanged);
  }

  void _onPointsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _pointsController.removeListener(_onPointsChanged);
    _pointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
      if (index == 0) {
        _pointsController.text = '100';
        _descriptionController.text = 'Redeem for wallet credit';
      } else {
        _pointsController.text = '7';
        _descriptionController.text = 'Redeem for Floret Reusable Bag';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final pointsToRedeem = int.tryParse(_pointsController.text.trim()) ??
        (_selectedOptionIndex == 0 ? 100 : 7);
    final hasEnoughPoints =
        widget.availablePoints >= pointsToRedeem && widget.availablePoints > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFEA580C),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeem Reward Points',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E242F),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Convert reward points into wallet credit or rewards',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8C95A6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Option 1: Redeem for Wallet Credit
            _buildRewardOptionCard(
              index: 0,
              icon: Icons.account_balance_wallet_rounded,
              iconBgColor: const Color(0xFFE2E8F0),
              iconColor: const Color(0xFF1E293B),
              title: 'Redeem for Wallet Credit',
              subtitle: '100 points -> Direct wallet credit',
              pointsTag: '100 PTS',
            ),

            const SizedBox(height: 12),

            // Option 2: Floret Reusable Bag
            _buildRewardOptionCard(
              index: 1,
              icon: Icons.shopping_bag_rounded,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              title: 'Floret Reusable Bag',
              subtitle: '7 points -> Eco-friendly bag',
              pointsTag: '7 PTS',
            ),

            const SizedBox(height: 18),

            // Input 1: Points to Redeem
            TextFormField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E242F),
              ),
              decoration: InputDecoration(
                labelText: 'Points to Redeem',
                labelStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.stars_rounded,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E293B),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Input 2: Description
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E242F),
              ),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.article_rounded,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E293B),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Bottom Row: Available Points on left, Confirm Redeem on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Points',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8C95A6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.availablePoints} pts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: hasEnoughPoints
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final currentPointsToRedeem =
                          int.tryParse(_pointsController.text.trim()) ??
                              (_selectedOptionIndex == 0 ? 100 : 7);
                      if (widget.availablePoints < currentPointsToRedeem) {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFFF5252),
                            behavior: SnackBarBehavior.fixed,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            content: Text(
                              'Insufficient points! You need at least $currentPointsToRedeem eco-points to redeem.',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        widget.onConfirmRedeem?.call(currentPointsToRedeem);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirm Redeem',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardOptionCard({
    required int index,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String pointsTag,
  }) {
    final isSelected = _selectedOptionIndex == index;

    return GestureDetector(
      onTap: () => _selectOption(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8C95A6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pointsTag,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
