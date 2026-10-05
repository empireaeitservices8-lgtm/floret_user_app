import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';
import 'package:floret_app/features/auth/screen/otp_screen.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/profile/screen/profile_screen.dart';
import 'package:floret_app/features/settings/screen/settings_screen.dart';
import 'package:floret_app/features/splashscreen/screen/splashscreen.dart';
import 'package:floret_app/features/notifications/screen/notifications_screen.dart';
import 'package:floret_app/features/wallet/screen/wallet_screen.dart';
import 'package:floret_app/features/settings/screen/privacy_security_screen.dart';
import 'package:floret_app/features/settings/screen/notification_preferences_screen.dart';
import 'package:floret_app/features/settings/screen/help_support_screen.dart';
import 'package:floret_app/features/settings/screen/about_app_screen.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/features/booking/screen/disposal_console_screen.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';
import 'package:floret_app/features/wallet/screen/razorpay_checkout_screen.dart';

void main() {
  testWidgets('1. SplashScreen renders Floret logo and loading indicator',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const SplashScreen(),
        routes: {
          LoginScreen.routeName: (c) => const Scaffold(),
        },
      ),
    );
    await tester.pump();

    // Verify progress indicator is present
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Settle timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('2. LoginScreen renders UI elements identically to design',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Powered by Floret Technologies'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to manage your waste sustainably'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('10-digit mobile number'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    final phoneFinder = find.byType(TextField);
    expect(phoneFinder, findsOneWidget);

    await tester.enterText(phoneFinder, '9876543210');
    await tester.pump();

    expect(find.text('9876543210'), findsOneWidget);

    await tester.tap(find.text('Send OTP'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verified navigated to OTP screen
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Verify & Login'), findsOneWidget);
  });

  testWidgets('3. OtpScreen renders OTP input and verifies to Home',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const OtpScreen(mobileNumber: '9995723146'),
        routes: {
          HomeScreen.routeName: (c) => const Scaffold(),
        },
      ),
    );
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('9995723146'), findsOneWidget);
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Resend OTP'), findsOneWidget);
    expect(find.text('Enter OTP code'), findsOneWidget);
    expect(find.text('Verify & Login'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter OTP code
    final otpFinder = find.byType(TextField);
    await tester.enterText(otpFinder, '1234');
    await tester.pump();

    expect(find.text('1234'), findsOneWidget);

    // Tap Verify & Login
    await tester.tap(find.text('Verify & Login'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('4. HomeScreen renders all sections from Images 3 and 4',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // Header & Greeting
    expect(find.text('Good afternoon 🌤️'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);
    expect(find.text('Sustainability Score'), findsOneWidget);
    expect(find.text('0 pts'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Earn eco-points on pickups to level up! 🌱'),
        findsOneWidget);

    // Metrics
    expect(find.text('Pending Bills'), findsOneWidget);
    expect(find.text('Active Pickups'), findsOneWidget);

    // Waste Categories
    expect(find.text('Waste Categories'), findsOneWidget);
    expect(find.text('Sanitary Waste'), findsOneWidget);
    expect(find.text('Diapers, hygiene'), findsOneWidget);
    expect(find.text('Scrap Waste'), findsOneWidget);
    expect(find.text('Paper, metal, plast...'), findsOneWidget);
    expect(find.text('Glass Waste'), findsOneWidget);
    expect(find.text('Bottles, jars, shards'), findsOneWidget);

    // Eco Pickup Banner
    expect(find.text('Eco Pickup\nBooking'), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);

    // Climate Impact
    expect(find.text('Climate Impact'), findsOneWidget);
    expect(find.text('CO2 Reduced'), findsOneWidget);
    expect(find.text('0.0 kg'), findsOneWidget);
    expect(find.text('Eco Points'), findsOneWidget);
    expect(find.text('0 Pts'), findsOneWidget);

    // Recycle Progress
    expect(find.text('Recycle Progress'), findsOneWidget);
    expect(find.text('0% Done'), findsOneWidget);
    expect(find.text('Target: 50kg monthly recycler'), findsOneWidget);
    expect(find.text('Monthly Total'), findsOneWidget);
    expect(find.text('0.0 kg / 50 kg'), findsOneWidget);
    expect(find.text('Live sync active'), findsOneWidget);
    expect(find.text('Keep going!'), findsOneWidget);

    // Bottom Navigation
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('5. SettingsScreen renders all elements from Image 1',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Settings'), findsNWidgets(2)); // Title & BottomNav
    expect(find.text('Configure preferences & security'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    expect(find.text('ACCOUNT & PREFERENCES'), findsOneWidget);
    expect(find.text('Privacy & Security'), findsOneWidget);
    expect(find.text('Notification Preferences'), findsOneWidget);

    expect(find.text('SUPPORT & GENERAL'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('About App'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('6. ProfileScreen renders all elements from Image 2',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Good afternoon 🌤️'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);

    expect(find.text('Carbon Saved'), findsOneWidget);
    expect(find.text('Points'), findsOneWidget);
    expect(find.text('Pickups'), findsOneWidget);

    expect(find.text('MY ACTIVITY & REWARDS'), findsOneWidget);
    expect(find.text('Floret Wallet'), findsOneWidget);
    expect(find.text('Check points and earned bags'), findsOneWidget);

    expect(find.text('SUPPORT & ACCOUNT'), findsOneWidget);
    expect(find.text('Order History'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);

    expect(find.text('Safai 365'), findsOneWidget);
    expect(find.text('Powered by Floret Technologies'), findsOneWidget);
  });

  testWidgets('7. NotificationsScreen renders UI elements matching Image 1',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
    await tester.pump();

    // Verify Title & Tabs
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);

    // Verify Empty State elements
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    expect(find.text('No notifications found'), findsOneWidget);
    expect(find.text('Your notifications will appear here.'), findsOneWidget);

    // Switch tab
    await tester.tap(find.text('Upcoming'));
    await tester.pump();
  });

  testWidgets('8. WalletScreen renders UI elements matching Image 2',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );
    await tester.pump();

    // Header & Balance Card
    expect(find.text('Floret Wallet'), findsOneWidget);
    expect(find.text('WALLETS BALANCE'), findsOneWidget);
    expect(find.text('Auto Top-Up OFF'), findsOneWidget);
    expect(find.text('₹ 0.00'), findsOneWidget);
    expect(find.text('Top Up'), findsNWidgets(2)); // Card button & Action card
    expect(find.text('E-Mandate Pending'), findsOneWidget);
    expect(find.text('Authorize >'), findsOneWidget);

    // Action Cards
    expect(find.text('Add Funds'), findsOneWidget);
    expect(find.text('Auto Top-Up'), findsOneWidget);
    expect(find.text('Configure'), findsOneWidget);
    expect(find.text('E-Mandate'), findsOneWidget);
    expect(find.text('Authorize'), findsOneWidget);

    // Segmented tabs & Empty state
    expect(find.text('Wallet Activity'), findsOneWidget);
    expect(find.text('Eco Rewards'), findsOneWidget);
    expect(find.text('No wallet transactions found'), findsOneWidget);
    expect(find.text('Make a Top-Up'), findsOneWidget);

    // Switch segmented control to Eco Rewards (Image 2)
    await tester.tap(find.text('Eco Rewards'));
    await tester.pumpAndSettle();

    // Verify all Eco Rewards elements
    expect(find.text('Available Safai Points'), findsOneWidget);
    expect(find.text('0 pts'), findsOneWidget);
    expect(find.text('Redeem'), findsOneWidget);
    expect(find.text('Earned'), findsOneWidget);
    expect(find.text('Redeemed'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(
        find.text(
            'Safai Points Rule: Earn 1 point per ₹100 spent • 1 Point = ₹0.25 redemption value'),
        findsOneWidget);
    expect(find.text('Reward Points Transaction History'), findsOneWidget);
    expect(find.text('No reward points history found'), findsOneWidget);

    // Switch back to Wallet Activity (Image 1)
    await tester.tap(find.text('Wallet Activity'));
    await tester.pumpAndSettle();

    expect(find.text('No wallet transactions found'), findsOneWidget);
    expect(find.text('Make a Top-Up'), findsOneWidget);
  });

  testWidgets(
      '9. HomeScreen navigates to NotificationsScreen on bell tap and WalletScreen on sustainability card tap',
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
          WalletScreen.routeName: (c) => const WalletScreen(),
        },
      ),
    );
    await tester.pump();

    // Tap bell icon -> navigates to NotificationsScreen
    final bellFinder = find.byIcon(Icons.notifications_none_rounded);
    expect(bellFinder, findsOneWidget);
    await tester.tap(bellFinder);
    await tester.pumpAndSettle();

    expect(find.text('No notifications found'), findsOneWidget);

    // Tap back button
    final backFinder = find.byIcon(Icons.chevron_left_rounded);
    await tester.tap(backFinder);
    await tester.pumpAndSettle();

    // Tap Sustainability Score card -> navigates to WalletScreen
    final scoreFinder = find.text('Sustainability Score');
    expect(scoreFinder, findsOneWidget);
    await tester.tap(scoreFinder);
    await tester.pumpAndSettle();

    expect(find.text('Floret Wallet'), findsOneWidget);
    expect(find.text('WALLETS BALANCE'), findsOneWidget);
  });

  testWidgets(
      '10. ProfileScreen navigates to WalletScreen on Floret Wallet tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: ProfileScreen.routeName,
        routes: {
          ProfileScreen.routeName: (c) => const ProfileScreen(),
          WalletScreen.routeName: (c) => const WalletScreen(),
        },
      ),
    );
    await tester.pump();

    final walletTileFinder = find.text('Floret Wallet');
    expect(walletTileFinder, findsOneWidget);
    await tester.tap(walletTileFinder);
    await tester.pumpAndSettle();

    expect(find.text('WALLETS BALANCE'), findsOneWidget);
  });

  testWidgets(
      '11. WalletScreen opens Top Up Wallet bottom sheet matching Image 1',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );
    await tester.pump();

    // Tap on Top Up action card
    final topUpCardFinder = find.text('Add Funds');
    expect(topUpCardFinder, findsOneWidget);
    await tester.tap(topUpCardFinder);
    await tester.pumpAndSettle();

    // Verify Image 1 content
    expect(find.text('Top Up Wallet'), findsOneWidget);
    expect(find.text('Add funds to your Floret balance'), findsOneWidget);
    expect(find.text('Select Amount (₹500 - ₹2,000)'), findsOneWidget);
    expect(find.text('₹500'), findsOneWidget);
    expect(find.text('₹1000'), findsOneWidget);
    expect(find.text('₹1500'), findsOneWidget);
    expect(find.text('₹2000'), findsOneWidget);
    expect(find.text('Custom Amount (₹)'), findsOneWidget);
    expect(find.text('Proceed to Pay ₹500.00'), findsOneWidget);

    // Tap ₹1000 preset
    await tester.tap(find.text('₹1000'));
    await tester.pumpAndSettle();
    // Tap Proceed to Pay -> opens Razorpay Checkout Screen matching screenshot
    await tester.tap(find.text('Proceed to Pay ₹1000.00'));
    await tester.pumpAndSettle();

    // Verify Razorpay Checkout Screen elements
    expect(find.text('Floret Technologies'), findsOneWidget);
    expect(find.text('Wallet Balance Top-Up'), findsOneWidget);
    expect(find.text('₹1000.00'), findsOneWidget);
    expect(find.text('UPI / QR'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('NetBanking'), findsOneWidget);
    expect(find.text('Wallets'), findsOneWidget);
    expect(find.text('Instant Pay via Apps'), findsOneWidget);
    expect(find.text('Google Pay'), findsOneWidget);
    expect(find.text('PhonePe'), findsOneWidget);
    expect(find.text('Paytm'), findsOneWidget);
    expect(find.text('BHIM UPI'), findsOneWidget);
    expect(find.text('Or Enter VPA / UPI ID'), findsOneWidget);
    expect(find.text('user@okaxis'), findsOneWidget);
    expect(find.text('Scan QR code with any UPI App to complete payment'),
        findsOneWidget);
    // Tap close button to return to WalletScreen
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify back on Floret Wallet screen
    expect(find.text('Floret Wallet'), findsOneWidget);
  });

  testWidgets(
      '12. WalletScreen opens Auto Top-Up Settings bottom sheet matching Image 2',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );
    await tester.pump();

    // Tap on Auto Top-Up action card
    final autoTopUpFinder = find.text('Configure');
    expect(autoTopUpFinder, findsOneWidget);
    await tester.tap(autoTopUpFinder);
    await tester.pumpAndSettle();

    // Verify initial content (OFF state matching image)
    expect(find.text('Auto Top-Up Settings'), findsOneWidget);
    expect(find.text('Automatically reload when balance drops low'),
        findsOneWidget);
    expect(find.text('Enable Auto Top-Up'), findsOneWidget);
    expect(find.text('Manual UPI top-ups only'), findsOneWidget);
    expect(find.text('Top up when balance falls below (₹)'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('Amount to add automatically (₹)'), findsOneWidget);
    expect(find.text('500.00'), findsOneWidget);
    expect(
      find.text(
          'Note: Automatic top-up starts as soon as your bank mandate is authorized.'),
      findsNothing,
    );

    // Toggle auto top-up switch to ON
    await tester.tap(find.text('Enable Auto Top-Up'));
    await tester.pumpAndSettle();

    // Verify ON state content matching the screenshot
    expect(find.text('Automatic wallet refills enabled'), findsOneWidget);
    expect(
      find.text(
          'Note: Automatic top-up starts as soon as your bank mandate is authorized.'),
      findsOneWidget,
    );
    expect(find.text('Top up when balance falls below (₹)'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('Amount to add automatically (₹)'), findsOneWidget);
    expect(find.text('500.00'), findsOneWidget);
    expect(find.text('Save Auto Top-Up Settings'), findsOneWidget);

    // Save and dismiss (shows circular progress indicator for 2 seconds)
    await tester.tap(find.text('Save Auto Top-Up Settings'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify wallet screen reflects ON state matching screenshot
    expect(find.text('Auto Top-Up ON'), findsOneWidget);
    expect(find.text('₹100 limit'), findsOneWidget);
    expect(find.text('₹ 1500.00'), findsOneWidget);
    expect(find.text('Manual wallet top-up'), findsOneWidget);
    expect(find.text('+₹1500.00'), findsOneWidget);
  });

  testWidgets(
      '13. WalletScreen opens Authorize E-Mandate bottom sheet matching Image 3',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );
    await tester.pump();

    // Tap on E-Mandate action card
    final eMandateFinder = find.text('Authorize');
    expect(eMandateFinder, findsOneWidget);
    await tester.tap(eMandateFinder);
    await tester.pumpAndSettle();

    // Verify Image 3 content
    expect(find.text('Authorize E-Mandate'), findsOneWidget);
    expect(
        find.text('Authorize recurring debit with Razorpay'), findsOneWidget);
    expect(find.text('Mandate ID'), findsOneWidget);
    expect(find.text('Unique identifier issued by your bank / Razor...'),
        findsOneWidget);
    expect(find.text('Razorpay Payment ID'), findsOneWidget);
    expect(find.text('Authorization transaction reference ID'), findsOneWidget);
    expect(find.text('Confirm Mandate Authorization'), findsOneWidget);

    // Confirm and dismiss
    await tester.tap(find.text('Confirm Mandate Authorization'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      '14. WalletScreen shows insufficient points snackbar when 0 pts, and opens Redeem Reward Points when >= 100 pts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(initialPoints: 0),
      ),
    );
    await tester.pump();

    // Switch to Eco Rewards tab
    await tester.tap(find.text('Eco Rewards'));
    await tester.pumpAndSettle();

    // Tap Redeem button with 0 pts -> shows red snackbar matching screenshot
    final redeemBtnFinder = find.text('Redeem');
    expect(redeemBtnFinder, findsOneWidget);
    await tester.tap(redeemBtnFinder);
    await tester.pump();
    expect(
      find.text(
          'Insufficient points! You need at least 100 eco-points to redeem.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    // Now test with >= 100 points opening the bottom sheet
    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(initialPoints: 100),
      ),
    );
    await tester.pump();

    // Switch to Eco Rewards tab
    await tester.tap(find.text('Eco Rewards'));
    await tester.pumpAndSettle();

    // Tap Redeem button with 100 pts
    await tester.tap(find.text('Redeem'));
    await tester.pumpAndSettle();

    // Verify Redeem Bottom Sheet content
    expect(find.text('Redeem Reward Points'), findsOneWidget);
    expect(find.text('Convert reward points into wallet credit or rewards'),
        findsOneWidget);
    expect(find.text('Redeem for Wallet Credit'), findsOneWidget);
    expect(find.text('100 points -> Direct wallet credit'), findsOneWidget);
    expect(find.text('100 PTS'), findsOneWidget);
    expect(find.text('Points to Redeem'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Available Points'), findsOneWidget);
    expect(find.text('Confirm Redeem'), findsOneWidget);

    // Tap Confirm Redeem and dismiss
    await tester.tap(find.text('Confirm Redeem'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      '15. HomeScreen opens Select Pickup Option bottom sheet when Book Now is tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          DisposalConsoleScreen.routeName: (c) => const Scaffold(),
        },
      ),
    );
    await tester.pump();

    // Tap Book Now button
    final bookBtnFinder = find.text('Book Now');
    expect(bookBtnFinder, findsOneWidget);
    await tester.tap(bookBtnFinder);
    await tester.pumpAndSettle();

    // Verify Select Pickup Option Bottom Sheet content
    expect(find.text('Select Pickup Option'), findsOneWidget);
    expect(find.text('Choose the variety of waste dispatch service'),
        findsOneWidget);
    expect(find.text('Residential Pickup'), findsOneWidget);
    expect(
        find.text('Standard domestic organic & recyclables'), findsOneWidget);
    expect(find.text('Commercial & Bulk Dispatch'), findsOneWidget);
    expect(find.text('Debris, commercial bins, or heavy packaging'),
        findsOneWidget);
    expect(find.text('Instant Express Request'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.text('Collection within 2 hours (+50 points)'), findsOneWidget);

    // Tap Residential Pickup and dismiss
    await tester.tap(find.text('Residential Pickup'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      '16. SettingsScreen navigates to PrivacySecurityScreen and accordions expand/collapse matching images',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: SettingsScreen.routeName,
        routes: {
          SettingsScreen.routeName: (c) => const SettingsScreen(),
          PrivacySecurityScreen.routeName: (c) => const PrivacySecurityScreen(),
        },
      ),
    );
    await tester.pump();

    // Tap Privacy & Security tile in SettingsScreen
    final privacyTileFinder = find.text('Privacy & Security');
    expect(privacyTileFinder, findsOneWidget);
    await tester.tap(privacyTileFinder);
    await tester.pumpAndSettle();

    // Verify elements in PrivacySecurityScreen
    expect(find.text('Your connection is secure'), findsOneWidget);
    expect(find.text('Privacy Policies & Info'), findsOneWidget);
    expect(find.text('Data Protection & Encryption'), findsOneWidget);
    expect(find.text('Location Data Usage'), findsOneWidget);
    expect(find.text('Personal Information Sharing'), findsOneWidget);
    expect(find.text('Account & Data Deletion'), findsOneWidget);
    expect(find.text('Security Tips'), findsOneWidget);

    // Expand "Data Protection & Encryption" (Image 2)
    await tester.tap(find.text('Data Protection & Encryption'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining(
            'Floret Technologies takes your data security seriously'),
        findsOneWidget);

    // Expand "Location Data Usage" (Image 2)
    await tester.tap(find.text('Location Data Usage'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining(
            'We collect and process your geographical location data'),
        findsOneWidget);

    // Expand "Personal Information Sharing" (Image 3)
    await tester.tap(find.text('Personal Information Sharing'));
    await tester.pumpAndSettle();
    expect(find.textContaining('To facilitate smooth waste processing'),
        findsOneWidget);

    // Expand "Account & Data Deletion" (Image 3)
    await tester.tap(find.text('Account & Data Deletion'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining(
            'You hold the right to delete your Floret Technologies account'),
        findsOneWidget);

    // Collapse "Data Protection & Encryption"
    await tester.tap(find.text('Data Protection & Encryption'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining(
            'Floret Technologies takes your data security seriously'),
        findsNothing);
  });

  testWidgets(
      '19. SettingsScreen -> NotificationPreferencesScreen -> Save Preferences shows snackbar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: SettingsScreen.routeName,
        routes: {
          SettingsScreen.routeName: (c) => const SettingsScreen(),
          NotificationPreferencesScreen.routeName: (c) =>
              const NotificationPreferencesScreen(),
        },
      ),
    );
    await tester.pump();

    // Tap Notification Preferences tile in SettingsScreen
    final notifPrefTileFinder = find.text('Notification Preferences');
    expect(notifPrefTileFinder, findsOneWidget);
    await tester.tap(notifPrefTileFinder);
    await tester.pumpAndSettle();

    // Verify elements in NotificationPreferencesScreen
    expect(find.text('Notification Preferences'), findsWidgets);
    expect(find.text('Manage Notifications'), findsOneWidget);
    expect(
      find.text(
          'Choose how and when you want to receive updates from Floret Technologies.'),
      findsOneWidget,
    );
    expect(find.text('Channels'), findsOneWidget);
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(
      find.text('Receive alerts on your device lockscreen'),
      findsOneWidget,
    );
    expect(find.text('Email Notifications'), findsOneWidget);
    expect(
      find.text('Receive invoices and reports in your inbox'),
      findsOneWidget,
    );
    expect(find.text('SAVE PREFERENCES'), findsOneWidget);

    // Verify switch widgets and interactive toggling
    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    // Toggle Push Notifications switch
    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    // Tap "SAVE PREFERENCES"
    final saveButton = find.text('SAVE PREFERENCES');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify navigated back to SettingsScreen
    expect(find.text('ACCOUNT & PREFERENCES'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);

    // Verify SnackBar with exact text "preferences updated successfully!" is visible
    expect(find.text('preferences updated successfully!'), findsOneWidget);
  });

  testWidgets(
      '20. SettingsScreen -> HelpSupportScreen -> Helpline, Email Support with url_launcher, and FAQs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: SettingsScreen.routeName,
        routes: {
          SettingsScreen.routeName: (c) => const SettingsScreen(),
          HelpSupportScreen.routeName: (c) => const HelpSupportScreen(),
        },
      ),
    );
    await tester.pump();

    // Tap Help & Support tile in SettingsScreen
    final helpSupportTileFinder = find.text('Help & Support');
    expect(helpSupportTileFinder, findsOneWidget);
    await tester.tap(helpSupportTileFinder);
    await tester.pumpAndSettle();

    // Verify elements in HelpSupportScreen
    expect(find.text('Help & Support'), findsWidgets);
    expect(find.text('Support Helpline'), findsOneWidget);
    expect(
      find.text(
          'Call our dedicated support helpline for immediate booking assistance.'),
      findsOneWidget,
    );
    expect(find.text('92920 23601'), findsOneWidget);
    expect(find.text('CALL NOW'), findsOneWidget);

    // Verify Email Support Card
    expect(find.text('Email Support'), findsOneWidget);
    expect(find.text('florettechnologies@gmail.com'), findsOneWidget);

    // Tap Email Support card (launches email client via url_launcher)
    await tester.tap(find.text('florettechnologies@gmail.com'));
    await tester.pump();

    // Verify Frequently Asked Questions section
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('How do I schedule a waste pickup?'), findsOneWidget);
    expect(find.text('What types of waste are accepted?'), findsOneWidget);
    expect(find.text('Is there a charge for bulk collection?'), findsOneWidget);
    expect(find.text('How can I track my pickup driver?'), findsOneWidget);

    // Tap on "How do I schedule a waste pickup?" (Image 2)
    await tester.tap(find.text('How do I schedule a waste pickup?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
          'Tapping the "Book Now" button on the home screen initiates your pickup request'),
      findsOneWidget,
    );

    // Tap on "What types of waste are accepted?" (Image 2)
    await tester.tap(find.text('What types of waste are accepted?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
          'We collect Hazardous waste (medical, diapers, sanitary pads)'),
      findsOneWidget,
    );

    // Tap on "Is there a charge for bulk collection?" (Image 3)
    await tester.tap(find.text('Is there a charge for bulk collection?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
          'Yes, bulk waste or commercial collections have separate pricing packages'),
      findsOneWidget,
    );

    // Tap on "How can I track my pickup driver?" (Image 3)
    await tester.tap(find.text('How can I track my pickup driver?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
          'Once your booking is confirmed and a driver is assigned'),
      findsOneWidget,
    );

    // Collapse "How do I schedule a waste pickup?"
    await tester.tap(find.text('How do I schedule a waste pickup?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
          'Tapping the "Book Now" button on the home screen initiates your pickup request'),
      findsNothing,
    );
  });

  testWidgets(
      '21. SettingsScreen -> AboutAppScreen -> App Identity, Mission, Highlights, and Footer',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: SettingsScreen.routeName,
        routes: {
          SettingsScreen.routeName: (c) => const SettingsScreen(),
          AboutAppScreen.routeName: (c) => const AboutAppScreen(),
        },
      ),
    );
    await tester.pump();

    // Tap About App tile in SettingsScreen
    final aboutAppTileFinder = find.text('About App');
    expect(aboutAppTileFinder, findsOneWidget);
    await tester.tap(aboutAppTileFinder);
    await tester.pumpAndSettle();

    // Verify elements in AboutAppScreen
    expect(find.text('About App'), findsWidgets);
    expect(find.text('Safai 365'), findsOneWidget);
    expect(find.text('Powered by Floret Technologies'), findsOneWidget);
    expect(find.text('Version 1.0.0 (Build 7)'), findsOneWidget);

    // Verify Our Mission Card
    expect(find.text('Our Mission'), findsOneWidget);
    expect(
      find.textContaining(
          'Safai 365 is a smart waste management platform built with the mission'),
      findsOneWidget,
    );

    // Verify Key Highlights Card
    expect(find.text('Key Highlights'), findsOneWidget);
    expect(find.text('Flexible Scheduling'), findsOneWidget);
    expect(
      find.text(
          'Book pickups for residential or commercial waste on your time.'),
      findsOneWidget,
    );
    expect(find.text('Impact Metrics'), findsOneWidget);
    expect(
      find.text(
          'Track carbon reduction, trees saved, and recycling ratios live.'),
      findsOneWidget,
    );
    expect(find.text('Safe Verification'), findsOneWidget);
    expect(
      find.text(
          'Full verification profiles of door-to-door sanitation agents.'),
      findsOneWidget,
    );

    // Verify Footer
    expect(find.text('© 2026 Safai 365'), findsOneWidget);
    expect(find.text('All Rights Reserved.'), findsOneWidget);
  });

  testWidgets('22. SettingsScreen -> Tap Logout -> Navigates to LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: SettingsScreen.routeName,
        routes: {
          SettingsScreen.routeName: (c) => const SettingsScreen(),
          LoginScreen.routeName: (c) => const LoginScreen(),
        },
      ),
    );
    await tester.pump();

    // Verify on SettingsScreen
    expect(find.text('Logout'), findsOneWidget);

    // Tap Logout tile
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Verify navigated to LoginScreen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to manage your waste sustainably'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets(
      '23. ProfileScreen -> OrderHistoryScreen -> Filters selection & Empty State',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: ProfileScreen.routeName,
        routes: {
          ProfileScreen.routeName: (c) => const ProfileScreen(),
          OrderHistoryScreen.routeName: (c) => const OrderHistoryScreen(),
        },
      ),
    );
    await tester.pump();

    // Verify on ProfileScreen and find Order History
    final orderHistoryFinder = find.text('Order History');
    expect(orderHistoryFinder, findsOneWidget);

    // Tap on Order History tile
    await tester.tap(orderHistoryFinder);
    await tester.pumpAndSettle();

    // Verify on OrderHistoryScreen
    expect(find.text('Order History'), findsWidgets);

    // Verify 4 filter tabs
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);

    // Verify empty state
    expect(find.text('No orders found'), findsOneWidget);
    expect(find.text('Schedule a pickup to see your orders here.'),
        findsOneWidget);
    expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);

    // Verify 'All' text is white (selected) initially
    Text allTextWidget = tester.widget(find.text('All'));
    expect(allTextWidget.style?.color, Colors.white);

    // Verify 'Completed' text is black/dark (unselected) initially
    Text completedTextWidget = tester.widget(find.text('Completed'));
    expect(completedTextWidget.style?.color, const Color(0xFF182236));

    // Tap on 'Completed' tab
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();

    // Now 'Completed' should be selected (white text)
    completedTextWidget = tester.widget(find.text('Completed'));
    expect(completedTextWidget.style?.color, Colors.white);

    // And 'All' should be unselected (black text)
    allTextWidget = tester.widget(find.text('All'));
    expect(allTextWidget.style?.color, const Color(0xFF182236));

    // Tap on 'Pending' tab
    await tester.ensureVisible(find.text('Pending'));
    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();

    Text pendingTextWidget = tester.widget(find.text('Pending'));
    expect(pendingTextWidget.style?.color, Colors.white);

    // Tap on 'Reschedule' tab
    await tester.ensureVisible(find.text('Reschedule'));
    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();

    Text rescheduleTextWidget = tester.widget(find.text('Reschedule'));
    expect(rescheduleTextWidget.style?.color, Colors.white);

    // Tap back to 'All'
    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    allTextWidget = tester.widget(find.text('All'));
    expect(allTextWidget.style?.color, Colors.white);
  });

  testWidgets(
      '24. Flow: Book Now -> Select Residential Pickup -> Disposal Console -> Continue to Schedule -> Book Pickup -> Contact -> Location -> Saved Addresses shows snackbar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (c) => const HomeScreen(),
          DisposalConsoleScreen.routeName: (c) => const DisposalConsoleScreen(),
          BookPickupScreen.routeName: (c) => const BookPickupScreen(),
        },
      ),
    );
    await tester.pump();

    // 1. In Home tap on Book Now shows bottom sheet
    final bookBtnFinder = find.text('Book Now');
    expect(bookBtnFinder, findsOneWidget);
    await tester.tap(bookBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Select Pickup Option'), findsOneWidget);
    expect(find.text('Residential Pickup'), findsOneWidget);

    // 2. In bottom sheet tap on Residential pickup move to Disposal Console
    await tester.tap(find.text('Residential Pickup'));
    await tester.pumpAndSettle();

    expect(find.text('Disposal Console'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    expect(find.text('SANITARY WASTE'), findsOneWidget);
    expect(find.text('SOLID WASTE'), findsOneWidget);
    expect(find.text('GLASS WASTE'), findsOneWidget);
    expect(find.text('Live Impact Projection'), findsOneWidget);

    // Initial state: 0.0 kg and +0 XP
    expect(find.text('0.0 kg'), findsOneWidget);
    expect(find.text('+0 XP'), findsOneWidget);

    // Tap SANITARY WASTE to select it
    await tester.tap(find.text('SANITARY WASTE'));
    await tester.pumpAndSettle();

    // Shows guideline banner
    expect(find.text('Disposal Guideline'), findsOneWidget);
    expect(
      find.text(
          'Please pack sanitary waste in a sealed leak-proof bag before handing it to the collector.'),
      findsOneWidget,
    );
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('-8.2 kg'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);

    // 3. In disposal console tap on continue to Schedule shows Book Pickup and tick in contact
    final continueToScheduleFinder = find.text('Continue to Schedule');
    expect(continueToScheduleFinder, findsOneWidget);
    await tester.tap(continueToScheduleFinder);
    await tester.pumpAndSettle();

    expect(find.text('Book Pickup'), findsOneWidget);
    expect(find.text('Contact Details'), findsOneWidget);
    expect(find.text('nicy nicy'), findsOneWidget);
    expect(find.text('+919995723146'), findsOneWidget);

    // 4. Again tap on continue shows location details and put tick mark on location and so on
    final continueFinder = find.text('Continue');
    expect(continueFinder, findsOneWidget);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    expect(find.text('Location Details'), findsOneWidget);
    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('New Address'), findsOneWidget);
    expect(find.text('Locate on Map'), findsOneWidget);
    expect(find.textContaining('Pickup Address'), findsWidgets);
    expect(find.textContaining('City'), findsWidgets);
    expect(find.textContaining('State'), findsWidgets);

    // 5. In location details tap on saved address show snackbar no saved adress found.please add a new address
    await tester.tap(find.text('Saved Addresses'));
    await tester.pumpAndSettle();

    expect(
      find.text('no saved adress found.please add a new address'),
      findsOneWidget,
    );

    // Dismiss SnackBar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Continue to Schedule
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule Pickup'), findsOneWidget);
    expect(find.text('Please select Pickup Date'), findsOneWidget);
    expect(find.text('03-10-2026'), findsOneWidget);
    expect(find.text('Booking Summary'), findsOneWidget);

    // Tap date to open calendar picker
    await tester.tap(find.text('03-10-2026'));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Confirm Scheduling -> Shows CircularProgressIndicator in button
    await tester.tap(find.text('Confirm Scheduling'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete delay and transition to Receipt Ticket screen
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Receipt Ticket screen elements
    expect(find.text('Receipt Ticket'), findsOneWidget);
    expect(find.text('Booking Successful!'), findsOneWidget);
    expect(find.text('Booking ID: WC-161'), findsOneWidget);
    expect(find.text('Thursday, 15 Oct 2026'), findsOneWidget);
    expect(find.text('Sanitary waste'), findsOneWidget);
    expect(find.text('*WC-161*'), findsOneWidget);
    expect(find.text('Pickup scheduled successfully!'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    // Tap Back to Home
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Verify back on HomeScreen!
    expect(find.text('Receipt Ticket'), findsNothing);
    expect(find.text('Disposal Console'), findsNothing);
    expect(find.text('Book Pickup'), findsNothing);
    expect(find.text('Eco Pickup\nBooking'), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);
  });

  testWidgets(
      '25. Flow: Book Now -> Commercial & Bulk Dispatch -> Disposal Console & functions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (c) => const HomeScreen(),
          DisposalConsoleScreen.routeName: (c) => const DisposalConsoleScreen(),
          BookPickupScreen.routeName: (c) => const BookPickupScreen(),
        },
      ),
    );
    await tester.pump();

    // 1. In Home tap on Book Now shows bottom sheet
    await tester.tap(find.text('Book Now'));
    await tester.pumpAndSettle();

    expect(find.text('Commercial & Bulk Dispatch'), findsOneWidget);

    // 2. Tap Commercial & Bulk Dispatch -> navigates to Disposal Console
    await tester.tap(find.text('Commercial & Bulk Dispatch'));
    await tester.pumpAndSettle();

    expect(find.text('Disposal Console'), findsOneWidget);
    expect(find.text('Commercial & Bulk'), findsOneWidget);
    expect(find.text('SANITARY WASTE'), findsOneWidget);
    expect(find.text('SOLID WASTE'), findsOneWidget);
    expect(find.text('GLASS WASTE'), findsOneWidget);

    // Test functions: toggle SOLID WASTE
    await tester.tap(find.text('SOLID WASTE'));
    await tester.pumpAndSettle();

    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('-5.5 kg'), findsOneWidget);
    expect(find.text('+40 XP'), findsOneWidget);

    // Continue to Schedule
    await tester.tap(find.text('Continue to Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Book Pickup'), findsOneWidget);
    expect(find.text('Contact Details'), findsOneWidget);

    // Continue to Location
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Location Details'), findsOneWidget);
  });

  testWidgets(
      '26. RazorpayCheckoutScreen renders all screenshot elements, processes payment, and confirms success',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: RazorpayCheckoutScreen(amount: 500.00),
      ),
    );
    await tester.pump();

    // Verify top bar
    expect(find.text('https://api.razorpay.co...'), findsOneWidget);
    expect(find.text('SECURE'), findsOneWidget);

    // Verify merchant header
    expect(find.text('Floret Technologies'), findsOneWidget);
    expect(find.text('Wallet Balance Top-Up'), findsOneWidget);
    expect(find.text('₹500.00'), findsOneWidget);
    expect(find.text('Order ID: order_u6Fx1O'), findsOneWidget);

    // Verify tabs
    expect(find.text('UPI / QR'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('NetBanking'), findsOneWidget);
    expect(find.text('Wallets'), findsOneWidget);

    // Verify Instant Pay via Apps
    expect(find.text('Instant Pay via Apps'), findsOneWidget);
    expect(find.text('Google Pay'), findsOneWidget);
    expect(find.text('PhonePe'), findsOneWidget);
    expect(find.text('Paytm'), findsOneWidget);
    expect(find.text('BHIM UPI'), findsOneWidget);

    // Switch app to PhonePe
    await tester.tap(find.text('PhonePe'));
    await tester.pumpAndSettle();

    // Verify VPA and info banner in UPI / QR tab
    expect(find.text('Or Enter VPA / UPI ID'), findsOneWidget);
    expect(find.text('user@okaxis'), findsOneWidget);
    expect(
      find.text('Scan QR code with any UPI App to complete payment'),
      findsOneWidget,
    );

    // Switch payment method tab to Card
    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();

    // Verify Card preview and fields matching Image 1
    expect(find.text('CREDIT / DEBIT CARD'), findsOneWidget);
    expect(find.text('CARD HOLDER'), findsOneWidget);
    expect(find.text('VALUED USER'), findsAtLeastNWidgets(1));
    expect(find.text('EXPIRES'), findsOneWidget);
    expect(find.text('08/28'), findsAtLeastNWidgets(1));
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('Expiry (MM/YY)'), findsOneWidget);
    expect(find.text('CVV'), findsOneWidget);
    expect(find.text('Cardholder Name'), findsOneWidget);
    expect(find.text('•••'), findsOneWidget);

    // Switch payment method tab to NetBanking
    await tester.tap(find.text('NetBanking'));
    await tester.pumpAndSettle();

    // Verify NetBanking banks matching Image 2
    expect(find.text('Select Popular Bank'), findsOneWidget);
    expect(find.text('HDFC'), findsOneWidget);
    expect(find.text('ICICI'), findsOneWidget);
    expect(find.text('SBI'), findsOneWidget);
    expect(find.text('Axis'), findsOneWidget);
    expect(find.text('Kotak'), findsOneWidget);
    expect(find.text('PNB'), findsOneWidget);

    // Tap on ICICI bank
    await tester.tap(find.text('ICICI'));
    await tester.pumpAndSettle();

    // Switch payment method tab to Wallets
    await tester.tap(find.text('Wallets'));
    await tester.pumpAndSettle();

    // Verify Wallets matching Image 3
    expect(find.text('Mobikwik'), findsOneWidget);
    expect(find.text('Freecharge'), findsOneWidget);
    expect(find.text('Airtel Money'), findsOneWidget);
    expect(find.text('JioMoney'), findsOneWidget);

    // Tap on Freecharge wallet
    await tester.tap(find.text('Freecharge'));
    await tester.pumpAndSettle();

    // Verify Pay button
    final payBtn = find.text('PAY ₹500.00 VIA RAZORPAY');
    expect(payBtn, findsOneWidget);

    // Tap Pay button
    await tester.tap(payBtn);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Payment Successful dialog
    expect(find.text('Payment Successful!'), findsOneWidget);
    expect(
      find.text(
          '₹500.00 has been successfully credited to your Floret Wallet.'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      '27. Tapping cross icon on RazorpayCheckoutScreen navigates back to Floret Wallet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const RazorpayCheckoutScreen(amount: 500.00),
        routes: {
          WalletScreen.routeName: (context) => const WalletScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('razorpay_cross_icon')), findsOneWidget);

    // Tap cross icon
    await tester.tap(find.byKey(const Key('razorpay_cross_icon')));
    await tester.pumpAndSettle();

    // Verify back on Floret Wallet
    expect(find.text('Floret Wallet'), findsOneWidget);
  });
}
