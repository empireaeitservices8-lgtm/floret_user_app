import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/features/profile/screen/pickup_bill_bottom_sheet.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:shared_preferences/shared_preferences.dart';

class MockRescheduleApiService extends ApiService {
  dynamic capturedPickupId;
  DateTime? capturedPickupDate;
  String? capturedStatus;

  final Map<String, dynamic> sampleBackendData = {
    'id': 358,
    'user': 431,
    'status': 'rescheduled',
    'waste_type': 'Sanitary waste',
    'items_description': 'General household waste',
    'pickup_date': '2026-10-30',
    'pickup_time_slot': '9:00 AM – 12:00 PM',
    'street': 'Sunset Blvd',
    'city': 'Thiruvananthapuram',
    'zip_code': '695001',
    'contact_number': '+919995723146',
    'full_name': 'nicy nicy',
  };

  @override
  Future<Response> reschedulePickup({
    required dynamic pickupId,
    required DateTime pickupDate,
    String? pickupTimeSlot,
    String? token,
  }) async {
    capturedPickupId = pickupId;
    capturedPickupDate = pickupDate;
    capturedStatus = 'rescheduled';
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/$pickupId/'),
      statusCode: 200,
      data: {
        ...sampleBackendData,
        'id': pickupId,
        'pickup_date':
            '${pickupDate.year}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}',
        'status': 'rescheduled',
      },
    );
  }

  @override
  Future<Response> getPickups({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/'),
      statusCode: 200,
      data: [sampleBackendData],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
    await SpHelper.saveString(sp_keys.keyToken, 'mock_token');
    await SpHelper.saveString(sp_keys.keyUserId, '431');
    OrderStore.instance.resetForLogout();
    await OrderStore.instance.loadForUser('431');
  });

  group('Reschedule Pickup & Visual Order Card Tests', () {
    testWidgets(
        '1. Rescheduled card displays exact layout from screenshot (Badge, Unpaid, Cancel, Reschedule, View Bill)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockApi = MockRescheduleApiService();
      final repo = ProfileRepository(apiService: mockApi);

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Header details
      expect(find.text('Sanitary waste'), findsOneWidget);
      expect(find.text('WC-358'), findsOneWidget);

      // Status badge
      expect(find.text('RESCHEDULED'), findsOneWidget);
      expect(find.byIcon(Icons.edit_calendar_outlined), findsWidgets);

      // Date and Address
      expect(find.text('30 Oct 2026'), findsOneWidget);
      expect(find.text('Sunset Blvd, Thiruvananthapuram'), findsOneWidget);

      // Row 1 elements
      expect(find.text('Unpaid'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reschedule'), findsWidgets);

      // Row 2 element
      expect(find.text('View Bill'), findsOneWidget);

      // Rescheduled orders do not show 'Track Order'
      expect(find.text('Track Order'), findsNothing);

      // Tapping View Bill opens bottom sheet showing Bill Pending Generation matching user screenshot
      await tester.tap(find.text('View Bill'));
      await tester.pumpAndSettle();
      expect(find.byType(PickupBillBottomSheet), findsOneWidget);
      expect(find.text('Pickup Bill Details'), findsOneWidget);
      expect(find.text('Bill Pending Generation'), findsOneWidget);
      expect(
        find.text(
            'The collector has not yet submitted the live bill breakdown for this pickup. The live breakdown will be displayed here as soon as the collector submits the bill.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Bill Pending Generation'), findsNothing);
    });

    testWidgets(
        '2. Tapping Reschedule opens DatePicker with past dates disabled and calls PATCH API',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockApi = MockRescheduleApiService();
      final repo = ProfileRepository(apiService: mockApi);

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Reschedule button on the card (the last 'Reschedule' text is the button inside the card)
      final rescheduleBtn = find.text('Reschedule').last;
      await tester.ensureVisible(rescheduleBtn);
      await tester.tap(rescheduleBtn);
      await tester.pumpAndSettle();

      // Date picker dialog is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Verify past dates are disabled (today is firstDate)
      final datePickerFinder = find.byType(DatePickerDialog);
      final DatePickerDialog datePicker = tester.widget(datePickerFinder);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(datePicker.firstDate.isBefore(today), isFalse);

      // Tap 'OK' to select date
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // API was called with pickupId and new pickupDate
      expect(mockApi.capturedPickupId, equals(358));
      expect(mockApi.capturedStatus, equals('rescheduled'));
      expect(mockApi.capturedPickupDate, isNotNull);

      // Confirmation SnackBar is shown
      expect(find.textContaining('Pickup rescheduled to'), findsOneWidget);
    });
  });
}
