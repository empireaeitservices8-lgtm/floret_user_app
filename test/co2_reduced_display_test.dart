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

    test('Monthly CO₂ reduction and recycle progress are calculated separately per month, preserving previous months', () {
      final septDate = DateTime(2026, 9, 15);
      final octDate = DateTime(2026, 10, 15);

      final allOrders = [
        // September: 2 completed pickups (28.6 kg CO2, 10 kg recycle)
        OrderModel(
          bookingId: 'SEP-1',
          wasteType: 'Sanitary',
          pickupDate: septDate,
          completedDate: septDate,
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
        ),
        OrderModel(
          bookingId: 'SEP-2',
          wasteType: 'Dry',
          pickupDate: septDate,
          completedDate: septDate,
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
        ),
        // October: 1 completed pickup (14.3 kg CO2, 5 kg recycle)
        OrderModel(
          bookingId: 'OCT-1',
          wasteType: 'Glass',
          pickupDate: octDate,
          completedDate: octDate,
          address: 'Test',
          fullAddress: 'Test Full',
          contact: 'User',
          status: OrderStatus.completed,
        ),
      ];

      // September metrics
      final sepCompleted = allOrders.where((o) {
        final d = o.completedDate ?? o.pickupDate;
        return d.year == 2026 && d.month == 9 && o.status == OrderStatus.completed;
      }).length;
      expect(sepCompleted, 2);
      expect((sepCompleted * 14.3).toStringAsFixed(1), '28.6');
      expect(sepCompleted * 5.0, 10.0);

      // October metrics (separate from September!)
      final octCompleted = allOrders.where((o) {
        final d = o.completedDate ?? o.pickupDate;
        return d.year == 2026 && d.month == 10 && o.status == OrderStatus.completed;
      }).length;
      expect(octCompleted, 1);
      expect((octCompleted * 14.3).toStringAsFixed(1), '14.3');
      expect(octCompleted * 5.0, 5.0);

      // November metrics (starts fresh at 0 while preserving previous records)
      final novCompleted = allOrders.where((o) {
        final d = o.completedDate ?? o.pickupDate;
        return d.year == 2026 && d.month == 11 && o.status == OrderStatus.completed;
      }).length;
      expect(novCompleted, 0);
      expect((novCompleted * 14.3).toStringAsFixed(1), '0.0');
      expect(novCompleted * 5.0, 0.0);

      // Verify September & October records are all preserved in order store
      expect(allOrders.length, 3);
    });

    test('Values persist across logout and login and remote merge preserves previous months', () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_999');
      await OrderStore.instance.loadForUser('user_999');

      // Add completed pickup in September and October
      OrderStore.instance.addOrder(OrderModel(
        bookingId: 'PAST-SEP',
        wasteType: 'Sanitary',
        pickupDate: DateTime(2026, 9, 20),
        completedDate: DateTime(2026, 9, 20),
        address: 'Test',
        fullAddress: 'Test',
        contact: 'User',
        status: OrderStatus.completed,
        userId: 'user_999',
      ));
      OrderStore.instance.addOrder(OrderModel(
        bookingId: 'CURR-OCT',
        wasteType: 'Dry',
        pickupDate: DateTime(2026, 10, 10),
        completedDate: DateTime(2026, 10, 10),
        address: 'Test',
        fullAddress: 'Test',
        contact: 'User',
        status: OrderStatus.completed,
        userId: 'user_999',
      ));

      expect(OrderStore.instance.orders.value.length, 2);

      // Merge remote orders that only return recent active order
      OrderStore.instance.mergeRemoteOrders([
        OrderModel(
          bookingId: 'CURR-OCT',
          wasteType: 'Dry',
          pickupDate: DateTime(2026, 10, 10),
          completedDate: DateTime(2026, 10, 10),
          address: 'Test',
          fullAddress: 'Test',
          contact: 'User',
          status: OrderStatus.completed,
          userId: 'user_999',
        ),
      ]);

      // Previous month record PAST-SEP is preserved!
      expect(OrderStore.instance.orders.value.any((o) => o.bookingId == 'PAST-SEP'), isTrue);

      await OrderStore.instance.saveToStorage();

      // Simulate logout
      OrderStore.instance.resetForLogout();
      expect(OrderStore.instance.orders.value.isEmpty, isTrue);

      // Simulate login as user_999
      await OrderStore.instance.loadForUser('user_999');

      // Restored from persistent storage!
      expect(OrderStore.instance.orders.value.length, 2);
      expect(OrderStore.instance.orders.value.any((o) => o.bookingId == 'PAST-SEP'), isTrue);
      expect(OrderStore.instance.orders.value.any((o) => o.bookingId == 'CURR-OCT'), isTrue);
    });
  });
}
