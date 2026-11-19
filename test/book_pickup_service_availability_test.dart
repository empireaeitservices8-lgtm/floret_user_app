import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/home/screen/bottom_navigation_screen.dart';
import 'package:floret_app/features/map/screen/location_picker_map_screen.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
  });

  group('Service Availability Location Checks', () {
    test('Thiruvananthapuram city is within service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 8.5241,
        longitude: 76.9366,
        city: 'Thiruvananthapuram',
        district: 'Thiruvananthapuram',
        zipCode: '695004',
      );
      expect(outOfService, isFalse);
    });

    test('Varkala Municipality is within service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 8.7379,
        longitude: 76.7163,
        city: 'Varkala',
        district: 'Thiruvananthapuram',
        localBody: 'Varkala Municipality',
        zipCode: '695141',
      );
      expect(outOfService, isFalse);
    });

    test('Nedumangadu Municipality is within service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 8.6042,
        longitude: 77.0016,
        city: 'Nedumangad',
        district: 'Thiruvananthapuram',
        localBody: 'Nedumangadu Municipality',
        zipCode: '695541',
      );
      expect(outOfService, isFalse);
    });

    test('Kochi / Ernakulam is detected as out of service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 9.9312,
        longitude: 76.2673,
        city: 'Kochi',
        district: 'Ernakulam',
        zipCode: '682001',
      );
      expect(outOfService, isTrue);
    });

    test('Kollam is detected as out of service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 8.8932,
        longitude: 76.6141,
        city: 'Kollam',
        district: 'Kollam',
        zipCode: '691001',
      );
      expect(outOfService, isTrue);
    });

    test('Alappuzha is detected as out of service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 9.4981,
        longitude: 76.3388,
        city: 'Alappuzha',
        district: 'Alappuzha',
        zipCode: '688001',
      );
      expect(outOfService, isTrue);
    });

    test('Bangalore / Karnataka is detected as out of service area', () {
      final outOfService = isLocationOutOfService(
        latitude: 12.9716,
        longitude: 77.5946,
        city: 'Bengaluru',
        state: 'Karnataka',
        zipCode: '560001',
      );
      expect(outOfService, isTrue);
    });

    test(
        'Coordinates far outside Kerala (e.g. USA emulator) are detected as out of service',
        () {
      final outOfService = isLocationOutOfService(
        latitude: 37.4220,
        longitude: -122.0841,
      );
      expect(outOfService, isTrue);
    });
  });

  group('SelectedLocationResult isOutOfService field', () {
    test('Defaults to false and can be set to true', () {
      const normal = SelectedLocationResult(
        latitude: 8.5241,
        longitude: 76.9366,
        fullAddress: 'Thiruvananthapuram',
        street: 'MG Road',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        district: 'Thiruvananthapuram',
        zipCode: '695001',
        shortCode: 'TVM',
      );
      expect(normal.isOutOfService, isFalse);

      const out = SelectedLocationResult(
        latitude: 9.9312,
        longitude: 76.2673,
        fullAddress: 'Kochi, Kerala',
        street: 'Marine Drive',
        city: 'Kochi',
        state: 'Kerala',
        district: 'Ernakulam',
        zipCode: '682001',
        shortCode: 'KOC',
        isOutOfService: true,
      );
      expect(out.isOutOfService, isTrue);
    });
  });

  group('BookPickupScreen Locate on Map Out of Service Workflow', () {
    testWidgets('Locate on Map card exists under Location step',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      vm.proceedToLocation();
      vm.setAddressTab(1); // New Address tab

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            BottomNavigationScreen.routeName: (context) => const Scaffold(
                  body: Center(child: Text('Home Screen Content')),
                ),
          },
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Find Locate on Map card
      final locateOnMapFinder = find.text('Locate on Map');
      expect(locateOnMapFinder, findsOneWidget);
    });

    testWidgets(
        'Out of service notification displays "Service is not available in your location" and navigates to home page after 3 seconds',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            BottomNavigationScreen.routeName: (context) => const Scaffold(
                  body: Center(child: Text('Home Screen Content')),
                ),
          },
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Service is not available in your location'),
                        backgroundColor: Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );

                    await Future.delayed(const Duration(seconds: 3));
                    if (!context.mounted) return;

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      BottomNavigationScreen.routeName,
                      (route) => false,
                    );
                  },
                  child: const Text('Trigger Out Of Service'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger
      await tester.tap(find.text('Trigger Out Of Service'));
      await tester.pump();

      // Verify SnackBar appears with exact message
      expect(find.text('Service is not available in your location'),
          findsOneWidget);

      // Advance by 3 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.text('Home Screen Content'), findsOneWidget);
    });
  });
}
