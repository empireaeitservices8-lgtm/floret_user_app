import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/services/api_service.dart';

class MockSlotsApiService extends ApiService {
  bool availableSlotsApiCalled = false;
  String? capturedDistrict;
  String? capturedLocalBody;
  dynamic capturedReschedulePickupId;
  DateTime? capturedRescheduleDate;
  String? capturedRescheduleTimeSlot;

  MockSlotsApiService() : super(dio: Dio());

  @override
  Future<Response> getAvailablePickupSlots({
    String? district,
    String? localBody,
    String? token,
  }) async {
    availableSlotsApiCalled = true;
    capturedDistrict = district;
    capturedLocalBody = localBody;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

    return Response(
      requestOptions: RequestOptions(path: '/api/available-pickup-slots/'),
      statusCode: 200,
      data: {
        'total_available': 1,
        'slots': [
          {
            'id': 99,
            'date': tomorrowStr,
            'time_slot': '10:00 AM - 12:00 PM',
            'available_spots': 10,
            'district': district ?? 'Thiruvananthapuram',
            'local_body': localBody ?? 'Varkala Municipality',
          }
        ],
      },
    );
  }

  @override
  Future<Response> getPickups({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/'),
      statusCode: 200,
      data: [
        {
          'id': 161,
          'booking_id': 'WC-161',
          'status': 'Pending',
          'waste_type': 'Sanitary waste',
          'pickup_date':
              DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          'street': 'Paruthippara',
          'city': 'Thiruvananthapuram',
          'district': 'Thiruvananthapuram',
          'local_body': 'Varkala Municipality',
        }
      ],
    );
  }

  @override
  Future<Response> reschedulePickup({
    required dynamic pickupId,
    required DateTime pickupDate,
    String? pickupTimeSlot,
    String? token,
  }) async {
    capturedReschedulePickupId = pickupId;
    capturedRescheduleDate = pickupDate;
    capturedRescheduleTimeSlot = pickupTimeSlot;
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/$pickupId/'),
      statusCode: 200,
      data: {'status': 'success'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'OrderHistoryScreen calls available-pickup-slots API when tapping Reschedule',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockApi = MockSlotsApiService();
    final repo = ProfileRepository(apiService: mockApi);

    await tester.pumpWidget(
      MaterialApp(
        home: OrderHistoryScreen(
          repository: repo,
          initialFilterIndex: 0,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify order card is visible with Reschedule button icon
    final rescheduleFinder = find.byIcon(Icons.edit_calendar_outlined).first;
    expect(rescheduleFinder, findsOneWidget);

    // Tap on Reschedule button
    await tester.tap(rescheduleFinder);
    await tester.pump();

    // Verify available-pickup-slots API was called
    expect(mockApi.availableSlotsApiCalled, isTrue);

    // DatePicker dialog should be displayed
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Tap OK on the DatePicker to confirm date selection
    final okFinder = find.text('OK');
    expect(okFinder, findsOneWidget);
    await tester.tap(okFinder);
    await tester.pumpAndSettle();

    // Verify reschedulePickup was called on mockApi
    expect(mockApi.capturedRescheduleDate, isNotNull);
  });
}
