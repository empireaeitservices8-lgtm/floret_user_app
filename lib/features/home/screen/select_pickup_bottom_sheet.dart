import 'package:flutter/material.dart';

import '../../booking/screen/disposal_console_screen.dart';

class SelectPickupBottomSheet extends StatelessWidget {
  const SelectPickupBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectPickupBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131D31),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3E58),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Title & Subtitle (Centered)
            const Text(
              'Select Pickup Option',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose the variety of waste dispatch service',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8C97AC),
              ),
            ),

            const SizedBox(height: 22),

            // Option 1: Residential Pickup
            _buildOptionCard(
              context: context,
              iconWidget: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2B42),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_rounded,
                    color: Color(0xFF4B6B94),
                    size: 22,
                  ),
                ),
              ),
              title: 'Residential Pickup',
              subtitle: 'Standard domestic organic & recyclables',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, DisposalConsoleScreen.routeName);
              },
            ),

            const SizedBox(height: 12),

            // Option 2: Commercial & Bulk Dispatch
            _buildOptionCard(
              context: context,
              iconWidget: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2B3E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.apartment_rounded,
                    color: Color(0xFF22D3EE),
                    size: 22,
                  ),
                ),
              ),
              title: 'Commercial & Bulk Dispatch',
              subtitle: 'Debris, commercial bins, or heavy packaging',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  DisposalConsoleScreen.routeName,
                  arguments: 'Commercial & Bulk Dispatch',
                );
              },
            ),

            const SizedBox(height: 12),

            // Option 3: Instant Express Request (Disabled)
            _buildOptionCard(
              context: context,
              iconWidget: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B281B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFFBBF24),
                    size: 22,
                  ),
                ),
              ),
              title: 'Instant Express Request',
              badgeText: 'Disabled',
              subtitle: 'Collection within 2 hours (+50 points)',
              isDisabled: true,
              onTap: () {
                // Disabled option
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required Widget iconWidget,
    required String title,
    required String subtitle,
    String? badgeText,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF25334E),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDisabled
                                ? const Color(0xFF8C97AC)
                                : Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF381E24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF87171),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF75839C),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDisabled
                  ? const Color(0xFF3E4D68)
                  : const Color(0xFF5A6B88),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
