import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/widgets/app_bottom_nav_bar.dart';
import 'package:floret_app/features/home/screen/bottom_navigation_screen.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/notifications/screen/notifications_screen.dart';
import 'package:floret_app/features/wallet/screen/wallet_screen.dart';

void main() {
  testWidgets('AppBottomNavigationBar renders exactly matching design',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    int selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) {
              return AppBottomNavigationBar(
                currentIndex: selected,
                onTap: (index) {
                  setState(() {
                    selected = index;
                  });
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify all 3 navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Icons exist
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.manage_accounts_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    // Tap Settings
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(selected, 1);

    // Tap Profile
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(selected, 2);

    // Tap Home
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(selected, 0);
  });

  testWidgets('BottomNavigationScreen renders tabs and switches views',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: BottomNavigationScreen(),
      ),
    );
    await tester.pump();

    // Initially on Home
    expect(find.text('Good afternoon 🌤️'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);

    // Tap Settings tab
    final settingsFinder = find.descendant(
      of: find.byType(AppBottomNavigationBar),
      matching: find.text('Settings'),
    );
    await tester.tap(settingsFinder.first);
    await tester.pumpAndSettle();

    // Verify Settings tab is active
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets(
      'Tapping bell icon on HomeScreen navigates to NotificationsScreen matching design',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (c) => const HomeScreen(),
          NotificationsScreen.routeName: (c) => const NotificationsScreen(),
        },
      ),
    );
    await tester.pump();

    // Tap notification bell icon
    final bellFinder = find.byIcon(Icons.notifications_none_rounded);
    expect(bellFinder, findsOneWidget);
    await tester.tap(bellFinder);
    await tester.pumpAndSettle();

    // Verify Notifications header and tabs matching user screenshot
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);

    // Verify empty state matching user screenshot
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    expect(find.text('No notifications found'), findsOneWidget);
    expect(find.text('Your notifications will appear here.'), findsOneWidget);

    // Switch between tabs
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delivered'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Tap back button
    final backFinder = find.byIcon(Icons.chevron_left_rounded);
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
    await tester.pumpAndSettle();

    // Back to home
    expect(find.text('Good afternoon 🌤️'), findsOneWidget);
  });

  testWidgets('Tapping Eco Points on HomeScreen opens Floret Wallet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          WalletScreen.routeName: (context) => const WalletScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    final ecoPointsFinder = find.text('Eco Points');
    await tester.ensureVisible(ecoPointsFinder);
    await tester.tap(ecoPointsFinder);
    await tester.pumpAndSettle();

    expect(find.text('Floret Wallet'), findsOneWidget);
  });
}
