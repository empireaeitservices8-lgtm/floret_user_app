import 'package:flutter/material.dart';
import '../../home/screen/home_screen.dart';
import '../../home/screen/bottom_navigation_screen.dart';

class ReceiptTicketScreen extends StatefulWidget {
  static const String routeName = '/receipt_ticket';

  final String bookingId;
  final String date;
  final String wasteType;
  final String pickupAddress;
  final String contact;

  const ReceiptTicketScreen({
    super.key,
    this.bookingId = 'WC-161',
    this.date = 'Thursday, 15 Oct 2026',
    this.wasteType = 'Sanitary waste',
    this.pickupAddress =
        'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
    this.contact = 'User',
  });

  @override
  State<ReceiptTicketScreen> createState() => _ReceiptTicketScreenState();
}

class _ReceiptTicketScreenState extends State<ReceiptTicketScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Pickup scheduled successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF182236),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFBFBFD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Receipt Ticket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242F),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              // Ticket Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      child: Column(
                        children: [
                          // Circular Success Badge
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F8EE),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF182236),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Booking Successful!
                          const Text(
                            'Booking Successful!',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E242F),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Booking ID: WC-161
                          Text(
                            'Booking ID: ${widget.bookingId}',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E242F),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Your pickup collection request is logged and\nscheduled.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8C97AC),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ticket Perforation (Notches on sides & dashed line)
                    Row(
                      children: [
                        // Left notch
                        Container(
                          width: 14,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                        ),

                        // Dashed divider line
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const dashWidth = 6.0;
                                const dashHeight = 1.2;
                                final count = (constraints.maxWidth / (2 * dashWidth)).floor();
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(count, (_) {
                                    return const SizedBox(
                                      width: dashWidth,
                                      height: dashHeight,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ),

                        // Right notch
                        Container(
                          width: 14,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom Section Details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DATE
                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'DATE',
                            value: widget.date,
                          ),
                          const SizedBox(height: 16),

                          // WASTE TYPE
                          _buildDetailRow(
                            icon: Icons.recycling_rounded,
                            label: 'WASTE TYPE',
                            value: widget.wasteType,
                          ),
                          const SizedBox(height: 16),

                          // PICKUP ADDRESS
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'PICKUP ADDRESS',
                            value: widget.pickupAddress,
                          ),
                          const SizedBox(height: 16),

                          // CONTACT
                          _buildDetailRow(
                            icon: Icons.person_outline_rounded,
                            label: 'CONTACT',
                            value: widget.contact,
                          ),
                          const SizedBox(height: 18),

                          // Horizontal divider line
                          Container(
                            height: 1.2,
                            color: const Color(0xFF1E242F),
                            margin: const EdgeInsets.only(bottom: 20),
                          ),

                          // Barcode Graphic
                          _buildBarcode(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Bottom Button: Back to Home
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) {
                      return route.settings.name == HomeScreen.routeName ||
                          route.settings.name ==
                              BottomNavigationScreen.routeName ||
                          route.isFirst;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF131D31),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Individual detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242F),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Realistic Barcode Graphic
  Widget _buildBarcode() {
    final List<double> barWidths = [
      5, 3, 7, 2, 4, 6, 3, 5, 2, 7, 4, 3, 6, 2, 5, 4, 3, 7, 2, 4, 6, 3, 5, 2, 7, 3, 5, 4, 2, 6, 3, 5
    ];

    return Column(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: barWidths.asMap().entries.map((entry) {
              final isBar = entry.key % 2 == 0;
              return Container(
                width: entry.value,
                margin: const EdgeInsets.symmetric(horizontal: 1.2),
                decoration: BoxDecoration(
                  gradient: isBar
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF2D3748),
                            Color(0xFF1A202C),
                            Color(0xFF4A5568),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isBar ? null : Colors.transparent,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '*${widget.bookingId}*',
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 4.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
