import 'package:floret_app/features/booking/repos/booking_repository.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';
import 'package:floret_app/features/profile/screen/saved_addresses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Location Details State, District, Local Body, Ward API & Selection Tests', () {
    test('BookingRepository returns only required states, districts, local bodies', () {
      final repo = BookingRepository();
      
      // Only required state: Kerala
      final states = repo.getAvailableStates();
      expect(states, equals(['Kerala']));

      // Only required districts for Kerala: Thiruvananthapuram and Alappuzha
      final districts = repo.getDistrictsForState('Kerala');
      expect(districts, contains('Thiruvananthapuram'));
      expect(districts, contains('Alappuzha'));
      expect(districts.length, equals(2));

      // Only required local bodies for Thiruvananthapuram
      final tvmLB = repo.getLocalBodies('Thiruvananthapuram');
      expect(tvmLB, contains('Nedumangadu Municipality'));
      expect(tvmLB, contains('Varkala Municipality'));

      // Wards fallback / fetch returns non-empty list of wards
      final wardsNedumangad = repo.getWards('Nedumangadu Municipality');
      expect(wardsNedumangad, isNotEmpty);
      expect(wardsNedumangad, contains('1 - KALLUVARAMBU'));
      expect(wardsNedumangad, contains('8 - NAGARIKUNNU'));

      final wardsVarkala = repo.getWards('Varkala Municipality');
      expect(wardsVarkala, isNotEmpty);
      expect(wardsVarkala, contains('1 - Vilakkulam'));
    });

    testWidgets('SavedAddressesScreen Add Address uses required state, district, local body, ward',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      await tester.pumpWidget(
        const MaterialApp(
          home: SavedAddressesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Add Address" button
      final addAddressFinder = find.widgetWithText(ElevatedButton, 'Add Address');
      final fabFinder = find.byType(FloatingActionButton);
      if (addAddressFinder.evaluate().isNotEmpty) {
        await tester.tap(addAddressFinder);
      } else {
        await tester.tap(fabFinder);
      }
      await tester.pumpAndSettle();

      // In Add New Address sheet:
      expect(find.text('Add New Address'), findsOneWidget);

      // Verify dropdown fields exist
      expect(find.text('State'), findsOneWidget);
      expect(find.text('Select State first'), findsWidgets);

      // 1. Tap State -> opens picker with ONLY Kerala
      await tester.tap(find.text('State'));
      await tester.pumpAndSettle();

      expect(find.text('Select State'), findsOneWidget);
      expect(find.text('Kerala'), findsOneWidget);
      expect(find.text('Tamil Nadu'), findsNothing);
      expect(find.text('Karnataka'), findsNothing);

      // Select Kerala
      await tester.tap(find.text('Kerala'));
      await tester.pumpAndSettle();

      // State is now selected as Kerala
      expect(find.text('District'), findsOneWidget);

      // 2. Tap District -> opens picker with only required districts
      await tester.tap(find.text('District'));
      await tester.pumpAndSettle();

      expect(find.text('Select District'), findsOneWidget);
      expect(find.text('Thiruvananthapuram'), findsOneWidget);
      expect(find.text('Alappuzha'), findsOneWidget);
      expect(find.text('Ernakulam'), findsNothing);
      expect(find.text('Kozhikode'), findsNothing);

      // Select Thiruvananthapuram
      await tester.tap(find.text('Thiruvananthapuram'));
      await tester.pumpAndSettle();

      // 3. Tap Local Body -> opens picker with only required local bodies
      expect(find.text('Local Body'), findsOneWidget);
      await tester.tap(find.text('Local Body'));
      await tester.pumpAndSettle();

      expect(find.text('Select Local Body'), findsOneWidget);
      expect(find.text('Nedumangadu Municipality'), findsOneWidget);
      expect(find.text('Varkala Municipality'), findsOneWidget);
      expect(find.text('Kochi Municipal Corporation'), findsNothing);

      // Select Nedumangadu Municipality
      await tester.tap(find.text('Nedumangadu Municipality'));
      await tester.pumpAndSettle();

      // 4. Tap Ward -> calls API / fetchWards and opens Ward Picker
      expect(find.text('Ward'), findsOneWidget);
      await tester.tap(find.text('Ward'));
      await tester.pumpAndSettle();

      expect(find.text('Select Ward'), findsOneWidget);
      expect(find.text('1 - KALLUVARAMBU'), findsOneWidget);

      // Select Ward 1
      await tester.tap(find.text('1 - KALLUVARAMBU'));
      await tester.pumpAndSettle();

      // Ward is selected
      expect(find.text('1 - KALLUVARAMBU'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('BookPickupScreen Location Details selects required state, district, local body, ward',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      await tester.pumpWidget(
        const MaterialApp(
          home: BookPickupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // On Step 0 (Select Waste Categories), select a category and tap Continue to advance to Step 1
      final continueBtn = find.text('Continue');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Step 1: Location Details
      expect(find.text('Location Details'), findsOneWidget);

      // Switch to New Address tab if Saved Addresses is selected
      final newAddressTab = find.text('New Address');
      if (newAddressTab.evaluate().isNotEmpty) {
        await tester.tap(newAddressTab);
        await tester.pumpAndSettle();
      }

      // Check State selector
      final stateFinder = find.text('Select state');
      expect(stateFinder, findsOneWidget);
      await tester.tap(stateFinder);
      await tester.pumpAndSettle();

      expect(find.text('Select State'), findsOneWidget);
      expect(find.text('Kerala'), findsOneWidget);

      await tester.tap(find.text('Kerala'));
      await tester.pumpAndSettle();

      // Check District selector
      final districtFinder = find.text('Select District');
      expect(districtFinder, findsOneWidget);
      await tester.tap(districtFinder);
      await tester.pumpAndSettle();

      expect(find.text('Select District'), findsWidgets);
      expect(find.text('Thiruvananthapuram'), findsOneWidget);

      await tester.tap(find.text('Thiruvananthapuram'));
      await tester.pumpAndSettle();

      // Check Local Body selector
      final lbFinder = find.text('Select Local Body');
      expect(lbFinder, findsOneWidget);
      await tester.tap(lbFinder);
      await tester.pumpAndSettle();

      expect(find.text('Nedumangadu Municipality'), findsOneWidget);
      await tester.tap(find.text('Nedumangadu Municipality'));
      await tester.pumpAndSettle();

      // Check Ward selector
      final wardFinder = find.text('Select Ward');
      expect(wardFinder, findsOneWidget);
      await tester.tap(wardFinder);
      await tester.pumpAndSettle();

      expect(find.text('1 - KALLUVARAMBU'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
