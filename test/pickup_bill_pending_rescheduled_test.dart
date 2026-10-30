import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/screen/pickup_bill_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pickup Bill Details - Pending and Rescheduled Tests', () {
    testWidgets(
        'Tapping View Bill on a Pending order displays Bill Pending Generation bottom sheet matching image',
        (tester) async {
      final pendingOrder = OrderModel(
        id: 352,
        bookingId: 'WC-352',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 26),
        address: 'Sunset Blvd, Thiruvananthapuram',
        fullAddress: 'Sunset Blvd, Thiruvananthapuram',
        contact: '+919995723146',
        status: OrderStatus.pending,
        rawStatus: 'pending',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () => showPickupBillBottomSheet(
                      context,
                      pendingOrder,
                      isPendingBill: true,
                    ),
                    child: const Text('Open Bill'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Bill'));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Pickup Bill Details'), findsOneWidget);
      expect(find.byKey(const Key('close_bill_bottom_sheet_icon')),
          findsOneWidget);

      // Verify Order Item Card
      expect(find.text('WC-352'), findsOneWidget);
      expect(find.text('Sanitary waste'), findsOneWidget);

      // Verify Pending Bill Content matching screenshot
      expect(find.text('Bill Pending Generation'), findsOneWidget);
      expect(
        find.text(
          'The collector has not yet submitted the live bill breakdown for this pickup. The live breakdown will be displayed here as soon as the collector submits the bill.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);

      // Verify Close Button
      expect(
          find.byKey(const Key('close_pending_bill_button')), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.byKey(const Key('close_pending_bill_button')));
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed
      expect(find.text('Bill Pending Generation'), findsNothing);
    });

    testWidgets(
        'Tapping View Bill on a Rescheduled order displays Bill Pending Generation bottom sheet matching image',
        (tester) async {
      final rescheduledOrder = OrderModel(
        id: 358,
        bookingId: 'WC-358',
        wasteType: 'Sanitary waste',
        pickupDate: DateTime(2026, 10, 30),
        address: 'Sunset Blvd, Thiruvananthapuram',
        fullAddress: 'Sunset Blvd, Thiruvananthapuram',
        contact: '+919995723146',
        status: OrderStatus.reschedule,
        rawStatus: 'rescheduled',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () => showPickupBillBottomSheet(
                      context,
                      rescheduledOrder,
                      isPendingBill: true,
                    ),
                    child: const Text('Open Bill'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Bill'));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Pickup Bill Details'), findsOneWidget);
      expect(find.text('WC-358'), findsOneWidget);
      expect(find.text('Sanitary waste'), findsOneWidget);

      // Verify Pending Bill Content
      expect(find.text('Bill Pending Generation'), findsOneWidget);
      expect(
        find.text(
          'The collector has not yet submitted the live bill breakdown for this pickup. The live breakdown will be displayed here as soon as the collector submits the bill.',
        ),
        findsOneWidget,
      );
    });
  });
}
