import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/notifications/model/notification_model.dart';
import 'package:floret_app/features/notifications/repos/notification_repository.dart';
import 'package:floret_app/features/notifications/screen/notifications_screen.dart';
import 'package:floret_app/features/notifications/viewmodel/notifications_view_model.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

class MockPickupsApiService extends ApiService {
  List<dynamic> mockResponseList = [];
  bool shouldThrowError = false;
  String? capturedToken;

  MockPickupsApiService({Dio? dio}) : super(dio: dio ?? Dio());

  @override
  Future<Response> getPickups({String? token}) async {
    capturedToken = token;
    if (shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/pickups/'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/pickups/'),
          statusCode: 500,
          data: {'error': 'Internal server error while retrieving pickups'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: '/api/pickups/'),
      statusCode: 200,
      data: mockResponseList,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
    OrderStore.instance.resetForLogout();
  });

  tearDown(() {
    OrderStore.instance.resetForLogout();
  });

  group('Order History & Pickups API Integration', () {
    test('1. Signed-in user fetches their actual bookings with authentication headers', () async {
      await SpHelper.saveString(sp_keys.keyToken, 'auth_token_user_101');
      await SpHelper.saveString(sp_keys.keyUserId, '101');

      final mockApi = MockPickupsApiService();
      mockApi.mockResponseList = [
        {
          'id': 161,
          'user': 101,
          'pickup_date': '2026-10-15',
          'pickup_time_slot': '09:00 AM - 12:00 PM',
          'status': 'Pending',
          'waste_type': 'Sanitary waste',
          'street': 'Paruthippara',
          'city': 'Thiruvananthapuram',
          'district': 'Thiruvananthapuram',
          'state': 'Kerala',
          'zip_code': '695015',
          'ward_name': 'Ward 5',
          'localbody': 'Nedumangadu Municipality',
          'landmark': 'Near Temple',
          'full_name': 'Test User',
          'contact_number': '+919876543210',
          'bags_used': 2,
        },
        {
          'id': 168,
          'user': 101,
          'pickup_date': '2026-10-15',
          'completed_at': '2026-10-13T14:30:00Z',
          'status': 'Completed',
          'waste_type': 'Solid waste',
          'street': 'Pattom',
          'city': 'Thiruvananthapuram',
          'district': 'Thiruvananthapuram',
          'state': 'Kerala',
          'zip_code': '695004',
          'full_name': 'Test User',
          'contact_number': '+919876543210',
        },
      ];

      final repo = ProfileRepository(apiService: mockApi);
      final orders = await repo.fetchOrderHistory();

      // Verify token was sent in request
      expect(mockApi.capturedToken, 'auth_token_user_101');
      expect(orders.length, 2);

      // Verify order 1 (pending)
      final order1 = orders.firstWhere((o) => o.bookingId == 'WC-161');
      expect(order1.wasteType, 'Sanitary waste');
      expect(order1.status, OrderStatus.pending);
      expect(order1.pickupDate.year, 2026);
      expect(order1.pickupDate.month, 10);
      expect(order1.pickupDate.day, 15);
      expect(order1.address, contains('Paruthippara'));
      expect(order1.fullAddress, contains('695015'));
      expect(order1.userId, '101');

      // Verify order 2 (completed)
      final order2 = orders.firstWhere((o) => o.bookingId == 'WC-168');
      expect(order2.wasteType, 'Solid waste');
      expect(order2.status, OrderStatus.completed);
      expect(order2.completedDate, isNotNull);
      expect(order2.completedDate!.day, 13);
      expect(order2.userId, '101');
    });

    test('2. User Data Isolation: Second user sees ONLY their own bookings', () async {
      // Backend returns records containing both user 101 and user 202
      final mockApi = MockPickupsApiService();
      mockApi.mockResponseList = [
        {
          'id': 1001,
          'user': 101,
          'status': 'Completed',
          'waste_type': 'Sanitary waste',
          'pickup_date': '2026-10-10',
          'street': 'User 101 Street',
        },
        {
          'id': 2002,
          'user': 202,
          'status': 'Pending',
          'waste_type': 'E-Waste',
          'pickup_date': '2026-10-14',
          'street': 'User 202 Street',
        },
      ];

      final repo = ProfileRepository(apiService: mockApi);

      // 1. Authenticate as User 101
      await SpHelper.saveString(sp_keys.keyToken, 'token_user_101');
      await SpHelper.saveString(sp_keys.keyUserId, '101');

      final ordersUser101 = await repo.fetchOrderHistory();
      expect(ordersUser101.length, 1);
      expect(ordersUser101.first.bookingId, 'WC-1001');
      expect(ordersUser101.any((o) => o.bookingId == 'WC-2002'), isFalse);

      // 2. Switch to User 202
      await SpHelper.saveString(sp_keys.keyToken, 'token_user_202');
      await SpHelper.saveString(sp_keys.keyUserId, '202');

      final ordersUser202 = await repo.fetchOrderHistory();
      expect(ordersUser202.length, 1);
      expect(ordersUser202.first.bookingId, 'WC-2002');
      expect(ordersUser202.any((o) => o.bookingId == 'WC-1001'), isFalse);
    });

    test('3. Deduplication: Remote and local bookings overlap correctly without duplicates', () {
      final repo = ProfileRepository();

      // Local booking WC-161 is still pending locally
      final localOrder = OrderModel(
        bookingId: 'WC-161',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Paruthippara',
        fullAddress: 'Full Paruthippara',
        contact: 'User',
        status: OrderStatus.pending,
        userId: '101',
      );
      // Local newly added booking not on backend yet
      final localOnlyOrder = OrderModel(
        bookingId: 'WC-999',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 20),
        address: 'Local street',
        fullAddress: 'Local full address',
        contact: 'User',
        status: OrderStatus.pending,
        userId: '101',
      );

      OrderStore.instance.orders.value = [localOrder, localOnlyOrder];

      // Remote returns WC-161 updated to COMPLETED on server
      final remoteOrderUpdated = OrderModel(
        bookingId: 'WC-161',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        completedDate: DateTime(2026, 10, 15),
        address: 'Paruthippara',
        fullAddress: 'Full Paruthippara',
        contact: 'User',
        status: OrderStatus.completed,
        userId: '101',
      );

      OrderStore.instance.mergeRemoteOrders([remoteOrderUpdated]);

      // Total orders should be 2 (no duplicates!)
      expect(OrderStore.instance.orders.value.length, 2);

      // WC-161 now has the updated status from server (Completed)
      final mergedWC161 = OrderStore.instance.orders.value
          .firstWhere((o) => o.bookingId == 'WC-161');
      expect(mergedWC161.status, OrderStatus.completed);

      // WC-999 (local only booking) is preserved!
      final preservedWC999 = OrderStore.instance.orders.value
          .firstWhere((o) => o.bookingId == 'WC-999');
      expect(preservedWC999.status, OrderStatus.pending);
    });

    testWidgets('4. OrderHistoryScreen displays actual bookings, filters, and supports refresh',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'test_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');

      final mockApi = MockPickupsApiService();
      mockApi.mockResponseList = [
        {
          'id': 501,
          'user': 101,
          'status': 'Completed',
          'waste_type': 'Sanitary waste',
          'pickup_date': '2026-10-12',
          'street': 'Kowdiar',
          'city': 'Thiruvananthapuram',
        },
        {
          'id': 502,
          'user': 101,
          'status': 'Pending',
          'waste_type': 'Solid waste',
          'pickup_date': '2026-10-16',
          'street': 'Palayam',
          'city': 'Thiruvananthapuram',
        },
        {
          'id': 503,
          'user': 101,
          'status': 'Rescheduled',
          'waste_type': 'Glass waste',
          'pickup_date': '2026-10-18',
          'street': 'Vazhuthacaud',
          'city': 'Thiruvananthapuram',
        },
        {
          'id': 504,
          'user': 101,
          'status': 'Cancelled',
          'waste_type': 'Sanitary waste',
          'pickup_date': '2026-10-08',
          'street': 'Pattom',
          'city': 'Thiruvananthapuram',
        },
      ];

      final repo = ProfileRepository(apiService: mockApi);

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // All 4 orders present in 'All' tab
      expect(find.text('WC-501'), findsOneWidget);
      expect(find.text('WC-502'), findsOneWidget);
      expect(find.text('WC-503'), findsOneWidget);
      expect(find.text('WC-504'), findsOneWidget);

      // Filter: Completed
      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();
      expect(find.text('WC-501'), findsOneWidget);
      expect(find.text('WC-502'), findsNothing);

      // Filter: Pending
      await tester.tap(find.text('Pending').first);
      await tester.pumpAndSettle();
      expect(find.text('WC-502'), findsOneWidget);
      expect(find.text('WC-501'), findsNothing);

      // Filter: Reschedule
      await tester.ensureVisible(find.text('Reschedule').first);
      await tester.tap(find.text('Reschedule').first);
      await tester.pumpAndSettle();
      expect(find.text('WC-503'), findsOneWidget);

      // Filter: Cancelled
      await tester.ensureVisible(find.text('Cancelled').first);
      await tester.tap(find.text('Cancelled').first);
      await tester.pumpAndSettle();
      expect(find.text('WC-504'), findsOneWidget);
    });

    testWidgets('5. API failure displays error state with Retry button (not silent empty result)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'test_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');
      OrderStore.instance.orders.value = [];

      final mockApi = MockPickupsApiService();
      mockApi.shouldThrowError = true;

      final repo = ProfileRepository(apiService: mockApi);

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Should display Error State, NOT "No orders found"
      expect(find.text('Unable to Load Orders'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('No orders found'), findsNothing);

      // Recover and tap Retry
      mockApi.shouldThrowError = false;
      mockApi.mockResponseList = [
        {
          'id': 777,
          'user': 101,
          'status': 'Pending',
          'waste_type': 'Sanitary waste',
          'pickup_date': '2026-10-15',
          'street': 'Statue',
          'city': 'Thiruvananthapuram',
        }
      ];

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Order loaded after retry
      expect(find.text('WC-777'), findsOneWidget);
      expect(find.text('Unable to Load Orders'), findsNothing);
    });
  });

  group('Notifications & Pickup Events Integration', () {
    test('6. Notifications reflect all pickup events: confirmed, rescheduled, cancelled, delivered',
        () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_101');
      await OrderStore.instance.loadForUser('user_101');

      final orderConfirmed = OrderModel(
        bookingId: 'WC-301',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Pattom',
        fullAddress: 'TC 14/1250, Pattom',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_101',
      );

      final orderRescheduled = OrderModel(
        bookingId: 'WC-302',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 18),
        address: 'Kowdiar',
        fullAddress: 'Kowdiar Avenue',
        contact: 'User',
        status: OrderStatus.reschedule,
        userId: 'user_101',
      );

      final orderDelivered = OrderModel(
        bookingId: 'WC-303',
        wasteType: 'Solid waste',
        pickupDate: DateTime(2026, 10, 15),
        completedDate: DateTime(2026, 10, 13),
        address: 'Paruthippara',
        fullAddress: 'KRAA/11, Paruthippara',
        contact: 'User',
        status: OrderStatus.completed,
        userId: 'user_101',
      );

      final orderCancelled = OrderModel(
        bookingId: 'WC-304',
        wasteType: 'Glass waste',
        pickupDate: DateTime(2026, 10, 10),
        address: 'Sasthamangalam',
        fullAddress: 'Sasthamangalam Road',
        contact: 'User',
        status: OrderStatus.cancelled,
        userId: 'user_101',
      );

      OrderStore.instance.orders.value = [
        orderConfirmed,
        orderRescheduled,
        orderDelivered,
        orderCancelled,
      ];

      final vm = NotificationsViewModel();
      await vm.loadNotifications();

      // Check Upcoming tab
      vm.setTabIndex(1);
      final upcoming = vm.filteredNotifications;
      expect(upcoming.length, 2);
      expect(upcoming.any((n) => n.title == 'Pickup Scheduled • WC-301'), isTrue);
      expect(upcoming.any((n) => n.title == 'Pickup Rescheduled • WC-302'), isTrue);

      // Check Delivered tab
      vm.setTabIndex(2);
      final delivered = vm.filteredNotifications;
      expect(delivered.length, 1);
      expect(delivered.first.title, 'Pickup Delivered • WC-303');
      expect(delivered.first.time, '13 Oct 2026');

      // Check All tab
      vm.setTabIndex(0);
      final all = vm.filteredNotifications;
      expect(all.length, 4);
      expect(all.any((n) => n.title == 'Pickup Cancelled • WC-304'), isTrue);
    });

    test('7. Mark as read persists locally for authenticated user', () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_persist');
      await OrderStore.instance.loadForUser('user_persist');

      final orderPending = OrderModel(
        bookingId: 'WC-401',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Pattom',
        fullAddress: 'Pattom full',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_persist',
      );

      OrderStore.instance.orders.value = [orderPending];

      final repo = NotificationRepository();
      final vm = NotificationsViewModel(repository: repo);
      await vm.loadNotifications();

      // Initially unread
      expect(vm.notifications.first.isRead, isFalse);

      // Mark as read
      await vm.markAsRead('WC-401');
      expect(vm.notifications.first.isRead, isTrue);

      // Create a brand new ViewModel instance simulating screen reopen
      final vmNew = NotificationsViewModel(repository: repo);
      await vmNew.loadNotifications();

      // Persisted read state should remain true
      expect(vmNew.notifications.first.isRead, isTrue);
    });

    test('8. Backend notification endpoint absence is documented and returns empty list', () async {
      final repo = NotificationRepository();
      final remoteNotifications = await repo.fetchNotifications();
      expect(remoteNotifications, isEmpty);
    });
  });
}
