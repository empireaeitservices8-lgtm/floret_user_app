import 'package:flutter/material.dart';

/// Bottom sheet shown after auto top-up settings are saved successfully.
class AutoTopUpSuccessSheet extends StatelessWidget {
  final bool enabled;
  final double threshold;
  final double topUpAmount;

  const AutoTopUpSuccessSheet({
    super.key,
    required this.enabled,
    required this.threshold,
    required this.topUpAmount,
  });

  static Future<void> show(
    BuildContext context, {
    required bool enabled,
    required double threshold,
    required double topUpAmount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AutoTopUpSuccessSheet(
        enabled: enabled,
        threshold: threshold,
        topUpAmount: topUpAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('auto_topup_success_sheet'),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 44,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            enabled ? 'Auto Top-Up Enabled' : 'Auto Top-Up Disabled',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E242F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enabled
                ? 'Your wallet will be topped up with ₹${topUpAmount.toInt()} '
                    'whenever the balance falls below ₹${threshold.toInt()}.'
                : 'Your auto top-up settings were saved successfully.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('auto_topup_success_done'),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF131D31),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
