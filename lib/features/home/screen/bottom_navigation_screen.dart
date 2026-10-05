import 'package:flutter/material.dart';
import '../../settings/screen/settings_screen.dart';
import '../../profile/screen/profile_screen.dart';
import 'home_screen.dart';
import '../../../widgets/app_bottom_nav_bar.dart';

class BottomNavigationScreen extends StatefulWidget {
  static const String routeName = '/bottom_nav';
  static const String route = '/bottom_nav';
  final int initialIndex;

  const BottomNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late int _currentIndex;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _previousIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    HomeScreen(showBottomNav: false),
    SettingsScreen(showBottomNav: false),
    ProfileScreen(showBottomNav: false),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isForward = _currentIndex >= _previousIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isIncoming = child.key == ValueKey<int>(_currentIndex);
          final double slideOffset = isIncoming
              ? (isForward ? 0.05 : -0.05)
              : (isForward ? -0.05 : 0.05);

          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(slideOffset, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
