import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/profile/model/address_model.dart';
import 'package:floret_app/services/address_storage_service.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/booking/screen/book_pickup_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AddressStorageService Tests', () {
    test('getSavedAddresses returns default seeds if empty', () async {
      final addresses = await AddressStorageService.getSavedAddresses();
      expect(addresses.isNotEmpty, isTrue);
      expect(addresses.any((a) => a.addressLine == 'Sunset Blvd'), isTrue);
      expect(addresses.any((a) => a.id == '1792210679721'), isTrue);
    });

    test('addAddress saves to SharedPreferences and retrieves correctly', () async {
      final newAddr = AddressModel(
        id: 'test_123',
        type: 'Home',
        addressLine: '123 Palm Grove',
        city: 'Kochi',
        state: 'Kerala',
        pincode: '682001',
        isDefault: true,
      );

      await AddressStorageService.addAddress(newAddr);
      final list = await AddressStorageService.getSavedAddresses();
      expect(list.any((a) => a.id == 'test_123'), isTrue);
      final saved = list.firstWhere((a) => a.id == 'test_123');
      expect(saved.addressLine, equals('123 Palm Grove'));
      expect(saved.city, equals('Kochi'));
      expect(saved.isDefault, isTrue);
    });
  });

  group('BookingViewModel Saved Address Tests', () {
    test('loads saved addresses and selects default', () async {
      final vm = BookingViewModel();
      await vm.loadSavedAddresses();

      expect(vm.savedAddresses.isNotEmpty, isTrue);
      expect(vm.selectedSavedAddress, isNotNull);
      expect(vm.selectedSavedAddress!.isDefault, isTrue);

      vm.setAddressTab(0);
      expect(vm.pickupAddressController.text, equals(vm.selectedSavedAddress!.addressLine));
    });

    test('selectSavedAddress updates form fields and selected address', () async {
      final vm = BookingViewModel();
      await vm.loadSavedAddresses();

      final first = vm.savedAddresses.first;
      vm.selectSavedAddress(first);

      expect(vm.selectedSavedAddress?.id, equals(first.id));
      expect(vm.pickupAddressController.text, equals(first.addressLine));
      expect(vm.cityController.text, equals(first.city));
    });

    test('saveCurrentAddressToProfile adds new address to storage', () async {
      final vm = BookingViewModel();
      vm.pickupAddressController.text = '456 Hilltop Ave';
      vm.cityController.text = 'Kollam';
      vm.zipCodeController.text = '691001';
      vm.setStateSelection('Kerala');

      final saved = await vm.saveCurrentAddressToProfile(type: 'Work');
      expect(saved, isNotNull);
      expect(saved!.addressLine, equals('456 Hilltop Ave'));
      expect(saved.city, equals('Kollam'));

      final all = await AddressStorageService.getSavedAddresses();
      expect(all.any((a) => a.addressLine == '456 Hilltop Ave'), isTrue);
    });

    test('if entered pickup address is repeated, only latest one is stored and shown', () async {
      final vm = BookingViewModel();
      await vm.loadSavedAddresses();

      // Enter address "Sunset Blvd" with new city "Kochi"
      vm.pickupAddressController.text = 'Sunset Blvd';
      vm.cityController.text = 'Kochi';
      vm.zipCodeController.text = '682001';

      await vm.saveCurrentAddressToProfile();

      // Verify "Sunset Blvd" appears only once in savedAddresses
      final sunsetMatches = vm.savedAddresses
          .where((a) => a.addressLine.toLowerCase() == 'sunset blvd')
          .toList();
      expect(sunsetMatches.length, equals(1));
      // Verify it reflects the latest entered data
      expect(sunsetMatches.first.city, equals('Kochi'));
      expect(sunsetMatches.first.pincode, equals('682001'));
    });

    test('deduplicates repeated addresses loaded from raw storage, showing only latest', () async {
      // Simulate raw storage having repeated entries
      await AddressStorageService.saveAddresses([
        AddressModel(
          id: 'old_1',
          addressLine: 'Baker Street',
          city: 'London',
          pincode: '111111',
          isDefault: true,
        ),
        AddressModel(
          id: 'old_2',
          addressLine: 'Palm Grove',
          city: 'Kochi',
          pincode: '682001',
          isDefault: false,
        ),
        AddressModel(
          id: 'latest_1',
          addressLine: 'Baker Street',
          city: 'New London',
          pincode: '222222',
          isDefault: false,
        ),
      ]);

      final vm = BookingViewModel();
      await vm.loadSavedAddresses();

      final bakerMatches = vm.savedAddresses
          .where((a) => a.addressLine.toLowerCase() == 'baker street')
          .toList();
      expect(bakerMatches.length, equals(1));
      expect(bakerMatches.first.city, equals('New London'));
      expect(bakerMatches.first.pincode, equals('222222'));
    });
  });

  group('BookPickupScreen Widget Tests', () {
    testWidgets('Displays Saved Addresses tab, cards and Selected Destination', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = BookingViewModel();
      await vm.loadSavedAddresses();
      vm.proceedToLocation(); // Move to Step 1: Location Details
      vm.setAddressTab(0); // Select Saved Addresses tab

      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Location Details and Saved Addresses tab are present
      expect(find.text('Location Details'), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('New Address'), findsOneWidget);

      // Verify Saved Address cards (e.g. Sunset Blvd, Home (Default))
      expect(find.text('Sunset Blvd'), findsAtLeastNWidgets(1));
      expect(find.text('Selected Destination'), findsOneWidget);

      // Verify Continue button is present
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Location Details Saved Addresses does not show repeated addresses, only latest',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Preload repeated addresses in storage
      await AddressStorageService.saveAddresses([
        AddressModel(
          id: 'addr_1',
          type: 'Home',
          addressLine: 'Green Valley',
          city: 'Old Town',
          pincode: '695001',
          isDefault: true,
        ),
        AddressModel(
          id: 'addr_2',
          type: 'Work',
          addressLine: 'Cyber Park',
          city: 'Tech City',
          pincode: '695581',
          isDefault: false,
        ),
        AddressModel(
          id: 'addr_3',
          type: 'Home',
          addressLine: 'Green Valley',
          city: 'New Town',
          pincode: '695002',
          isDefault: false,
        ),
      ]);

      final vm = BookingViewModel();
      await vm.loadSavedAddresses();
      vm.proceedToLocation(); // Move to Step 1: Location Details
      vm.setAddressTab(0); // Select Saved Addresses tab

      await tester.pumpWidget(
        MaterialApp(
          home: BookPickupScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // "Green Valley" should only have one card in horizontal saved addresses list
      // Total occurrences of "Green Valley": 1 in horizontal card + 1 in Selected Destination = 2 (not 3)
      expect(find.text('Green Valley'), findsNWidgets(2));
      // The latest city "New Town" should be displayed
      expect(find.textContaining('New Town'), findsAtLeastNWidgets(1));
      // The older city "Old Town" should not be displayed
      expect(find.textContaining('Old Town'), findsNothing);
    });
  });
}
