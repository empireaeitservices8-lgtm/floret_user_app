import 'package:floret_app/features/profile/screen/my_account_screen.dart';
import 'package:floret_app/features/profile/viewmodel/my_account_view_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/address_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('My Account Address Details - Registration Address Tests', () {
    test('MyAccountViewModel loads user registration address as default address, city, and pincode',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_street', 'House 42, Green Valley');
      await prefs.setString('registration_city', 'Nedumangad');
      await prefs.setString('registration_state', 'Kerala');
      await prefs.setString('registration_district', 'Thiruvananthapuram');
      await prefs.setString('registration_local_body', 'Nedumangadu Municipality');
      await prefs.setString('registration_ward', '8 - NAGARIKUNNU');
      await prefs.setString('registration_zip_code', '695541');
      await prefs.setString(
        'registration_address',
        'House 42, Green Valley, 8 - NAGARIKUNNU, Nedumangadu Municipality, Nedumangad, Thiruvananthapuram, Kerala, 695541',
      );

      final vm = MyAccountViewModel();
      await vm.loadAddressDetails();

      expect(
        vm.defaultAddress,
        equals(
          'House 42, Green Valley, 8 - NAGARIKUNNU, Nedumangadu Municipality, Nedumangad, Thiruvananthapuram, Kerala, 695541',
        ),
      );
      expect(vm.city, equals('Nedumangad'));
      expect(vm.pincode, equals('695541'));
    });

    test('AddressStorageService initializes default address from registration address if empty',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_street', 'Flat 3B, Palm Towers');
      await prefs.setString('registration_city', 'Thiruvananthapuram');
      await prefs.setString('registration_zip_code', '695001');

      final saved = await AddressStorageService.getSavedAddresses();
      expect(saved, isNotEmpty);
      expect(saved.first.isDefault, isTrue);
      expect(saved.first.addressLine, equals('Flat 3B, Palm Towers'));
      expect(saved.first.city, equals('Thiruvananthapuram'));
      expect(saved.first.pincode, equals('695001'));
    });

    testWidgets('MyAccountScreen displays user registration address under Address Details',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_street', 'Sunrise Villa, Ward 8');
      await prefs.setString('registration_city', 'Nedumangad');
      await prefs.setString('registration_zip_code', '695541');
      await prefs.setString(
        'registration_address',
        'Sunrise Villa, Ward 8, Nedumangad, Kerala, 695541',
      );
      await SpHelper.saveString(
        'registration_address',
        'Sunrise Villa, Ward 8, Nedumangad, Kerala, 695541',
      );
      await SpHelper.saveString('registration_city', 'Nedumangad');
      await SpHelper.saveString('registration_zip_code', '695541');

      final vm = MyAccountViewModel();
      await vm.loadAddressDetails();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MyAccountViewModel>.value(
            value: vm,
            child: const MyAccountScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Address Details section header
      expect(find.text('Address Details'), findsOneWidget);

      // Verify Default Address label and user's registration address text
      expect(find.text('Default Address'), findsOneWidget);
      expect(
        find.text('Sunrise Villa, Ward 8, Nedumangad, Kerala, 695541'),
        findsOneWidget,
      );

      // Verify City
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Nedumangad'), findsOneWidget);

      // Verify Pincode
      expect(find.text('Pincode'), findsOneWidget);
      expect(find.text('695541'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
