import 'package:flutter/material.dart';
import '../repos/wallet_repository.dart';

class EMandateBottomSheet extends StatefulWidget {
  const EMandateBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EMandateBottomSheet(),
    );
  }

  @override
  State<EMandateBottomSheet> createState() => _EMandateBottomSheetState();
}

class _EMandateBottomSheetState extends State<EMandateBottomSheet> {
  late final TextEditingController _mandateIdController;
  late final TextEditingController _paymentIdController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _mandateIdController = TextEditingController();
    _paymentIdController = TextEditingController();
  }

  @override
  void dispose() {
    _mandateIdController.dispose();
    _paymentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF9333EA),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authorize E-Mandate',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E242F),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Authorize recurring debit with Razorpay',
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

          const SizedBox(height: 24),

          // Input 1: Mandate ID
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF475569),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _mandateIdController,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E242F),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Mandate ID',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Unique identifier issued by your bank / Razor...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8C95A6),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Input 2: Razorpay Payment ID
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.credit_card_rounded,
                  color: Color(0xFF475569),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _paymentIdController,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E242F),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Razorpay Payment ID',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Authorization transaction reference ID',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8C95A6),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Bottom Action Button: Confirm Mandate Authorization
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final mandateId = _mandateIdController.text.trim();
                      final paymentId = _paymentIdController.text.trim();

                      if (mandateId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter Mandate ID'),
                          ),
                        );
                        return;
                      }

                      if (paymentId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter Razorpay Payment ID'),
                          ),
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      final success = await WalletRepository().authorizeMandate(
                        mandateId: mandateId,
                        razorpayPaymentId: paymentId,
                      );

                      if (!mounted) return;
                      setState(() => _isSubmitting = false);

                      if (success) {
                        navigator.pop(true);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('E-Mandate authorized successfully!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to authorize E-Mandate. Please check Mandate ID.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E22CE),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Confirm Mandate Authorization',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
