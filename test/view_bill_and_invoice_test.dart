import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/features/profile/model/bill_model.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/features/profile/screen/pickup_bill_bottom_sheet.dart';
import 'package:floret_app/features/profile/screen/official_invoice_screen.dart';

class MockProfileRepoForInvoice extends ProfileRepository {
  final List<OrderModel> mockOrders;
  final Function(dynamic pickupId)? onDownloadBill;

  MockProfileRepoForInvoice(this.mockOrders, {this.onDownloadBill});

  @override
  Future<List<OrderModel>> fetchOrderHistory({String? token}) async {
    return mockOrders;
  }

  @override
  Future<BillModel?> downloadBillInvoice(dynamic pickupId,
      {String? token}) async {
    if (onDownloadBill != null) {
      return onDownloadBill!(pickupId);
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleBackendResponse = {
    "invoice": {
      "branding": {
        "company_name": "Florettechnologies",
        "tagline": "Clean City, Green Future",
        "logo_url":
            "https://florettechuser.pythonanywhere.com/static/images/canvas.png",
        "support_email": "support@florettech.com",
        "helpline": "+91 94460 02666"
      },
      "invoice_meta": {
        "invoice_no": "FLT-INV-227",
        "date": "16-11-2026 07:06:28",
        "status": "PAID"
      },
      "customer_details": {"name": "919995723146_644", "pickup_id": "545"},
      "item_details": [
        {
          "description": "Recyclable Waste Collection",
          "weight_kg": "10.00 kg",
          "rate_per_kg": "Rs. 40.00",
          "amount": "Rs. 400.00"
        },
        {
          "description": "Bag fee (₹7/bag) + GST",
          "bag_count": "1 bags",
          "amount": "Rs. 7.00"
        }
      ],
      "financials": {
        "subtotal": "Rs. 407.00",
        "gst": "Rs. 73.26",
        "total_amount": "Rs. 576.45"
      },
      "payment_info": {
        "method": "cash",
        "transaction_id": "BILL-437",
        "gateway": "N/A"
      },
      "remarks":
          "Gross: ₹576.45 | Voucher (FLT-250): -₹0.00 | Wallet: -₹0.00 | Paid: ₹576.45 via cash",
      "design_theme": {
        "primary_color": "#2E7D32",
        "accent_color": "#81C784",
        "font_family": "Roboto, sans-serif"
      }
    }
  };

  final completedOrder545 = OrderModel(
    id: 545,
    bookingId: 'WC-545',
    wasteType: 'Recyclable Waste',
    pickupDate: DateTime(2026, 11, 16),
    completedDate: DateTime(2026, 11, 16, 7, 6, 28),
    address: 'Varkala, Thiruvananthapuram',
    fullAddress: 'Varkala, Thiruvananthapuram',
    contact: '+919995723146',
    status: OrderStatus.completed,
    userId: '461',
    paymentStatus: 'paid',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.saveString(sp_keys.keyToken, 'test_token');
    await SpHelper.saveString(sp_keys.keyUserId, '461');
  });

  group('View Bill and Invoice - 10 Fields & API Verification', () {
    test('1. BillModel correctly parses exact response fields', () {
      final bill = BillModel.fromJson(sampleBackendResponse);

      expect(bill.pickupId, equals(545));
      expect(bill.invoiceNo, equals('FLT-INV-227'));
      expect(bill.displayDateTime, equals('16-11-2026 07:06:28'));
      expect(bill.displayPaymentMode, equals('Cash'));
      expect(bill.displayTransactionId, equals('BILL-437'));
      expect(bill.displayBagCount, equals('1 bags'));
      expect(bill.displayRateOfBag, equals('₹7/bag'));
      expect(bill.weight, equals(10.0));
      expect(bill.displayWeight, equals('10.00 kg'));
      expect(bill.rate, equals(40.0));
      expect(bill.displayRatePerKg, equals('₹40.00/kg'));
      expect(bill.subtotal, equals(407.0));
      expect(bill.displaySubtotal, equals('₹407.00'));
      expect(bill.gst, equals(73.26));
      expect(bill.displayGst, equals('₹73.26'));
      expect(bill.totalAmount, equals(576.45));
      expect(bill.displayTotalAmount, equals('₹576.45'));
    });

    testWidgets(
        '2. Tapping on View Bill under completed calls API and shows 10 requested fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      dynamic capturedPickupId;
      final parsedBill = BillModel.fromJson(sampleBackendResponse);
      final repo = MockProfileRepoForInvoice(
        [completedOrder545],
        onDownloadBill: (id) {
          capturedPickupId = id;
          return parsedBill;
        },
      );
      OrderStore.instance.orders.value = [completedOrder545];

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Completed" tab filter
      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();

      // Tap on "View Bill" button
      final viewBillBtn = find.text('View Bill');
      expect(viewBillBtn, findsOneWidget);
      await tester.tap(viewBillBtn);
      await tester.pumpAndSettle();

      // Verify API was called with pickupId 545
      expect(capturedPickupId, equals(545));

      // Verify PickupBillBottomSheet opened
      expect(find.byType(PickupBillBottomSheet), findsOneWidget);
      expect(find.text('Bill Breakdown'), findsOneWidget);

      // Verify the 10 requested fields:
      // 1. payment mode
      expect(find.text('Payment Mode'), findsOneWidget);
      expect(find.text('Cash'), findsWidgets);

      // 2. transaction id
      expect(find.text('Transaction ID'), findsOneWidget);
      expect(find.text('BILL-437'), findsOneWidget);

      // 3. date abd time
      expect(find.text('Date & Time'), findsOneWidget);
      expect(find.text('16-11-2026 07:06:28'), findsOneWidget);

      // 4. weight
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('10.00 kg'), findsOneWidget);

      // 5. rate per kg
      expect(find.text('Rate per kg'), findsOneWidget);
      expect(find.text('₹40.00/kg'), findsOneWidget);

      // 6. bag count
      expect(find.text('Bag Count'), findsOneWidget);
      expect(find.text('1 bags'), findsOneWidget);

      // 7. rate of bag
      expect(find.text('Rate of Bag'), findsOneWidget);
      expect(find.text('₹7/bag'), findsOneWidget);

      // 8. sub total
      expect(find.text('Sub Total'), findsOneWidget);
      expect(find.text('₹407.00'), findsOneWidget);

      // 9. GST/tax
      expect(find.text('GST / Tax'), findsOneWidget);
      expect(find.text('₹73.26'), findsOneWidget);

      // 10. total amount
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('₹576.45'), findsOneWidget);
    });

    testWidgets(
        '3. Tapping on Invoice under completed calls API and shows fields on Official Invoice',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      dynamic capturedPickupId;
      final parsedBill = BillModel.fromJson(sampleBackendResponse);
      final repo = MockProfileRepoForInvoice(
        [completedOrder545],
        onDownloadBill: (id) {
          capturedPickupId = id;
          return parsedBill;
        },
      );
      OrderStore.instance.orders.value = [completedOrder545];

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Completed" tab
      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();

      // Tap on "Invoice" button
      final invoiceBtn = find.text('Invoice');
      expect(invoiceBtn, findsOneWidget);
      await tester.tap(invoiceBtn);
      await tester.pumpAndSettle();

      // Verify API was called with pickupId 545
      expect(capturedPickupId, equals(545));

      // Verify OfficialInvoiceScreen is displayed
      expect(find.byType(OfficialInvoiceScreen), findsOneWidget);
      expect(find.text('Official Invoice'), findsOneWidget);
      expect(find.text('INVOICE #FLT-INV-227'), findsOneWidget);
      expect(find.text('16-11-2026 07:06:28'), findsOneWidget);
      expect(find.text('#545'), findsOneWidget);

      // Check Line items & pricing
      expect(find.text('Recyclable Waste Collection'), findsOneWidget);
      expect(find.text('Weight: 10.00 kg'), findsOneWidget);
      expect(find.text('Rate: ₹40.00/kg'), findsOneWidget);
      expect(find.text('Bag count: 1 bags'), findsOneWidget);
      expect(find.text('Rate of bag: ₹7/bag'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('₹407.00'), findsOneWidget);
      expect(find.text('GST / Tax'), findsOneWidget);
      expect(find.text('₹73.26'), findsOneWidget);
      expect(find.text('TOTAL AMOUNT PAID'), findsOneWidget);
      expect(find.text('₹576.45'), findsOneWidget);

      // Check Payment specifications
      expect(find.text('Method'), findsOneWidget);
      expect(find.text('CASH'), findsOneWidget);
      expect(find.text('Transaction ID'), findsOneWidget);
      expect(find.text('BILL-437'), findsOneWidget);
    });

    testWidgets(
        '4. In Official Invoice tap on Download / Print PDF invoice calls API {{base_url}}/api/download-bill-invoice/?pickup_id=545',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int apiCallCount = 0;
      dynamic capturedPickupId;
      final parsedBill = BillModel.fromJson(sampleBackendResponse);
      final repo = MockProfileRepoForInvoice(
        [completedOrder545],
        onDownloadBill: (id) {
          apiCallCount++;
          capturedPickupId = id;
          return parsedBill;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OfficialInvoiceScreen(
            order: completedOrder545,
            initialBill: parsedBill,
            repository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Official Invoice'), findsOneWidget);
      final downloadPdfBtn = find.text('Download / Print PDF Invoice');
      expect(downloadPdfBtn, findsOneWidget);

      // Tap on Download / Print PDF Invoice
      await tester.tap(downloadPdfBtn);
      await tester.pumpAndSettle();

      // Verify downloadBillInvoice was called with pickup_id = 545
      expect(apiCallCount, equals(1));
      expect(capturedPickupId, equals(545));

      // Verify official invoice page is shown with all details
      expect(find.text('Official Invoice'), findsWidgets);
      expect(find.text('INVOICE #FLT-INV-227'), findsWidgets);
      expect(find.text('#545'), findsWidgets);
      expect(find.text('LINE ITEMS & PRICING'), findsWidgets);
      expect(find.text('PAYMENT SPECIFICATIONS'), findsWidgets);
      expect(find.text('₹407.00'), findsWidgets);
      expect(find.text('₹576.45'), findsWidgets);

      // Verify PDF button and Download / Print PDF Invoice button are NOT shown
      expect(find.text('PDF'), findsNothing);
      expect(find.text('Download / Print PDF Invoice'), findsNothing);
    });
  });
}
