import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders UI elements identically to design',
      (WidgetTester tester) async {
    // Set screen size for testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pump();

    // Verify Headings and Texts
    expect(find.text('Powered by Floret Technologies'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(
        find.text('Login to manage your waste sustainably'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('10-digit mobile number'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Verify phone input interaction
    final phoneFinder = find.byType(TextField);
    expect(phoneFinder, findsOneWidget);

    await tester.enterText(phoneFinder, '9876543210');
    await tester.pump();

    expect(find.text('9876543210'), findsOneWidget);

    // Tap Send OTP
    await tester.tap(find.text('Send OTP'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
