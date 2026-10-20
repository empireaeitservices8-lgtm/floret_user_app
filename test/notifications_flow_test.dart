import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/notifications/viewmodel/notifications_view_model.dart';
import 'package:floret_app/features/notifications/screen/notifications_screen.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
    OrderStore.instance.resetForLogout();
  });

  group('Bug 1: Notification Dates (Delivered vs Upcoming)', () {
    test('Delivered notification displays actual completion date (13 Oct 2026), not scheduled date (15 Oct 2026)', () async {
      final orderWC168 = OrderModel(
        bookingId: 'WC-168',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15), // Scheduled for 15 Oct
        completedDate: DateTime(2026, 10, 13), // Actually completed on 13 Oct
        address: 'Paruthippara, Thiruvananthapuram',
        fullAddress: 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
        contact: 'User',
        status: OrderStatus.completed,
      );

      OrderStore.instance.orders.value = [orderWC168];

      final vm = NotificationsViewModel();
      await vm.loadNotifications();

      // Check in Delivered category tab
      vm.setTabIndex(2); // 'Delivered'
      expect(vm.filteredNotifications.length, 1);

      final notif = vm.filteredNotifications.first;
      expect(notif.category, 'Delivered');
      expect(notif.time, '13 Oct 2026');
      expect(notif.description, 'Your Sanitary waste pickup on 13 Oct 2026 has been delivered. Thank you for recycling!');
      expect(notif.title, 'Pickup Delivered • WC-168');
    });

    test('Upcoming notification continues to display scheduled pickup date', () async {
      final upcomingOrder = OrderModel(
        bookingId: 'WC-161',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Paruthippara, Thiruvananthapuram',
        fullAddress: 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
        contact: 'User',
        status: OrderStatus.pending,
      );

      OrderStore.instance.orders.value = [upcomingOrder];

      final vm = NotificationsViewModel(
        nowProvider: () => DateTime(2026, 10, 13),
      );
      await vm.loadNotifications();

      // Check in Upcoming category tab
      vm.setTabIndex(1); // 'Upcoming'
      expect(vm.filteredNotifications.length, 1);

      final notif = vm.filteredNotifications.first;
      expect(notif.category, 'Upcoming');
      expect(notif.time, '15 Oct 2026');
      expect(notif.description, contains('Your Sanitary waste pickup is scheduled for 15 Oct 2026.'));
      expect(notif.title, 'Pickup Scheduled • WC-161');
    });

    test('Delivered notification safely falls back to pickupDate if completedDate is null', () async {
      final orderWithoutCompletedDate = OrderModel(
        bookingId: 'WC-170',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        completedDate: null, // Null completion date handled safely
        address: 'Paruthippara',
        fullAddress: 'KRAA/11, Paruthippara',
        contact: 'User',
        status: OrderStatus.completed,
      );

      OrderStore.instance.orders.value = [orderWithoutCompletedDate];

      final vm = NotificationsViewModel();
      await vm.loadNotifications();

      vm.setTabIndex(2); // 'Delivered'
      expect(vm.filteredNotifications.length, 1);
      final notif = vm.filteredNotifications.first;
      expect(notif.time, '15 Oct 2026');
      expect(notif.description, 'Your Sanitary waste pickup on 15 Oct 2026 has been delivered. Thank you for recycling!');
    });
  });

  group('Bug 2: User Data Isolation (Users cannot see other users notifications)', () {
    test('User A cannot see User B notifications in ViewModel and OrderStore', () async {
      // User A creates an order
      await OrderStore.instance.loadForUser('user_A');
      final orderUserA = OrderModel(
        bookingId: 'WC-201',
        wasteType: 'Dry & Recyclable waste',
        pickupDate: DateTime(2026, 10, 12),
        completedDate: DateTime(2026, 10, 12),
        address: 'User A Address',
        fullAddress: 'User A Full Address',
        contact: 'User A',
        status: OrderStatus.completed,
        userId: 'user_A',
      );
      final orderUserB = OrderModel(
        bookingId: 'WC-202',
        wasteType: 'Hazardous waste',
        pickupDate: DateTime(2026, 10, 14),
        address: 'User B Address',
        fullAddress: 'User B Full Address',
        contact: 'User B',
        status: OrderStatus.pending,
        userId: 'user_B',
      );

      OrderStore.instance.orders.value = [orderUserA, orderUserB];

      // Set logged in user as User A
      await SpHelper.saveString(sp_keys.keyUserId, 'user_A');

      final vmUserA = NotificationsViewModel();
      await vmUserA.loadNotifications();

      // User A should only see User A notification
      expect(vmUserA.notifications.length, 1);
      expect(vmUserA.notifications.first.id, 'WC-201');
      expect(vmUserA.notifications.any((n) => n.id == 'WC-202'), isFalse);

      // Now switch to User B
      await SpHelper.saveString(sp_keys.keyUserId, 'user_B');
      await OrderStore.instance.loadForUser('user_B');
      OrderStore.instance.orders.value = [orderUserA, orderUserB];

      final vmUserB = NotificationsViewModel();
      await vmUserB.loadNotifications();

      // User B should only see User B notification
      expect(vmUserB.notifications.length, 1);
      expect(vmUserB.notifications.first.id, 'WC-202');
      expect(vmUserB.notifications.any((n) => n.id == 'WC-201'), isFalse);
    });

    test('On logout, OrderStore resets and does not leak previous user orders', () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_A');
      await OrderStore.instance.loadForUser('user_A');

      OrderStore.instance.addOrder(
        OrderModel(
          bookingId: 'WC-999',
          wasteType: 'E-Waste',
          pickupDate: DateTime(2026, 10, 20),
          address: 'Secret Addr',
          fullAddress: 'Secret Full Addr',
          contact: 'Secret User',
          userId: 'user_A',
        ),
      );

      expect(OrderStore.instance.orders.value.any((o) => o.bookingId == 'WC-999'), isTrue);

      // Logout User A
      OrderStore.instance.resetForLogout();
      await SpHelper.clearAll();

      // User B logs in without WC-999 in their store
      await SpHelper.saveString(sp_keys.keyUserId, 'user_B');
      await OrderStore.instance.loadForUser('user_B');

      expect(OrderStore.instance.orders.value.any((o) => o.bookingId == 'WC-999'), isFalse);
    });

    test('Tabs All, Upcoming, and Delivered filter properly', () async {
      final orderDelivered = OrderModel(
        bookingId: 'WC-168',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        completedDate: DateTime(2026, 10, 13),
        address: 'Paruthippara',
        fullAddress: 'KRAA/11, Paruthippara',
        contact: 'User',
        status: OrderStatus.completed,
      );
      final orderUpcoming = OrderModel(
        bookingId: 'WC-165',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 14),
        address: 'Pattom',
        fullAddress: 'TC 14/1250, Pattom',
        contact: 'User',
        status: OrderStatus.pending,
      );

      OrderStore.instance.orders.value = [orderDelivered, orderUpcoming];

      final vm = NotificationsViewModel(
        nowProvider: () => DateTime(2026, 10, 13),
      );
      await vm.loadNotifications();

      // All Tab
      vm.setTabIndex(0);
      expect(vm.filteredNotifications.length, 2);

      // Upcoming Tab
      vm.setTabIndex(1);
      expect(vm.filteredNotifications.length, 1);
      expect(vm.filteredNotifications.first.id, 'WC-165');

      // Delivered Tab
      vm.setTabIndex(2);
      expect(vm.filteredNotifications.length, 1);
      expect(vm.filteredNotifications.first.id, 'WC-168');
      expect(vm.filteredNotifications.first.time, '13 Oct 2026');
    });

    testWidgets('NotificationsScreen UI displays 13 Oct 2026 in Delivered tab and 15 Oct 2026 in Upcoming tab', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final orderDelivered = OrderModel(
        bookingId: 'WC-168',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        completedDate: DateTime(2026, 10, 13),
        address: 'Paruthippara',
        fullAddress: 'KRAA/11, Paruthippara',
        contact: 'User',
        status: OrderStatus.completed,
      );
      final orderUpcoming = OrderModel(
        bookingId: 'WC-161',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Paruthippara',
        fullAddress: 'KRAA/11, Paruthippara',
        contact: 'User',
        status: OrderStatus.pending,
      );

      OrderStore.instance.orders.value = [orderDelivered, orderUpcoming];

      final vm = NotificationsViewModel(
        nowProvider: () => DateTime(2026, 10, 13),
      );
      await vm.loadNotifications();

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Delivered tab
      await tester.tap(find.text('Delivered').first);
      await tester.pumpAndSettle();

      // Delivered notification should display 13 Oct 2026, not 15 Oct 2026
      expect(find.text('Your Sanitary waste pickup on 13 Oct 2026 has been delivered. Thank you for recycling!'), findsOneWidget);
      expect(find.text('13 Oct 2026'), findsOneWidget);
      expect(find.text('Pickup Delivered • WC-168'), findsOneWidget);

      // Switch to Upcoming tab
      await tester.tap(find.text('Upcoming').first);
      await tester.pumpAndSettle();

      // Upcoming notification should display 15 Oct 2026
      expect(find.text('Pickup Scheduled • WC-161'), findsOneWidget);
      expect(find.text('15 Oct 2026'), findsOneWidget);
      expect(find.textContaining('scheduled for 15 Oct 2026'), findsOneWidget);
    });
  });

  group('Upcoming Section Date Filtering (Today and Future Dates)', () {
    test('Upcoming section shows today and future dates, but hides previous dates', () async {
      final baseNow = DateTime(2026, 10, 20, 16, 0); // 20 Oct 2026 at 4:00 PM

      final orderYesterday = OrderModel(
        bookingId: 'WC-YESTERDAY',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 19, 10, 0), // 19 Oct 2026 (previous date)
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.pending,
      );

      final orderTodayEarlier = OrderModel(
        bookingId: 'WC-TODAY-EARLIER',
        wasteType: 'Solid waste',
        pickupDate: DateTime(2026, 10, 20, 9, 0), // Today at 9:00 AM (scheduled time has passed)
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.pending,
      );

      final orderTodayLater = OrderModel(
        bookingId: 'WC-TODAY-LATER',
        wasteType: 'E-Waste',
        pickupDate: DateTime(2026, 10, 20, 18, 0), // Today at 6:00 PM (later today)
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.reschedule,
      );

      final orderTomorrow = OrderModel(
        bookingId: 'WC-TOMORROW',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 21, 11, 0), // Tomorrow (future date)
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.pending,
      );

      final orderNextWeek = OrderModel(
        bookingId: 'WC-NEXT-WEEK',
        wasteType: 'Glass waste',
        pickupDate: DateTime(2026, 10, 27, 14, 0), // Next week (future date)
        address: 'Addr',
        fullAddress: 'Full Addr',
        contact: 'User',
        status: OrderStatus.pending,
      );

      OrderStore.instance.orders.value = [
        orderYesterday,
        orderTodayEarlier,
        orderTodayLater,
        orderTomorrow,
        orderNextWeek,
      ];

      final vm = NotificationsViewModel(nowProvider: () => baseNow);
      await vm.loadNotifications();

      // In All tab: all 5 are present
      vm.setTabIndex(0);
      expect(vm.filteredNotifications.length, 5);

      // In Upcoming tab: WC-YESTERDAY is hidden! Today's (both earlier and later) and future are visible!
      vm.setTabIndex(1);
      final upcoming = vm.filteredNotifications;
      expect(upcoming.length, 4);

      final upcomingIds = upcoming.map((n) => n.id).toList();
      expect(upcomingIds.contains('WC-YESTERDAY'), isFalse);
      expect(upcomingIds.contains('WC-TODAY-EARLIER'), isTrue);
      expect(upcomingIds.contains('WC-TODAY-LATER'), isTrue);
      expect(upcomingIds.contains('WC-TOMORROW'), isTrue);
      expect(upcomingIds.contains('WC-NEXT-WEEK'), isTrue);
    });

    testWidgets('NotificationsScreen UI shows today and future dates in Upcoming tab, but hides previous dates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final baseNow = DateTime(2026, 10, 20, 16, 0); // 20 Oct 2026 at 4:00 PM

      final orderPast = OrderModel(
        bookingId: 'WC-PAST-001',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 18, 10, 0), // Past date
        address: 'Past St',
        fullAddress: 'Past Full St',
        contact: 'User',
        status: OrderStatus.pending,
      );

      final orderToday = OrderModel(
        bookingId: 'WC-TODAY-001',
        wasteType: 'Solid waste',
        pickupDate: DateTime(2026, 10, 20, 9, 30), // Today at 9:30 AM (past scheduled time)
        address: 'Today St',
        fullAddress: 'Today Full St',
        contact: 'User',
        status: OrderStatus.pending,
      );

      final orderFuture = OrderModel(
        bookingId: 'WC-FUT-001',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 25, 14, 0), // Future date
        address: 'Future St',
        fullAddress: 'Future Full St',
        contact: 'User',
        status: OrderStatus.pending,
      );

      OrderStore.instance.orders.value = [orderPast, orderToday, orderFuture];

      final vm = NotificationsViewModel(nowProvider: () => baseNow);
      await vm.loadNotifications();

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Upcoming tab
      await tester.tap(find.text('Upcoming').first);
      await tester.pumpAndSettle();

      // Today's notification is visible even though scheduled time passed!
      expect(find.text('Pickup Scheduled • WC-TODAY-001'), findsOneWidget);
      expect(find.text('20 Oct 2026'), findsOneWidget);

      // Future notification is visible!
      expect(find.text('Pickup Scheduled • WC-FUT-001'), findsOneWidget);
      expect(find.text('25 Oct 2026'), findsOneWidget);

      // Past notification is NOT visible under Upcoming!
      expect(find.text('Pickup Scheduled • WC-PAST-001'), findsNothing);
      expect(find.text('18 Oct 2026'), findsNothing);

      // Switch to All tab: Past notification IS visible under All!
      await tester.tap(find.text('All').first);
      await tester.pumpAndSettle();
      expect(find.text('Pickup Scheduled • WC-PAST-001'), findsOneWidget);
      expect(find.text('Pickup Scheduled • WC-TODAY-001'), findsOneWidget);
      expect(find.text('Pickup Scheduled • WC-FUT-001'), findsOneWidget);
    });
  });
}
