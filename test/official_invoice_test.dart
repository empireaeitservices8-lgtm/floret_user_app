import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/profile/model/order_model.dart';
import 'package:floret_app/features/profile/model/bill_model.dart';
import 'package:floret_app/features/profile/repos/profile_repository.dart';
import 'package:floret_app/features/profile/screen/order_history_screen.dart';
import 'package:floret_app/features/profile/screen/official_invoice_screen.dart';
import 'package:floret_app/features/profile/screen/invoice_pdf_preview_screen.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/invoice_pdf_service.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:shared_preferences/shared_preferences.dart';

class MockProfileRepository extends ProfileRepository {
  final List<OrderModel> mockOrders;
  final BillModel? Function(dynamic pickupId)? onDownloadBill;
  MockProfileRepository(this.mockOrders, {this.onDownloadBill});

  @override
  Future<List<OrderModel>> fetchOrderHistory({String? token}) async {
    return mockOrders;
  }

  @override
  Future<BillModel?> downloadBillInvoice(dynamic pickupId, {String? token}) async {
    if (onDownloadBill != null) {
      return onDownloadBill!(pickupId);
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.saveString(sp_keys.keyToken, 'mock_token');
    await SpHelper.saveString(sp_keys.keyUserId, '101');
    await OrderStore.instance.loadForUser('101');
  });

  group('Completed Order History & Official Invoice Tests', () {
    final completedOrder = OrderModel(
      bookingId: 'WC-168',
      wasteType: 'Sanitary waste',
      pickupDate: DateTime(2026, 10, 13),
      completedDate: DateTime(2026, 10, 15, 12, 56, 9),
      address: 'gsgshbsvnskbsbndn, Thiruvananthapuram',
      fullAddress: 'gsgshbsvnskbsbndn, Thiruvananthapuram',
      contact: '917306929058',
      status: OrderStatus.completed,
      userId: '101',
      weight: 1.0,
    );

    final pendingOrder = OrderModel(
      bookingId: 'WC-200',
      wasteType: 'Recyclable waste',
      pickupDate: DateTime(2026, 10, 20),
      address: 'Kowdiar, Thiruvananthapuram',
      fullAddress: 'Kowdiar, Thiruvananthapuram',
      contact: '917306929058',
      status: OrderStatus.pending,
      userId: '101',
    );

    testWidgets(
        '1. Completed order shows Paid badge and Invoice button, while pending does not',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = MockProfileRepository([completedOrder, pendingOrder]);
      OrderStore.instance.orders.value = [completedOrder, pendingOrder];

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Check completed card has 'Paid' badge and 'Invoice' button
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Invoice'), findsOneWidget);
      expect(find.text('View Bill'), findsNWidgets(2));

      // Filter to Completed tab
      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();

      expect(find.text('WC-168'), findsOneWidget);
      expect(find.text('WC-200'), findsNothing);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Invoice'), findsOneWidget);
    });

    testWidgets('2. Tap on Invoice opens OfficialInvoiceScreen matching Images 2 & 3',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = MockProfileRepository([completedOrder]);
      OrderStore.instance.orders.value = [completedOrder];

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Invoice button
      await tester.tap(find.text('Invoice'));
      await tester.pumpAndSettle();

      // Check OfficialInvoiceScreen elements
      expect(find.text('Official Invoice'), findsOneWidget);
      expect(find.text('Florettechnologies'), findsOneWidget);
      expect(find.text('Clean City, Green Future'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget);
      expect(find.textContaining('INVOICE #FLT-INV-'), findsOneWidget);

      // Customer & Pickup details
      expect(find.text('CUSTOMER & PICKUP DETAILS'), findsOneWidget);
      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('917306929058'), findsOneWidget);
      expect(find.text('Pickup Reference'), findsOneWidget);

      // Line items & pricing
      expect(find.text('LINE ITEMS & PRICING'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('GST / Tax'), findsOneWidget);
      expect(find.text('TOTAL AMOUNT PAID'), findsOneWidget);
      expect(find.text('₹49.56'), findsWidgets);

      // Payment specifications
      expect(find.text('PAYMENT SPECIFICATIONS'), findsOneWidget);
      expect(find.text('Method'), findsOneWidget);
      expect(find.text('CASH'), findsOneWidget);
      expect(find.text('Transaction ID'), findsOneWidget);
      expect(find.text('BILL-252'), findsOneWidget);

      // Download / Print PDF button
      expect(find.text('Download / Print PDF Invoice'), findsOneWidget);
      expect(
          find.text(
              'Questions? Contact support@florettech.com or call +91 94460 02666'),
          findsOneWidget);
    });

    testWidgets(
        '3. Tap on Download / Print PDF Invoice opens InvoicePdfPreviewScreen matching Image 4',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: OfficialInvoiceScreen(
            order: completedOrder,
            initialBill: BillModel.sample,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Download / Print PDF Invoice'
      await tester.tap(find.text('Download / Print PDF Invoice'));
      await tester.pumpAndSettle();

      // Check InvoicePdfPreviewScreen elements (Image 4)
      expect(find.byType(InvoicePdfPreviewScreen), findsOneWidget);
      expect(find.text('Select a printer'), findsOneWidget);
      expect(find.text('Copies:   1'), findsOneWidget);
      expect(find.text('Paper size:   ISO A4'), findsOneWidget);

      // A4 Sheet elements
      expect(find.text('FLORETTECHNOLOGIES'), findsOneWidget);
      expect(find.text('INVOICE'), findsOneWidget);
      expect(find.text('BILLED TO:'), findsOneWidget);
      expect(find.text('DATE & STATUS:'), findsOneWidget);
      expect(find.text('DESCRIPTION'), findsOneWidget);
      expect(find.text('QTY / WEIGHT'), findsOneWidget);
      expect(find.text('RATE (Rs./kg)'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);
      expect(find.text('PAYMENT INFORMATION'), findsOneWidget);

      // Bottom bar
      expect(find.text('1/1'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets(
        '4. PDF icon button in OfficialInvoiceScreen AppBar opens InvoicePdfPreviewScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: OfficialInvoiceScreen(
            order: completedOrder,
            initialBill: BillModel.sample,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'PDF' action button in AppBar
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();

      expect(find.text('Select a printer'), findsOneWidget);
      expect(find.text('1/1'), findsOneWidget);
    });

    test('5. InvoicePdfService generates valid vector PDF bytes with order and bill details', () async {
      final pdfBytes = await InvoicePdfService.instance.generateInvoicePdfBytes(
        order: completedOrder,
        bill: BillModel.sample,
      );

      // Verify PDF header magic bytes "%PDF-"
      expect(pdfBytes.length, greaterThan(1000));
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    testWidgets(
        '6. InvoicePdfPreviewScreen contains working Download Invoice and Print Invoice buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: InvoicePdfPreviewScreen(
            order: completedOrder,
            bill: BillModel.sample,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Download Invoice and Print Invoice buttons
      final printBtn = find.byKey(const Key('print_invoice_button'));
      final downloadBtn = find.byKey(const Key('download_invoice_button'));

      expect(printBtn, findsOneWidget);
      expect(downloadBtn, findsOneWidget);
      expect(find.text('Print Invoice'), findsOneWidget);
      expect(find.text('Download Invoice'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Verify tapping print button works
      await tester.tap(printBtn);
      await tester.pump();

      // Verify tapping download button works
      await tester.tap(downloadBtn);
      await tester.pump();
    });

    testWidgets(
        '7. Tapping on Invoice under completed calls downloadBillInvoice API and displays backend invoice data',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final completedOrder357 = OrderModel(
        id: 357,
        bookingId: 'WC-357',
        wasteType: 'Recyclable Waste',
        pickupDate: DateTime(2026, 10, 26),
        completedDate: DateTime(2026, 10, 26, 10, 38, 00),
        address: 'Sunset Blvd, Thiruvananthapuram',
        fullAddress: 'Sunset Blvd, Thiruvananthapuram',
        contact: '917306929058',
        status: OrderStatus.completed,
        userId: '101',
        paymentStatus: 'paid',
      );

      final Map<String, dynamic> sampleBackendInvoice = {
        'invoice': {
          'branding': {
            'company_name': 'Florettechnologies',
            'tagline': 'Clean City, Green Future',
            'logo_url':
                'https://florettechuser.pythonanywhere.com/static/images/canvas.png',
            'support_email': 'support@florettech.com',
            'helpline': '+91 94460 02666',
          },
          'invoice_meta': {
            'invoice_no': 'FLT-INV-115',
            'date': '26-10-2026 10:38:00',
            'status': 'PAID',
          },
          'customer_details': {
            'name': '917306929058_471',
            'pickup_id': 357,
          },
          'item_details': [
            {
              'description': 'Recyclable Waste Collection',
              'weight_kg': '5.00 kg',
              'rate_per_kg': 'Rs. 42.00',
              'amount': 'Rs. 256.06',
            }
          ],
          'financials': {
            'subtotal': 'Rs. 256.06',
            'gst': 'Rs. 0.00',
            'total_amount': 'Rs. 256.06',
          },
          'payment_info': {
            'method': 'cash',
            'transaction_id': 'BILL-315',
            'gateway': 'N/A',
          },
          'remarks':
              'Gross: ₹256.06 | Voucher (FLT-250): -₹0.00 | Wallet: -₹0.00 | Paid: ₹256.06 via cash',
          'design_theme': {
            'primary_color': '#2E7D32',
            'accent_color': '#81C784',
            'font_family': 'Roboto, sans-serif',
          },
        }
      };

      dynamic capturedPickupId;
      final repo = MockProfileRepository(
        [completedOrder357],
        onDownloadBill: (id) {
          capturedPickupId = id;
          return BillModel.fromJson(sampleBackendInvoice);
        },
      );
      OrderStore.instance.orders.value = [completedOrder357];

      await tester.pumpWidget(
        MaterialApp(
          home: OrderHistoryScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Invoice button
      final invoiceBtn = find.text('Invoice');
      expect(invoiceBtn, findsOneWidget);
      await tester.tap(invoiceBtn);
      await tester.pumpAndSettle();

      // Verify API was called with pickupId 357
      expect(capturedPickupId, equals(357));

      // Verify OfficialInvoiceScreen displays parsed data from API
      expect(find.text('Official Invoice'), findsOneWidget);
      expect(find.text('INVOICE #FLT-INV-115'), findsOneWidget);
      expect(find.text('26-10-2026 10:38:00'), findsOneWidget);
      expect(find.text('917306929058_471'), findsOneWidget);
      expect(find.text('#357'), findsOneWidget);
      expect(find.text('Recyclable Waste Collection'), findsOneWidget);
      expect(find.text('Weight: 5.00 kg'), findsOneWidget);
      expect(find.text('Rate: ₹42.00/kg'), findsOneWidget);
      expect(find.text('₹256.06'), findsWidgets);
      expect(
          find.textContaining('Paid: ₹256.06 via cash', findRichText: true),
          findsOneWidget);
    });
  });
}
