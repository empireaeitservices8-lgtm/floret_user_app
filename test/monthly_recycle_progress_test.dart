import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/home/viewmodel/home_view_model.dart';
import 'package:floret_app/features/home/model/home_model.dart';
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

  group('Monthly Recycle Progress Tests', () {
    test('HomeViewModel.getUserPickupWeight filters by month and changes at start of each month', () {
      final vm = HomeViewModel();

      final pastMonthOrder = OrderModel(
        bookingId: 'ORD-PAST',
        wasteType: 'Sanitary',
        pickupDate: DateTime(2026, 9, 20),
        completedDate: DateTime(2026, 9, 21),
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
      );

      final currentMonthOrder1 = OrderModel(
        bookingId: 'ORD-CURR-1',
        wasteType: 'Sanitary',
        pickupDate: DateTime(2026, 10, 2),
        completedDate: DateTime(2026, 10, 2),
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
      );

      final currentMonthOrder2 = OrderModel(
        bookingId: 'ORD-CURR-2',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 10),
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
      );

      final nextMonthOrder = OrderModel(
        bookingId: 'ORD-NEXT',
        wasteType: 'Sanitary',
        pickupDate: DateTime(2026, 11, 1),
        completedDate: DateTime(2026, 11, 1),
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
      );

      final allOrders = [
        pastMonthOrder,
        currentMonthOrder1,
        currentMonthOrder2,
        nextMonthOrder,
      ];

      // In October 2026, only currentMonthOrder1 & currentMonthOrder2 count (2 * 5kg = 10kg)
      final octWeight = vm.getUserPickupWeight(allOrders, DateTime(2026, 10, 15));
      expect(octWeight, 10.0);

      // In November 2026 (starting of next month), October orders reset and only November order counts (5kg)
      final novWeight = vm.getUserPickupWeight(allOrders, DateTime(2026, 11, 1));
      expect(novWeight, 5.0);

      // In December 2026, with no December orders, weight resets to 0.0kg
      final decWeight = vm.getUserPickupWeight(allOrders, DateTime(2026, 12, 1));
      expect(decWeight, 0.0);
    });

    testWidgets('HomeScreen Recycle Progress card counts only current month orders', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');

      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 15);

      // Seed orders: 1 from last month, 1 from this month
      final pastOrder = OrderModel(
        bookingId: 'OLD-1',
        wasteType: 'Sanitary',
        pickupDate: lastMonth,
        completedDate: lastMonth,
        address: 'Test Addr',
        fullAddress: 'Test Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
        userId: '101',
      );
      final currentOrder = OrderModel(
        bookingId: 'CURR-1',
        wasteType: 'Dry waste',
        pickupDate: now,
        address: 'Test Addr',
        fullAddress: 'Test Full Addr',
        contact: 'User',
        status: OrderStatus.completed,
        userId: '101',
      );

      OrderStore.instance.mergeRemoteOrders([pastOrder, currentOrder]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // Recycle Progress should reflect only this month's pickup (5.0 kg / 50 kg -> 10% Done)
      expect(find.text('Recycle Progress'), findsOneWidget);
      expect(find.text('5.0 kg / 50 kg'), findsOneWidget);
      expect(find.text('10% Done'), findsOneWidget);

      // CO2 Reduced (other functions untouched) still counts all completed pickups (2 pickups * 14.3 = 28.6 kg)
      expect(find.text('CO₂ Reduced'), findsOneWidget);
      expect(find.text('28.6 kg'), findsOneWidget);
    });

    testWidgets('Recycle Progress percentage caps at 100% even if user pickup weight exceeds 50kg', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyToken, 'valid_token');
      await SpHelper.saveString(sp_keys.keyUserId, '101');
      await OrderStore.instance.loadForUser('101');

      final now = DateTime.now();

      // Create orders totaling 60kg (12 pickups * 5kg) in current month
      final heavyOrders = List.generate(
        12,
        (i) => OrderModel(
          bookingId: 'HEAVY-$i',
          wasteType: 'Dry waste',
          pickupDate: now,
          address: 'Test Addr',
          fullAddress: 'Test Full Addr',
          contact: 'User',
          status: OrderStatus.completed,
          userId: '101',
        ),
      );

      OrderStore.instance.mergeRemoteOrders(heavyOrders);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // 60kg / 50kg should show 100% Done (not 120%)
      expect(find.text('Recycle Progress'), findsOneWidget);
      expect(find.text('60.0 kg / 50 kg'), findsOneWidget);
      expect(find.text('100% Done'), findsOneWidget);
      expect(find.text('Goal Achieved! 🎉'), findsOneWidget);
    });

    test('HomeOverviewModel parses total_recycled_weight: 25.0 and HomeViewModel reflects it in getUserPickupWeight', () {
      final json = {
        'username': '919995723146_639',
        'pending_bills': 0,
        'scheduled_pickups': 0,
        'total_recycled_weight': 25.0,
        'message': 'Welcome back, 919995723146_639!',
      };

      final overview = HomeOverviewModel.fromJson(json);
      expect(overview.totalRecycledWeight, equals(25.0));

      final vm = HomeViewModel();
      expect(vm.getUserPickupWeight(), equals(0.0));
    });
  });
}

