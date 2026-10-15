import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/booking/viewmodel/booking_view_model.dart';
import 'package:floret_app/features/auth/viewmodel/signup_view_model.dart';
import 'package:floret_app/features/map/screen/location_picker_map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SelectedLocationResult Data Model', () {
    test('SelectedLocationResult holds location details and coordinates accurately', () {
      const result = SelectedLocationResult(
        latitude: 8.5241,
        longitude: 76.9366,
        fullAddress: 'GWFP+MM2, Kesavadasapuram, Thiruvananthapuram, Kerala - 695004',
        street: 'Kesavadasapuram',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        district: 'Thiruvananthapuram',
        localBody: 'Thiruvananthapuram Corporation',
        ward: '12',
        zipCode: '695004',
        shortCode: 'GWFP+MM2',
      );

      expect(result.latitude, 8.5241);
      expect(result.longitude, 76.9366);
      expect(result.shortCode, 'GWFP+MM2');
      expect(result.city, 'Thiruvananthapuram');
      expect(result.state, 'Kerala');
      expect(result.zipCode, '695004');
    });
  });

  group('BookingViewModel Map Location Integration', () {
    test('setMapLocation populates address controllers and coordinates', () {
      final vm = BookingViewModel();

      vm.setMapLocation(
        address: 'House No 42, Green Lane, Kesavadasapuram',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        district: 'Thiruvananthapuram',
        localBody: 'Thiruvananthapuram Corporation',
        ward: 'Ward 15',
        zipCode: '695004',
        lat: 8.5241,
        lng: 76.9366,
      );

      expect(vm.pickupAddressController.text, 'House No 42, Green Lane, Kesavadasapuram');
      expect(vm.cityController.text, 'Thiruvananthapuram');
      expect(vm.selectedState, 'Kerala');
      expect(vm.selectedDistrict, 'Thiruvananthapuram');
      expect(vm.selectedLocalBody, 'Thiruvananthapuram Corporation');
      expect(vm.selectedWard, 'Ward 15');
      expect(vm.zipCodeController.text, '695004');
      expect(vm.latitude, 8.5241);
      expect(vm.longitude, 76.9366);

      vm.dispose();
    });
  });

  group('SignupViewModel Map Location Integration', () {
    test('setMapLocation populates registration address fields and coordinates', () {
      final vm = SignupViewModel();

      vm.setMapLocation(
        street: 'Flat 3B, Palm Heights, Kowdiar',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        district: 'Thiruvananthapuram',
        localBody: 'Thiruvananthapuram Corporation',
        ward: 'Kowdiar Ward',
        zipCode: '695003',
        lat: 8.5280,
        lng: 76.9570,
      );

      expect(vm.streetAddressController.text, 'Flat 3B, Palm Heights, Kowdiar');
      expect(vm.cityController.text, 'Thiruvananthapuram');
      expect(vm.selectedState, 'Kerala');
      expect(vm.selectedDistrict, 'Thiruvananthapuram');
      expect(vm.selectedLocalBody, 'Thiruvananthapuram Corporation');
      expect(vm.selectedWard, 'Kowdiar Ward');
      expect(vm.zipCodeController.text, '695003');
      expect(vm.latitude, 8.5280);
      expect(vm.longitude, 76.9570);

      // Validate that step 3 validation passes with populated address and terms accepted
      vm.toggleTerms(true);
      expect(vm.validateStep3(), isTrue);

      vm.dispose();
    });
  });
}
