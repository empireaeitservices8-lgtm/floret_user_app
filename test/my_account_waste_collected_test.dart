import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/viewmodel/my_account_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('My Account - Waste Collected matches Home Screen tests', () {
    test(
        'Waste Collected displays 0.0 kg when there are no pickups or cached weight',
        () async {
      await SpHelper.clearAll();
      OrderStore.instance.orders.value = [];

      final vm = MyAccountViewModel();
      expect(vm.wasteCollected, 0.0);
    });

    test(
        'Waste Collected displays cached API total_recycled_weight same as Home (18.0 kg)',
        () async {
      await SpHelper.clearAll();
      await SpHelper.saveString('total_recycled_weight', '18.0');
      OrderStore.instance.orders.value = [];

      final vm = MyAccountViewModel();
      await vm.loadProfile();
      expect(vm.wasteCollected, 18.0);
    });

    test(
        'Waste Collected increases by 5.0 kg per completed pickup dynamically matching Home',
        () async {
      await SpHelper.clearAll();
      final now = DateTime.now();

      final order1 = OrderModel(
        bookingId: 'WC-101',
        wasteType: 'Recyclable Waste',
        pickupDate: now,
        address: 'Test address',
        fullAddress: 'Test full address',
        contact: 'Test user',
        status: OrderStatus.completed,
      );

      final order2 = OrderModel(
        bookingId: 'WC-102',
        wasteType: 'Recyclable Waste',
        pickupDate: now,
        address: 'Test address',
        fullAddress: 'Test full address',
        contact: 'Test user',
        status: OrderStatus.completed,
      );

      OrderStore.instance.orders.value = [order1, order2];

      final vm = MyAccountViewModel();
      expect(vm.wasteCollected, 10.0);

      // Add a third completed pickup dynamically
      final order3 = OrderModel(
        bookingId: 'WC-103',
        wasteType: 'Recyclable Waste',
        pickupDate: now,
        address: 'Test address',
        fullAddress: 'Test full address',
        contact: 'Test user',
        status: OrderStatus.completed,
      );

      OrderStore.instance.orders.value = [order1, order2, order3];
      expect(vm.wasteCollected, 15.0);
    });
  });
}
