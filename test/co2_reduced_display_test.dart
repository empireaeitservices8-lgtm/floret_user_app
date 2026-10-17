import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/profile/screen/profile_screen.dart';
import 'package:floret_app/features/profile/screen/my_account_screen.dart';
import 'package:floret_app/viewmodels/profile_viewmodel.dart';
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
    test('Calculates CO₂ reduction formula correctly (pickup count × 14.3 formatted to 1 decimal place)', () {
      final orders = <OrderModel>[];

      // 0 completed pickups -> 0.0 kg
      var completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      var co2Reduced = (completedCount * 14.3).toStringAsFixed(1);
      expect(co2Reduced, '0.0');

      // 1 completed pickup -> 14.3 kg
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
      co2Reduced = (completedCount * 14.3).toStringAsFixed(1);
      expect(co2Reduced, '14.3');

      // 2 completed pickups -> 28.6 kg
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
      co2Reduced = (completedCount * 14.3).toStringAsFixed(1);
      expect(co2Reduced, '28.6');

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
      co2Reduced = (completedCount * 14.3).toStringAsFixed(1);
      expect(co2Reduced, '28.6');

      // 5 completed pickups -> 71.5 kg
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
      co2Reduced = (completedCount * 14.3).toStringAsFixed(1);
      expect(co2Reduced, '71.5');
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

    testWidgets('HomeScreen displays 28.6 kg for 2 completed pickups and auto-updates to 42.9 kg on new completed pickup',
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

      // 2 completed pickups = 28.6 kg
      expect(find.text('CO₂ Reduced'), findsOneWidget);
      expect(find.text('28.6 kg'), findsOneWidget);

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

      // Automatically updates to 42.9 kg!
      expect(find.text('42.9 kg'), findsOneWidget);
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

    testWidgets('Recycle Progress card and progress bar reflect user pickup weight dynamically (5kg per pickup)',
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

      // Initially with 0 orders: 0.0 kg / 50 kg and 0% Done
      expect(find.text('Recycle Progress'), findsOneWidget);
      expect(find.text('0.0 kg / 50 kg'), findsOneWidget);
      expect(find.text('0% Done'), findsOneWidget);

      // User has 1 pickup -> 5.0 kg / 50 kg (10% Done)
      OrderStore.instance.orders.value = [
        OrderModel(
          bookingId: 'WC-201',
          wasteType: 'Solid waste',
          pickupDate: DateTime.now(),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          userId: '101',
        ),
      ];
      await tester.pump();

      // Updates dynamically to 5.0 kg / 50 kg and 10% Done
      expect(find.text('5.0 kg / 50 kg'), findsOneWidget);
      expect(find.text('10% Done'), findsOneWidget);

      // User books 2nd pickup -> total 10.0 kg / 50 kg (20% Done)
      OrderStore.instance.orders.value = [
        ...OrderStore.instance.orders.value,
        OrderModel(
          bookingId: 'WC-202',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime.now(),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          userId: '101',
        ),
      ];
      await tester.pump();

      // Updates dynamically to 10.0 kg / 50 kg and 20% Done
      expect(find.text('10.0 kg / 50 kg'), findsOneWidget);
      expect(find.text('20% Done'), findsOneWidget);

      // User books 3rd pickup -> total 15.0 kg / 50 kg (30% Done)
      OrderStore.instance.orders.value = [
        ...OrderStore.instance.orders.value,
        OrderModel(
          bookingId: 'WC-203',
          wasteType: 'Dry waste',
          pickupDate: DateTime.now(),
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          userId: '101',
        ),
      ];
      await tester.pump();

      // Updates dynamically to 15.0 kg / 50 kg and 30% Done
      expect(find.text('15.0 kg / 50 kg'), findsOneWidget);
      expect(find.text('30% Done'), findsOneWidget);
    });

    testWidgets('ProfileScreen Carbon Saved reflects 14.3kg CO2 increment per pickup dynamically',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await SpHelper.saveString('eco_reward_points', '250');
      await OrderStore.instance.loadForUser('101');

      // 2 completed pickups -> 28.6 kg
      OrderStore.instance.orders.value = [
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
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileViewModel>(
            create: (_) => ProfileViewModel(),
            child: const ProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Carbon Saved'), findsOneWidget);
      expect(find.text('28.6 kg'), findsOneWidget);

      // Add a 3rd completed pickup -> 42.9 kg
      OrderStore.instance.orders.value = [
        ...OrderStore.instance.orders.value,
        OrderModel(
          bookingId: 'REAL-3',
          wasteType: 'Glass',
          pickupDate: DateTime(2026, 10, 3),
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
          userId: '101',
        ),
      ];
      await tester.pump();

      expect(find.text('42.9 kg'), findsOneWidget);
    });

    testWidgets('MyAccountScreen displays total pickups and updates dynamically',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');

      // 2 pickups initially
      OrderStore.instance.orders.value = [
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
          status: OrderStatus.pending,
          userId: '101',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProfileViewModel>(
            create: (_) => ProfileViewModel(),
            child: const MyAccountScreen(),
          ),
        ),
      );
      await tester.pump();

      // Total Pickups shows 2
      expect(find.text('Total Pickups'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Add 3rd pickup
      OrderStore.instance.orders.value = [
        ...OrderStore.instance.orders.value,
        OrderModel(
          bookingId: 'REAL-3',
          wasteType: 'Glass',
          pickupDate: DateTime(2026, 10, 3),
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
          userId: '101',
        ),
      ];
      await tester.pump();

      // Total Pickups updates dynamically to 3!
      expect(find.text('3'), findsOneWidget);
    });
  });
}
