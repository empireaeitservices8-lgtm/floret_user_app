import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF1E242F),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            height: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
            height: 1.5,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: AnimatedScale(
                  scale: currentIndex == 0 ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: const Icon(Icons.home_outlined, size: 24),
                ),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: AnimatedScale(
                  scale: 1.08,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.home_outlined, size: 24),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: AnimatedScale(
                  scale: currentIndex == 1 ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: const Icon(Icons.manage_accounts_outlined, size: 24),
                ),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: AnimatedScale(
                  scale: 1.08,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.manage_accounts_outlined, size: 24),
                ),
              ),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: AnimatedScale(
                  scale: currentIndex == 2 ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: const Icon(Icons.person_outline_rounded, size: 24),
                ),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: AnimatedScale(
                  scale: 1.08,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.person_outline_rounded, size: 24),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
