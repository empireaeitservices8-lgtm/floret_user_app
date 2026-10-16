import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OrderStore.instance.resetForLogout();
    await SpHelper.clearUserData();
  });

  tearDown(() async {
    SharedPreferences.setMockInitialValues({});
    OrderStore.instance.resetForLogout();
    await SpHelper.clearUserData();
  });

  group('CO₂ Reduced Value Display Unit & Widget Tests', () {
    test('Calculates CO₂ reduction formula correctly (completed count × 0.5 formatted to 1 decimal place)', () {
      final orders = <OrderModel>[];

      // 0 completed pickups -> 0.0 kg
      var completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      var co2Reduced = (completedCount * 0.5).toStringAsFixed(1);
      expect(co2Reduced, '0.0');

      // 1 completed pickup -> 0.5 kg
      orders.add(OrderModel(
        bookingId: 'ORD-1',
        wasteType: 'Sanitary',
        pickupDate: DateTime(2026, 10, 1),
        address: 'Test Addr',
        fullAddress: 'Test Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
      ));
      completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      co2Reduced = (completedCount * 0.5).toStringAsFixed(1);
      expect(co2Reduced, '0.5');

      // 2 completed pickups -> 1.0 kg
      orders.add(OrderModel(
        bookingId: 'ORD-2',
        wasteType: 'Dry',
        pickupDate: DateTime(2026, 10, 2),
        address: 'Test Addr',
        fullAddress: 'Test Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
      ));
      completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      co2Reduced = (completedCount * 0.5).toStringAsFixed(1);
      expect(co2Reduced, '1.0');

      // Add non-completed pickups (pending, cancelled, reschedule) -> should still be 2 completed
      orders.addAll([
        OrderModel(
          bookingId: 'ORD-3',
          wasteType: 'E-Waste',
          pickupDate: DateTime(2026, 10, 3),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.pending,
        ),
        OrderModel(
          bookingId: 'ORD-4',
          wasteType: 'Glass',
          pickupDate: DateTime(2026, 10, 4),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.cancelled,
        ),
        OrderModel(
          bookingId: 'ORD-5',
          wasteType: 'Metal',
          pickupDate: DateTime(2026, 10, 5),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.reschedule,
        ),
      ]);
      completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      co2Reduced = (completedCount * 0.5).toStringAsFixed(1);
      expect(co2Reduced, '1.0');

      // 5 completed pickups -> 2.5 kg
      orders.addAll([
        OrderModel(
          bookingId: 'ORD-6',
          wasteType: 'Sanitary',
          pickupDate: DateTime(2026, 10, 6),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.completed,
        ),
        OrderModel(
          bookingId: 'ORD-7',
          wasteType: 'Dry',
          pickupDate: DateTime(2026, 10, 7),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.completed,
        ),
        OrderModel(
          bookingId: 'ORD-8',
          wasteType: 'Organic',
          pickupDate: DateTime(2026, 10, 8),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.completed,
        ),
      ]);
      completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      co2Reduced = (completedCount * 0.5).toStringAsFixed(1);
      expect(co2Reduced, '2.5');
    });

    test('OrderModel.fromBackendJson correctly maps various backend completed statuses', () {
      final backendStatuses = [
        {'id': 1, 'status': 'completed'},
        {'id': 2, 'status': 'complete'},
        {'id': 3, 'status': 'delivered'},
        {'id': 4, 'status': 'collected'},
        {'id': 5, 'status': 'picked_up'},
        {'id': 6, 'status': 'picked up'},
        {'id': 7, 'status': 'done'},
        {'id': 8, 'status': 'finished'},
        {'id': 9, 'is_completed': true},
        {'id': 10, 'is_collected': true},
      ];

      for (final json in backendStatuses) {
        final order = OrderModel.fromBackendJson(json);
        expect(order.status, OrderStatus.completed,
            reason: 'Expected $json to be mapped to OrderStatus.completed');
      }

      // Non-completed statuses
      expect(OrderModel.fromBackendJson({'id': 11, 'status': 'pending'}).status, OrderStatus.pending);
      expect(OrderModel.fromBackendJson({'id': 12, 'status': 'cancelled'}).status, OrderStatus.cancelled);
      expect(OrderModel.fromBackendJson({'id': 13, 'status': 'rescheduled'}).status, OrderStatus.reschedule);
    });

    testWidgets('HomeScreen displays 0.0 kg when user has zero completed pickups',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');
      OrderStore.instance.orders.value = [];

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('CO₂ Reduced'), findsOneWidget);
      expect(find.text('0.0 kg'), findsOneWidget);
    });

    testWidgets('HomeScreen displays 1.0 kg for 2 completed pickups and auto-updates to 1.5 kg on new completed pickup',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');

      // Initially 2 completed pickups (plus 1 pending)
      OrderStore.instance.mergeRemoteOrders([
        OrderModel(
          bookingId: 'REAL-1',
          wasteType: 'Sanitary',
          pickupDate: DateTime(2026, 10, 1),
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
          userId: '101',
        ),
        OrderModel(
          bookingId: 'REAL-2',
          wasteType: 'Dry',
          pickupDate: DateTime(2026, 10, 2),
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
          userId: '101',
        ),
        OrderModel(
          bookingId: 'REAL-3',
          wasteType: 'E-Waste',
          pickupDate: DateTime(2026, 10, 3),
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.pending,
          userId: '101',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // 2 completed pickups = 1.0 kg
      expect(find.text('CO₂ Reduced'), findsOneWidget);
      expect(find.text('1.0 kg'), findsOneWidget);

      // Now an order status updates or a 3rd completed pickup arrives
      OrderStore.instance.orders.value = [
        ...OrderStore.instance.orders.value,
        OrderModel(
          bookingId: 'REAL-4',
          wasteType: 'Organic',
          pickupDate: DateTime(2026, 10, 4),
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
          userId: '101',
        ),
      ];

      await tester.pump();

      // Automatically updates to 1.5 kg!
      expect(find.text('1.5 kg'), findsOneWidget);
    });

    testWidgets('HomeScreen preserves Eco Points card while displaying CO₂ Reduced',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');
      OrderStore.instance.orders.value = [];

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Climate Impact'), findsOneWidget);
      expect(find.text('CO₂ Reduced'), findsOneWidget);
      expect(find.text('Eco Points'), findsOneWidget);
    });
  });
}
