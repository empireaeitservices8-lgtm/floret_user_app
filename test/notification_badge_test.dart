import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/profile/screen/profile_screen.dart';
import 'package:floret_app/features/notifications/screen/notifications_screen.dart';
import 'package:floret_app/features/notifications/viewmodel/notifications_view_model.dart';
import 'package:floret_app/features/notifications/repos/notification_repository.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/viewmodels/profile_viewmodel.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

Widget _buildTestApp({
  required Widget child,
  required NotificationsViewModel notifVm,
  required ProfileViewModel profileVm,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NotificationsViewModel>.value(value: notifVm),
      ChangeNotifierProvider<ProfileViewModel>.value(value: profileVm),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        NotificationsScreen.routeName: (context) => NotificationsScreen(
              viewModel: notifVm,
            ),
      },
    ),
  );
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

  group('Dynamic Notification Badge System', () {
    test('1. No badge when there are no unread notifications', () async {
      final repo = NotificationRepository();
      final vm = NotificationsViewModel(repository: repo);
      await vm.loadNotifications();

      expect(vm.notifications, isEmpty);
      expect(vm.unreadCount, 0);
      expect(vm.hasUnreadNotifications, isFalse);
    });

    test('2. Order completed and cancelled are not automatically marked as read', () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_1');
      await OrderStore.instance.loadForUser('user_1');

      final completedOrder = OrderModel(
        bookingId: 'WC-901',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        completedDate: DateTime(2026, 10, 13),
        address: 'Pattom',
        fullAddress: 'Pattom full',
        contact: 'User 1',
        status: OrderStatus.completed,
        userId: 'user_1',
      );

      final cancelledOrder = OrderModel(
        bookingId: 'WC-902',
        wasteType: 'E-Waste',
        pickupDate: DateTime(2026, 10, 10),
        address: 'Kowdiar',
        fullAddress: 'Kowdiar full',
        contact: 'User 1',
        status: OrderStatus.cancelled,
        userId: 'user_1',
      );

      OrderStore.instance.addOrder(completedOrder);
      OrderStore.instance.addOrder(cancelledOrder);

      final vm = NotificationsViewModel();
      await vm.loadNotifications();

      // Neither order should be automatically marked read!
      expect(vm.notifications.length, 2);
      expect(vm.notifications[0].isRead, isFalse);
      expect(vm.notifications[1].isRead, isFalse);
      expect(vm.unreadCount, 2);
      expect(vm.hasUnreadNotifications, isTrue);
    });

    testWidgets('3. Badge appears on HomeScreen when unread notifications exist and hides when empty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyUserId, 'user_badge');
      await OrderStore.instance.loadForUser('user_badge');

      final notifVm = NotificationsViewModel();
      final profileVm = ProfileViewModel();
      await notifVm.loadNotifications();

      // Case A: No unread notifications -> No badge dot on HomeScreen
      await tester.pumpWidget(
        _buildTestApp(
          child: const HomeScreen(),
          notifVm: notifVm,
          profileVm: profileVm,
        ),
      );
      await tester.pump();

      final homeDotFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFFFA500));
      expect(homeDotFinder, findsNothing);

      // Now add an unread order
      final newOrder = OrderModel(
        bookingId: 'WC-701',
        wasteType: 'Solid waste',
        pickupDate: DateTime(2026, 10, 16),
        address: 'Statue',
        fullAddress: 'Statue full',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_badge',
      );
      OrderStore.instance.addOrder(newOrder);
      await tester.pump();

      // Badge dot should now appear on HomeScreen!
      expect(notifVm.hasUnreadNotifications, isTrue);
      expect(homeDotFinder, findsOneWidget);
    });

    testWidgets('4. Badge appears on ProfileScreen when unread notifications exist and hides when empty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyUserId, 'user_profile');
      await OrderStore.instance.loadForUser('user_profile');

      final notifVm = NotificationsViewModel();
      final profileVm = ProfileViewModel();
      await notifVm.loadNotifications();

      // Initially no unread notifications -> no badge dot on ProfileScreen
      await tester.pumpWidget(
        _buildTestApp(
          child: const ProfileScreen(),
          notifVm: notifVm,
          profileVm: profileVm,
        ),
      );
      await tester.pump();

      final profileDotFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFEF4444));
      expect(profileDotFinder, findsNothing);

      // Add unread order
      final unreadOrder = OrderModel(
        bookingId: 'WC-702',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 18),
        address: 'Pattom',
        fullAddress: 'Pattom full',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_profile',
      );
      OrderStore.instance.addOrder(unreadOrder);
      await tester.pump();

      // Red badge dot appears on ProfileScreen!
      expect(notifVm.hasUnreadNotifications, isTrue);
      expect(profileDotFinder, findsOneWidget);
    });

    testWidgets('5. Tapping the bell on HomeScreen marks notifications as read, immediately hides badge, and navigates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyUserId, 'user_tap_home');
      await OrderStore.instance.loadForUser('user_tap_home');

      final order = OrderModel(
        bookingId: 'WC-801',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Palayam',
        fullAddress: 'Palayam full',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_tap_home',
      );
      OrderStore.instance.addOrder(order);

      final notifVm = NotificationsViewModel();
      final profileVm = ProfileViewModel();
      await notifVm.loadNotifications();
      expect(notifVm.hasUnreadNotifications, isTrue);

      await tester.pumpWidget(
        _buildTestApp(
          child: const HomeScreen(),
          notifVm: notifVm,
          profileVm: profileVm,
        ),
      );
      await tester.pump();

      final homeDotFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFFFA500));
      expect(homeDotFinder, findsOneWidget);

      // Tap the notification bell on HomeScreen
      final bellFinder = find.byIcon(Icons.notifications_none_rounded);
      expect(bellFinder, findsOneWidget);
      await tester.tap(bellFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigated to NotificationsScreen and all notifications marked as read!
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(notifVm.hasUnreadNotifications, isFalse);
      expect(notifVm.unreadCount, 0);

      // Navigate back to HomeScreen
      final backButton = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Badge on HomeScreen is now completely hidden!
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(homeDotFinder, findsNothing);
    });

    testWidgets('6. Tapping the bell on ProfileScreen marks notifications as read, immediately hides badge, and navigates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString(sp_keys.keyUserId, 'user_tap_profile');
      await OrderStore.instance.loadForUser('user_tap_profile');

      final order = OrderModel(
        bookingId: 'WC-802',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 15),
        address: 'Kowdiar',
        fullAddress: 'Kowdiar full',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_tap_profile',
      );
      OrderStore.instance.addOrder(order);

      final notifVm = NotificationsViewModel();
      final profileVm = ProfileViewModel();
      await notifVm.loadNotifications();
      expect(notifVm.hasUnreadNotifications, isTrue);

      await tester.pumpWidget(
        _buildTestApp(
          child: const ProfileScreen(),
          notifVm: notifVm,
          profileVm: profileVm,
        ),
      );
      await tester.pump();

      final profileDotFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFEF4444));
      expect(profileDotFinder, findsOneWidget);

      // Tap the notification bell on ProfileScreen
      final bellFinder = find.byIcon(Icons.notifications_none_rounded);
      expect(bellFinder, findsOneWidget);
      await tester.tap(bellFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigated to NotificationsScreen and all notifications marked as read!
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(notifVm.hasUnreadNotifications, isFalse);
      expect(notifVm.unreadCount, 0);

      // Navigate back to ProfileScreen
      final backButton = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Badge on ProfileScreen is now completely hidden!
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(profileDotFinder, findsNothing);
    });

    test('7. Read status persists after restarting the application', () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_restart');
      await OrderStore.instance.loadForUser('user_restart');

      final order = OrderModel(
        bookingId: 'WC-803',
        wasteType: 'Dry waste',
        pickupDate: DateTime(2026, 10, 18),
        address: 'Kowdiar',
        fullAddress: 'Kowdiar full',
        contact: 'User',
        status: OrderStatus.reschedule,
        userId: 'user_restart',
      );
      OrderStore.instance.addOrder(order);

      final repo = NotificationRepository();
      final vm1 = NotificationsViewModel(repository: repo);
      await vm1.loadNotifications();
      expect(vm1.hasUnreadNotifications, isTrue);

      // Mark all as read
      await vm1.markAllAsRead();
      expect(vm1.hasUnreadNotifications, isFalse);

      // Simulate app restart by instantiating a new ViewModel with the same storage
      final vmRestarted = NotificationsViewModel(repository: repo);
      await vmRestarted.loadNotifications();

      expect(vmRestarted.notifications.length, 1);
      expect(vmRestarted.notifications.first.isRead, isTrue);
      expect(vmRestarted.hasUnreadNotifications, isFalse);
      expect(vmRestarted.unreadCount, 0);
    });

    test('8. Newly arriving notifications appear unread and show badge again without resetting existing read ones',
        () async {
      await SpHelper.saveString(sp_keys.keyUserId, 'user_new');
      await OrderStore.instance.loadForUser('user_new');

      final initialOrder = OrderModel(
        bookingId: 'WC-100',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 10),
        address: 'Addr 1',
        fullAddress: 'Full Addr 1',
        contact: 'User',
        status: OrderStatus.completed,
        userId: 'user_new',
      );
      OrderStore.instance.addOrder(initialOrder);

      final vm = NotificationsViewModel();
      await vm.loadNotifications();
      expect(vm.notifications.length, 1);

      // Mark initial order as read
      await vm.markAllAsRead();
      expect(vm.hasUnreadNotifications, isFalse);
      expect(vm.notifications.first.isRead, isTrue);

      // New booking arrives
      final newOrder = OrderModel(
        bookingId: 'WC-101',
        wasteType: 'E-Waste',
        pickupDate: DateTime(2026, 10, 22),
        address: 'Addr 2',
        fullAddress: 'Full Addr 2',
        contact: 'User',
        status: OrderStatus.pending,
        userId: 'user_new',
      );
      OrderStore.instance.addOrder(newOrder);

      // New notification should be unread, while initial order stays read!
      expect(vm.notifications.length, 2);
      final initialNotif = vm.notifications.firstWhere((n) => n.id == 'WC-100');
      final newNotif = vm.notifications.firstWhere((n) => n.id == 'WC-101');

      expect(initialNotif.isRead, isTrue);
      expect(newNotif.isRead, isFalse);
      expect(vm.unreadCount, 1);
      expect(vm.hasUnreadNotifications, isTrue);
    });

    test('9. Switching accounts does not leak read status between users', () async {
      // User A setup
      await SpHelper.saveString(sp_keys.keyUserId, 'user_A');
      await OrderStore.instance.loadForUser('user_A');

      final orderA = OrderModel(
        bookingId: 'WC-A1',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 12),
        address: 'User A Address',
        fullAddress: 'User A Full Address',
        contact: 'User A',
        status: OrderStatus.completed,
        userId: 'user_A',
      );
      OrderStore.instance.addOrder(orderA);

      final repo = NotificationRepository();
      final vmUserA = NotificationsViewModel(repository: repo);
      await vmUserA.loadNotifications();

      // User A marks as read
      await vmUserA.markAllAsRead();
      expect(vmUserA.hasUnreadNotifications, isFalse);

      // User B setup
      await SpHelper.saveString(sp_keys.keyUserId, 'user_B');
      await OrderStore.instance.loadForUser('user_B');

      final orderB = OrderModel(
        bookingId: 'WC-B1',
        wasteType: 'Hazardous waste',
        pickupDate: DateTime(2026, 10, 14),
        address: 'User B Address',
        fullAddress: 'User B Full Address',
        contact: 'User B',
        status: OrderStatus.pending,
        userId: 'user_B',
      );
      OrderStore.instance.addOrder(orderB);

      final vmUserB = NotificationsViewModel(repository: repo);
      await vmUserB.loadNotifications();

      // User B's notification MUST still be unread! User A's read status must NOT leak!
      expect(vmUserB.notifications.length, 1);
      expect(vmUserB.notifications.first.id, 'WC-B1');
      expect(vmUserB.notifications.first.isRead, isFalse);
      expect(vmUserB.hasUnreadNotifications, isTrue);
      expect(vmUserB.unreadCount, 1);
    });
  });
}
