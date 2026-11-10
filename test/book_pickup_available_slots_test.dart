import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/booking/model/pickup_slot_model.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'registration_address': 'Sunset Blvd',
      'registration_city': 'Thiruvananthapuram',
      'registration_zip_code': '695001',
    });
  });

  group('Available Pickup Slots Tests', () {
    test('PickupSlotModel parses JSON correctly matching API response', () {
      final json = {
        "id": 26,
        "date": "2026-11-10",
        "time_slot": "10:00 AM - 12:00 AM",
        "available_spots": 10,
        "district": "Thiruvananthapuram",
        "local_body": "Nedumangadu Municipality"
      };

      final slot = PickupSlotModel.fromJson(json);
      expect(slot.id, equals(26));
      expect(slot.date, equals('2026-11-10'));
      expect(slot.timeSlot, equals('10:00 AM - 12:00 AM'));
      expect(slot.availableSpots, equals(10));
      expect(slot.district, equals('Thiruvananthapuram'));
      expect(slot.localBody, equals('Nedumangadu Municipality'));
      expect(slot.parsedDate, equals(DateTime(2026, 11, 10)));

      final respJson = {
        "total_available": 1,
        "slots": [json]
      };
      final resp = AvailablePickupSlotsResponse.fromJson(respJson);
      expect(resp.totalAvailable, equals(1));
      expect(resp.slots.length, equals(1));
      expect(resp.slots.first.id, equals(26));
    });

    testWidgets(
        'Tapping Select Pickup Date calls available pickup slots and selected date shows in color',
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

      // Verify unselected text color is grey
      final unselectedText =
          tester.widget<Text>(find.text('Select Pickup Date'));
      expect(unselectedText.style?.color, equals(const Color(0xFF94A3B8)));

      // Tap on Date Picker field (invokes API and opens date picker dialog)
      await tester.tap(find.text('Select Pickup Date'));
      await tester.pumpAndSettle();

      // Verify DatePickerDialog is displayed with green theme
      final datePickerFinder = find.byType(DatePickerDialog);
      expect(datePickerFinder, findsOneWidget);

      final themeWidget = tester.widget<Theme>(
        find
            .ancestor(
              of: datePickerFinder,
              matching: find.byType(Theme),
            )
            .first,
      );
      expect(themeWidget.data.colorScheme.primary,
          equals(const Color(0xFF182236)));

      // Verify date in circle is always visible (white text on selected black circle)
      final datePickerTheme = themeWidget.data.datePickerTheme;
      expect(
          datePickerTheme.todayForegroundColor?.resolve({WidgetState.selected}),
          equals(Colors.white));
      expect(
          datePickerTheme.dayForegroundColor?.resolve({WidgetState.selected}),
          equals(Colors.white));
      expect(
          datePickerTheme.dayBackgroundColor?.resolve({WidgetState.selected}),
          equals(const Color(0xFF182236)));
      expect(
          datePickerTheme.todayBackgroundColor?.resolve({WidgetState.selected}),
          equals(const Color(0xFF182236)));

      // Verify unselected matching dates display a circular badge with border
      expect(datePickerTheme.dayBackgroundColor?.resolve({}),
          equals(const Color(0xFFF1F5F9)));
      expect(datePickerTheme.dayForegroundColor?.resolve({}),
          equals(const Color(0xFF182236)));
      final shape = datePickerTheme.dayShape?.resolve({});
      expect(shape, isA<CircleBorder>());
      expect(
          (shape as CircleBorder).side.color, equals(const Color(0xFF182236)));

      // Select date and tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify selected date shows in black color
      final now = DateTime.now();
      final expectedDateStr =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final selectedTextFinder = find.text(expectedDateStr);
      expect(selectedTextFinder, findsOneWidget);

      final selectedTextWidget = tester.widget<Text>(selectedTextFinder);
      expect(selectedTextWidget.style?.color, equals(const Color(0xFF182236)));

      // Verify calendar icon is displayed
      final iconFinder = find.byIcon(Icons.calendar_month_outlined);
      expect(iconFinder, findsOneWidget);
    });
  });
}
