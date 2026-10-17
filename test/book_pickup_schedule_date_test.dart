import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'registration_address': 'Flat 4B, Green Valley',
      'registration_city': 'Thiruvananthapuram',
      'registration_zip_code': '695001',
    });
  });

  group('BookPickupScreen Schedule Pickup Date Tests', () {
    testWidgets(
        'Pickup date picker sets firstDate to today so dates before today cannot be selected',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await vm.loadSavedAddresses();
      vm.proceedToLocation();
      vm.proceedToSchedule();

      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Verify on Schedule step
      expect(find.text('Schedule Pickup'), findsOneWidget);
      expect(find.text('Select Pickup Date'), findsOneWidget);

      // Tap on Date Picker field
      await tester.tap(find.text('Select Pickup Date'));
      await tester.pumpAndSettle();

      // Verify DatePickerDialog is displayed
      final datePickerFinder = find.byType(DatePickerDialog);
      expect(datePickerFinder, findsOneWidget);

      final datePickerWidget =
          tester.widget<DatePickerDialog>(datePickerFinder);
      final now = DateTime.now();
      final expectedToday = DateTime(now.year, now.month, now.day);

      // Verify firstDate cannot be before today's date
      expect(datePickerWidget.firstDate, equals(expectedToday));
      expect(datePickerWidget.initialDate?.isBefore(expectedToday) ?? false, isFalse);

      // Tap OK button to select today
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify date is selected and shown in the field
      final d = expectedToday.day.toString().padLeft(2, '0');
      final m = expectedToday.month.toString().padLeft(2, '0');
      final y = expectedToday.year.toString();
      expect(find.text('$d-$m-$y'), findsOneWidget);
    });

    testWidgets(
        'Shows validation error if pickup date is not selected when confirming booking',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await vm.loadSavedAddresses();
      vm.proceedToLocation();
      vm.proceedToSchedule();

      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Confirm Scheduling without selecting a date
      final confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Confirm Scheduling');
      expect(confirmButtonFinder, findsOneWidget);

      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      // Verify error validation message is shown
      expect(find.text('Please select a valid pickup date'), findsOneWidget);
      expect(find.text('Please select Pickup Date before proceeding'), findsOneWidget);
    });

    testWidgets(
        'Stepper shows checkmark only in corresponding page when navigating back to previous sections',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await vm.loadSavedAddresses();

      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Step 0: Contact page
      // Contact has check, Location shows '2', Schedule shows '3'
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(1));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Navigate to Step 1: Location page
      vm.proceedToLocation();
      await tester.pumpAndSettle();

      // Step 1: Location page
      // Contact has check, Location has check, Schedule shows '3'
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsOneWidget);

      // Navigate to Step 2: Schedule page
      vm.proceedToSchedule();
      await tester.pumpAndSettle();

      // Step 2: Schedule page
      // Contact, Location, Schedule all have checks
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsNothing);

      // NOW: Go back to previous section (Step 1: Location)
      vm.goBackStep();
      await tester.pumpAndSettle();

      // Verify that Schedule NO LONGER has a check, but shows '3'
      // Only corresponding page (Contact & Location) shows checks!
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsOneWidget);

      // Go back to previous section again (Step 0: Contact)
      vm.goBackStep();
      await tester.pumpAndSettle();

      // Verify that Location and Schedule NO LONGER have checks!
      // Shows check ONLY in corresponding page (Contact)!
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(1));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
