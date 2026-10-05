import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  static const String routeName = '/privacy_security';

  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // Set of expanded accordion items
  final Set<int> _expandedIndices = {};

  final List<Map<String, dynamic>> _policyItems = const [
    {
      'title': 'Data Protection & Encryption',
      'icon': Icons.shield_rounded,
      'content':
          'Floret Technologies takes your data security seriously. All personal information, billing details, and collection logs are encrypted in transit using SSL/TLS and at rest using AES-256 standard encryption. Your data is strictly secured in compliance with global data privacy guidelines.',
    },
    {
      'title': 'Location Data Usage',
      'icon': Icons.location_on_rounded,
      'content':
          'We collect and process your geographical location data solely to facilitate optimized waste pickup routing, connect you to local waste collectors, and track your active collection requests in real-time. Your location is never shared with third parties for marketing purposes.',
    },
    {
      'title': 'Personal Information Sharing',
      'icon': Icons.person_search_rounded,
      'content':
          'To facilitate smooth waste processing, your basic details (Name, Contact Number, Pickup Address) are shared only with the designated collection agent assigned to your request. We do not sell or lease your personal information to third-party advertisers.',
    },
    {
      'title': 'Account & Data Deletion',
      'icon': Icons.delete_outline_rounded,
      'content':
          'You hold the right to delete your Floret Technologies account and erase your historical records at any time. Under settings, you can submit a Request Account Deletion, which permanently purges your personal profile, credentials, and address list from our active databases within 14 business days.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // 1. Midnight Navy Top Bar
          _buildHeader(),

          // 2. Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Green/Dark Connection is Secure Banner
                  _buildConnectionBanner(),

                  const SizedBox(height: 22),

                  // Section Title
                  const Text(
                    'Privacy Policies & Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4 Expandable Policy Cards
                  ...List.generate(_policyItems.length, (index) {
                    final item = _policyItems[index];
                    final isExpanded = _expandedIndices.contains(index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPolicyCard(
                        index: index,
                        title: item['title'] as String,
                        icon: item['icon'] as IconData,
                        content: item['content'] as String,
                        isExpanded: isExpanded,
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Security Tips Yellow Box
                  _buildSecurityTipsBox(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header Widget
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1527),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
                splashRadius: 24,
              ),
              const SizedBox(width: 4),
              const Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Connection Banner
  Widget _buildConnectionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF162A32),
            Color(0xFF147545),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF147545).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.verified_user_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your connection is secure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'App version 1.0.0 is secured with industry-grade security protocols.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Expandable Policy Card
  Widget _buildPolicyCard({
    required int index,
    required String title,
    required IconData icon,
    required String content,
    required bool isExpanded,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_expandedIndices.contains(index)) {
            _expandedIndices.remove(index);
          } else {
            _expandedIndices.add(index);
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF0F3F6),
            width: 1.2,
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
            // Always Visible Header Row
            Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFF1E293B),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242F),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),

            // Expandable Description Content
            if (isExpanded) ...[
              const SizedBox(height: 14),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5A6578),
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 4. Security Tips Box
  Widget _buildSecurityTipsBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSecurityTipBullet(
            'Never share your verification OTP with anyone, including Floret Technologies agents.',
          ),
          const SizedBox(height: 10),
          _buildSecurityTipBullet(
            'Ensure your mobile device has a screen lock enabled for data protection.',
          ),
          const SizedBox(height: 10),
          _buildSecurityTipBullet(
            'Verify the identity of the collector at your doorstep using the track map.',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTipBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFFD97706),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB45309),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
