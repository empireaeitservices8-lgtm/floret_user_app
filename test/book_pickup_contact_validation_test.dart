import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookPickupScreen Contact Details Validation Tests', () {
    testWidgets(
        'Empty fields show required error messages and prevent navigation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contact Details'), findsOneWidget);
      expect(vm.currentStep, equals(0));

      // Tap Continue without entering name or phone
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      // Errors should appear and step should remain 0
      expect(find.text('Please enter full name'), findsOneWidget);
      expect(find.text('Please enter contact number'), findsOneWidget);
      expect(vm.currentStep, equals(0));
    });

    testWidgets('Full name validation checks letters, spaces, and length 3-50',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      final nameFinder = find.byType(TextField).at(0);
      final phoneFinder = find.byType(TextField).at(1);

      // Enter numbers in name
      await tester.enterText(nameFinder, 'John123');
      await tester.enterText(phoneFinder, '+919876543210');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
          find.text('Full name must contain only letters and spaces'), findsOneWidget);
      expect(vm.currentStep, equals(0));

      // Enter less than 3 chars (onChanged fires with enterText)
      await tester.enterText(nameFinder, 'Jo');
      await tester.pumpAndSettle();
      expect(
          find.text('Full name must be between 3 and 50 characters'), findsOneWidget);

      // Enter more than 50 chars
      await tester.enterText(nameFinder, 'A' * 51);
      await tester.pumpAndSettle();
      expect(
          find.text('Full name must be between 3 and 50 characters'), findsOneWidget);

      // Enter valid name
      await tester.enterText(nameFinder, 'John Doe');
      await tester.pumpAndSettle();
      expect(
          find.text('Full name must be between 3 and 50 characters'), findsNothing);
      expect(
          find.text('Full name must contain only letters and spaces'), findsNothing);
    });

    testWidgets(
        'Contact number validation checks +91 prefix, 10 digits, and starts with 6, 7, 8, or 9',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      final nameFinder = find.byType(TextField).at(0);
      final phoneFinder = find.byType(TextField).at(1);

      await tester.enterText(nameFinder, 'Jane Doe');

      // Missing +91
      await tester.enterText(phoneFinder, '9876543210');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
          find.text('Contact number must start with +91'), findsOneWidget);
      expect(vm.currentStep, equals(0));

      // Just +91
      await tester.enterText(phoneFinder, '+91');
      await tester.pumpAndSettle();
      expect(
          find.text('Contact number must include 10 digits after +91'), findsOneWidget);

      // Non-digits after +91
      await tester.enterText(phoneFinder, '+9198765abcde');
      await tester.pumpAndSettle();
      expect(
          find.text('Contact number must contain only digits after +91'), findsOneWidget);

      // Less than 10 digits after +91
      await tester.enterText(phoneFinder, '+91987654321');
      await tester.pumpAndSettle();
      expect(
          find.text('Contact number must be exactly 10 digits after +91'), findsOneWidget);

      // More than 10 digits after +91
      await tester.enterText(phoneFinder, '+9198765432100');
      await tester.pumpAndSettle();
      expect(
          find.text('Contact number must be exactly 10 digits after +91'), findsOneWidget);

      // Starts with 5 (invalid starting digit)
      await tester.enterText(phoneFinder, '+915123456789');
      await tester.pumpAndSettle();
      expect(
          find.text('Contact number must start with 6, 7, 8, or 9'), findsOneWidget);

      // Starts with 6, 7, 8, or 9 (valid)
      await tester.enterText(phoneFinder, '+916123456789');
      await tester.pumpAndSettle();
      expect(
          find.text('Contact number must start with 6, 7, 8, or 9'), findsNothing);
      expect(
          find.text('Contact number must be exactly 10 digits after +91'), findsNothing);
      expect(
          find.text('Contact number must start with +91'), findsNothing);
    });

    testWidgets(
        'Valid full name and contact number allows proceeding to Location step',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      final nameFinder = find.byType(TextField).at(0);
      final phoneFinder = find.byType(TextField).at(1);

      await tester.enterText(nameFinder, 'Rahul Sharma');
      await tester.enterText(phoneFinder, '+919876543210');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter full name'), findsNothing);
      expect(find.text('Please enter contact number'), findsNothing);
      expect(vm.currentStep, equals(1));
      expect(find.text('Location Details'), findsOneWidget);
    });
  });
}
