import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/services/api_service.dart';

class MockRescheduledOrderApiService extends ApiService {
  final Map<String, dynamic> sampleBackendResponse;

  MockRescheduledOrderApiService({required this.sampleBackendResponse})
      : super(dio: Dio());

  @override
  Future<Response> getPickups({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/'),
      statusCode: 200,
      data: [sampleBackendResponse],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final userProvidedJson = {
    "id": 523,
    "remaining_bags": null,
    "rejection_reason": "Rescheduled: hello",
    "full_name": "nicy test",
    "email": "",
    "contact_number": "+919995723146",
    "street": "err",
    "city": "kms",
    "zip_code": "123456",
    "state": "Kerala",
    "district": "Thiruvananthapuram",
    "localbody": "Varkala Municipality",
    "ward_name": "5 - Kallazhi",
    "landmark": "",
    "pickup_date": "2026-11-17",
    "pickup_time_slot": "9:00 AM – 12:00 PM",
    "status": "rescheduled",
    "items_description": "General household waste",
    "waste_type": "Sanitary waste",
    "created_at": "2026-11-13T06:01:31.051000Z",
    "collector_name": null,
    "vehicle_name": null,
    "vehicle_number": null,
    "collector_photo": null,
    "current_latitude": null,
    "current_longitude": null,
    "tracking_started_at": null,
    "rating": null,
    "wallet_amount_used": "0.00",
    "wallet_transaction_id": null,
    "final_payable_amount": "0.00",
    "bags_used": 1,
    "user": 461,
    "zone": null
  };

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
    await SpHelper.saveString(sp_keys.keyToken, 'valid_test_token');
    await SpHelper.saveString(sp_keys.keyUserId, '461');
    await OrderStore.instance.loadForUser('461');
  });

  test('OrderModel parses rescheduled backend response including rejection_reason', () {
    final order = OrderModel.fromBackendJson(userProvidedJson);

    expect(order.id, equals(523));
    expect(order.bookingId, equals('WC-523'));
    expect(order.status, equals(OrderStatus.reschedule));
    expect(order.rawStatus, equals('rescheduled'));
    expect(order.rejectionReason, equals('Rescheduled: hello'));
    expect(order.wasteType, equals('Sanitary waste'));
    expect(order.pickupDate.year, equals(2026));
    expect(order.pickupDate.month, equals(11));
    expect(order.pickupDate.day, equals(17));
    expect(order.pickupTimeSlot, equals('9:00 AM – 12:00 PM'));
    expect(order.address, contains('err'));
    expect(order.address, contains('kms'));
    expect(order.address, contains('Thiruvananthapuram'));
  });

  testWidgets('OrderHistoryScreen displays rescheduled order and reason below location',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockApi =
        MockRescheduledOrderApiService(sampleBackendResponse: userProvidedJson);
    final repo = ProfileRepository(apiService: mockApi);

    await tester.pumpWidget(
      MaterialApp(
        home: OrderHistoryScreen(
          repository: repo,
          initialFilterIndex: 3, // Reschedule filter tab
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify booking ID is displayed
    expect(find.text('WC-523'), findsOneWidget);

    // Verify status badge shows RESCHEDULED
    expect(find.text('RESCHEDULED'), findsOneWidget);

    // Verify location is displayed
    expect(find.textContaining('err, kms, Thiruvananthapuram'), findsOneWidget);

    // Verify rejection reason is displayed below location
    expect(find.text('Rescheduled: hello'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    // Verify Cancel and Reschedule action buttons are intact
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Reschedule'), findsAtLeastNWidgets(1));
  });
}
