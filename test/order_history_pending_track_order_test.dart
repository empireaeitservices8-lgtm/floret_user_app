import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_android/geocoding_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/map/screen/location_picker_map_screen.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

class MockApi extends ApiService {
  List<dynamic> pickups = [];

  MockApi() : super(dio: Dio());

  @override
  Future<Response> getPickups({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/'),
      statusCode: 200,
      data: pickups,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
    OrderStore.instance.resetForLogout();
    GeocodingAndroidFactory.registerWith();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geocoding'),
      (MethodCall methodCall) async {
        return [];
      },
    );
  });

  tearDown(() {
    OrderStore.instance.resetForLogout();
  });

  testWidgets(
      'Pending orders show Unpaid badge, Track Order navigates to LocationPickerMapScreen, picked & paid in Completed, unpaid in Pending',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await SpHelper.saveString(sp_keys.keyToken, 'token_xyz');
    await SpHelper.saveString(sp_keys.keyUserId, '396');

    final mockApi = MockApi();
    mockApi.pickups = [
      // 1. Accepted, Unpaid
      {
        'id': 165,
        'user': 396,
        'pickup_date': '2026-10-14',
        'status': 'Accepted',
        'payment_status': 'unpaid',
        'waste_type': 'Sanitary waste',
        'street': 'pandaraparambil, kochi',
      },
      // 2. Picked and Unpaid
      {
        'id': 172,
        'user': 396,
        'pickup_date': '2026-10-14',
        'status': 'Picked',
        'payment_status': 'unpaid',
        'waste_type': 'Sanitary waste',
        'street': 'gsgshbsvnskbsbndn, Thiruvananthapuram',
      },
      // 3. Picked and Paid
      {
        'id': 175,
        'user': 396,
        'pickup_date': '2026-10-14',
        'status': 'Picked',
        'payment_status': 'paid',
        'waste_type': 'Sanitary waste',
        'street': 'MG Road, Kochi',
      },
      // 4. Pending, Unpaid
      {
        'id': 176,
        'user': 396,
        'pickup_date': '2026-10-14',
        'status': 'Pending',
        'payment_status': 'unpaid',
        'waste_type': 'Sanitary waste',
        'street': 'Edappally, Kochi',
      },
    ];

    final repo = ProfileRepository(apiService: mockApi);

    await tester.pumpWidget(
      MaterialApp(
        home: OrderHistoryScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    // In 'All' tab, all orders should be present
    expect(find.text('WC-165'), findsOneWidget);
    expect(find.text('WC-172'), findsOneWidget);
    expect(find.text('WC-175'), findsOneWidget);
    expect(find.text('WC-176'), findsOneWidget);

    // 1. Check Completed Tab: Only picked & paid (WC-175) should be under Completed
    await tester.tap(find.text('Completed').first);
    await tester.pumpAndSettle();

    expect(find.text('WC-175'), findsOneWidget); // Picked and Paid -> Completed
    expect(find.text('WC-165'), findsNothing);
    expect(find.text('WC-172'), findsNothing);
    expect(find.text('WC-176'), findsNothing);

    // 2. Check Pending Tab:
    // Unpaid orders (WC-165, WC-172 [picked but unpaid], WC-176) should show under Pending
    await tester.tap(find.text('Pending').first);
    await tester.pumpAndSettle();

    expect(find.text('WC-165'), findsOneWidget); // Accepted & Unpaid -> Pending
    expect(find.text('WC-172'), findsOneWidget); // Picked & Unpaid -> Pending
    expect(find.text('WC-176'), findsOneWidget); // Pending & Unpaid -> Pending
    expect(find.text('WC-175'), findsNothing); // Picked & Paid -> NOT in Pending

    // Verify Unpaid badge is shown
    expect(find.text('Unpaid'), findsWidgets);

    // 3. Verify Track Order button under Pending navigates to LocationPickerMapScreen (same as registration)
    expect(find.text('Track Order'), findsWidgets);
    await tester.tap(find.text('Track Order').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LocationPickerMapScreen), findsOneWidget);
    expect(find.text('Track Order'), findsWidgets);
  });
}
