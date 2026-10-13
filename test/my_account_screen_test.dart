import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/features/profile/screen/profile_screen.dart';
import 'package:floret_app/features/profile/screen/my_account_screen.dart';
import 'package:floret_app/features/profile/screen/saved_addresses_screen.dart';
import 'package:floret_app/viewmodels/profile_viewmodel.dart';

void main() {
  testWidgets('MyAccountScreen renders all design elements from screenshot',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MyAccountScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('My Account'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    // 2. Avatar Section (Always Visible)
    expect(find.text('D'), findsOneWidget);
    expect(find.text('demo pr'), findsWidgets);

    // 3. Summary Metric Cards
    expect(find.byIcon(Icons.recycling_rounded), findsOneWidget);
    expect(find.text('Total Pickups'), findsOneWidget);

    expect(find.byIcon(Icons.scale_rounded), findsOneWidget);
    expect(find.text('0.0 kg'), findsOneWidget);
    expect(find.text('Waste\nCollected'), findsOneWidget);

    expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
    expect(find.text('Trees Equiv.'), findsOneWidget);

    // 4. Personal Information Section
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('+917306929058'), findsOneWidget);

    // 5. Address Details Section
    expect(find.text('Address Details'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);
    expect(find.text('Default Address'), findsOneWidget);

    // 6. Bottom Navigation Bar
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets(
      'ProfileScreen navigates to MyAccountScreen when tapping on Account',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProfileViewModel(),
        child: MaterialApp(
          initialRoute: ProfileScreen.routeName,
          routes: {
            ProfileScreen.routeName: (c) => const ProfileScreen(),
            MyAccountScreen.routeName: (c) => const MyAccountScreen(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap Account item
    final accountItemFinder = find.text('Account');
    expect(accountItemFinder, findsOneWidget);
    await tester.tap(accountItemFinder);
    await tester.pumpAndSettle();

    // Verify on MyAccountScreen
    expect(find.text('My Account'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('demo pr'), findsWidgets);
    expect(find.text('Total Pickups'), findsOneWidget);
    expect(find.text('Waste\nCollected'), findsOneWidget);
    expect(find.text('Trees Equiv.'), findsOneWidget);
  });

  testWidgets(
      'In My Account tap Manage, then tap Add Address shows bottom sheet matching screenshot',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: MyAccountScreen.routeName,
        routes: {
          MyAccountScreen.routeName: (c) => const MyAccountScreen(),
          SavedAddressesScreen.routeName: (c) => const SavedAddressesScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    // 1. In My Account, tap Manage
    final manageFinder = find.text('Manage');
    expect(manageFinder, findsOneWidget);
    await tester.tap(manageFinder);
    await tester.pumpAndSettle();

    // 2. On SavedAddressesScreen, tap Add Address
    expect(find.text('Addresses'), findsOneWidget);
    final addAddressFinder = find.text('Add Address');
    expect(addAddressFinder, findsWidgets);
    await tester.tap(addAddressFinder.first);
    await tester.pumpAndSettle();

    // 3. Verify bottom sheet elements
    expect(find.text('Add New Address'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('Street Address & House No'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('State'), findsOneWidget);
    expect(find.text('Select State first'), findsOneWidget);
    expect(find.text('Select District first'), findsOneWidget);
    expect(find.text('Select Local Body first'), findsOneWidget);
    expect(find.text('Zip Code'), findsOneWidget);
    expect(find.text('Set as Default Address'), findsOneWidget);
    expect(find.text('SAVE ADDRESS'), findsOneWidget);
  });
}
