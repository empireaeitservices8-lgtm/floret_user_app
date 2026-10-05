import 'package:flutter/material.dart';
import '../../auth/screen/safai_logo_widget.dart';

class AboutAppScreen extends StatelessWidget {
  static const String routeName = '/about_app';

  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // 1. Midnight Navy Top Bar
          _buildHeader(context),

          // 2. Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // App Logo & Details Section
                  _buildAppIdentitySection(),

                  const SizedBox(height: 24),

                  // Card 1: Our Mission
                  _buildOurMissionCard(),

                  const SizedBox(height: 16),

                  // Card 2: Key Highlights
                  _buildKeyHighlightsCard(),

                  const SizedBox(height: 28),

                  // Footer Copyright
                  _buildFooter(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header Widget
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1527),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'About App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. App Identity Section (Logo, Name, Version)
  Widget _buildAppIdentitySection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: SafaiLogoWidget(height: 52),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Safai 365',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Color(0xFF182236),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Powered by Floret Technologies',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Version 1.0.0 (Build 7)',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // 3. Our Mission Card
  Widget _buildOurMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF0F3F6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco_rounded,
                color: Color(0xFF182236),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF182236),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Safai 365 is a smart waste management platform built with the mission to automate, optimize, and digitize rubbish collection. We aim to help citizens schedule pickups effortlessly, support local sanitation workers, and measure our collective impact in building a greener, more sustainable world.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF475569),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Key Highlights Card
  Widget _buildKeyHighlightsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF0F3F6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: Color(0xFF182236),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Key Highlights',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF182236),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Highlight 1: Flexible Scheduling
          _buildHighlightItem(
            icon: Icons.calendar_today_rounded,
            title: 'Flexible Scheduling',
            subtitle:
                'Book pickups for residential or commercial waste on your time.',
          ),

          const Divider(
            height: 24,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 58,
          ),

          // Highlight 2: Impact Metrics
          _buildHighlightItem(
            icon: Icons.bar_chart_rounded,
            title: 'Impact Metrics',
            subtitle:
                'Track carbon reduction, trees saved, and recycling ratios live.',
          ),

          const Divider(
            height: 24,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 58,
          ),

          // Highlight 3: Safe Verification
          _buildHighlightItem(
            icon: Icons.shield_rounded,
            title: 'Safe Verification',
            subtitle:
                'Full verification profiles of door-to-door sanitation agents.',
          ),
        ],
      ),
    );
  }

  // Highlight Item Row
  Widget _buildHighlightItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
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
            color: const Color(0xFF182236),
            size: 20,
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
                  color: Color(0xFF182236),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF7E8B9B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Footer Widget
  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          '© 2026 Safai 365',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'All Rights Reserved.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFA0AEC0),
          ),
        ),
      ],
    );
  }
}
