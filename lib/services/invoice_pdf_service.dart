import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import '../features/profile/model/bill_model.dart';
import '../features/profile/model/order_model.dart';

class InvoicePdfService {
  InvoicePdfService._();
  static final InvoicePdfService instance = InvoicePdfService._();

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute:$second';
  }

  /// Generates real vector PDF bytes for the given order and bill.
  Future<Uint8List> generateInvoicePdfBytes({
    required OrderModel order,
    required BillModel bill,
  }) async {
    final pdf = pw.Document();

    final invoiceNumber = bill.formattedInvoiceNo;
    final pickupRef = bill.pickupId > 0
        ? '#${bill.pickupId}'
        : '#${order.bookingId.replaceAll(RegExp(r'[^0-9]'), '')}';
    final customerName =
        bill.userName.isNotEmpty ? bill.userName : '917306929058';
    final invoiceDateStr = (bill.invoiceDate != null && bill.invoiceDate!.isNotEmpty)
        ? bill.invoiceDate!
        : (order.completedDate != null
            ? _formatDateTime(order.completedDate!)
            : '15-10-2026 12:56:09');
    final wasteTitle = (bill.itemDescription != null && bill.itemDescription!.isNotEmpty)
        ? bill.itemDescription!
        : (order.wasteType.toLowerCase().contains('waste')
            ? (order.wasteType.toLowerCase().contains('collection')
                ? order.wasteType
                : '${order.wasteType} Collection')
            : 'Recyclable Waste Collection');
    final weightStr = bill.weight.toStringAsFixed(2);
    final rateStr = bill.rate.toStringAsFixed(2);
    final subtotalVal = (bill.subtotal != null && bill.subtotal! > 0)
        ? bill.subtotal!
        : bill.totalAmount;
    final subtotalStr = subtotalVal.toStringAsFixed(2);
    final totalStr = subtotalStr;
    final methodStr = bill.paymentMethod.isNotEmpty
        ? bill.paymentMethod.toUpperCase()
        : 'CASH';
    final txnId = bill.transactionId.isNotEmpty ? bill.transactionId : 'BILL-252';
    final remarks = bill.remarks.isNotEmpty
        ? bill.remarks
        : 'Gross: Rs. $subtotalStr | Voucher (FLT-250): -Rs. 0.00 | Wallet: -Rs. 0.00 | Paid: Rs. $subtotalStr via ${methodStr.toLowerCase()}';
    final safeRemarks = remarks.replaceAll('₹', 'Rs. ');

    // Attempt to load logo image if available
    pw.MemoryImage? logoImage;
    try {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        final bytes = await rootBundle.load('assets/images/floret_logo.png');
        logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
      }
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Header: Logo & Company Name (Left) | INVOICE (Right)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 42,
                          height: 42,
                          margin: const pw.EdgeInsets.only(right: 10),
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Container(
                          width: 36,
                          height: 36,
                          margin: const pw.EdgeInsets.only(right: 10),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFF15803D),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'F',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'FLORETTECHNOLOGIES',
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF166534),
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Clean City, Green Future',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF166534),
                          letterSpacing: 1.0,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'No: $invoiceNumber',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Green accent divider
              pw.Container(
                height: 2,
                color: PdfColor.fromInt(0xFF4ADE80),
              ),

              pw.SizedBox(height: 16),

              // 2. Billed To & Date / Status
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILLED TO:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF94A3B8),
                          letterSpacing: 0.4,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        customerName,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1E293B),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Pickup ID: $pickupRef',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromInt(0xFF64748B),
                        ),
                      ),
                      if (order.address.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          order.address,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColor.fromInt(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'DATE & STATUS:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF94A3B8),
                          letterSpacing: 0.4,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        invoiceDateStr,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1E293B),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF16A34A),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'PAID',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // 3. Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromInt(0xFFE2E8F0),
                    width: 0.8,
                  ),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  children: [
                    // Table Header
                    pw.Container(
                      color: PdfColor.fromInt(0xFF86EFAC),
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              'DESCRIPTION',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF065F46),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'QTY / WEIGHT',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF065F46),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'RATE (Rs./kg)',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF065F46),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'AMOUNT',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Body Row
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              wasteTitle,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF1E293B),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              '$weightStr kg',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColor.fromInt(0xFF1E293B),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'Rs. $rateStr',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColor.fromInt(0xFF1E293B),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'Rs. $totalStr',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // 4. Financial Totals (Right Aligned)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.SizedBox(
                  width: 240,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Subtotal:',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromInt(0xFF64748B),
                            ),
                          ),
                          pw.Text(
                            'Rs. $subtotalStr',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'GST / Tax:',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromInt(0xFF64748B),
                            ),
                          ),
                          pw.Text(
                            'Rs. 0.00',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        height: 1,
                        color: PdfColor.fromInt(0xFFE2E8F0),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Amount:',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF1E293B),
                            ),
                          ),
                          pw.Text(
                            'Rs. $totalStr',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 18),

              // 5. Payment Information Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF1F5F9),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF475569),
                        letterSpacing: 0.4,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Method: $methodStr',
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF1E293B),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Transaction ID: $txnId',
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColor.fromInt(0xFF1E293B),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      safeRemarks.startsWith('Remarks')
                          ? safeRemarks
                          : 'Remarks: $safeRemarks',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColor.fromInt(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // 6. Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                      color: PdfColor.fromInt(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Support: support@florettech.com',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColor.fromInt(0xFF94A3B8),
                      ),
                    ),
                    pw.Text(
                      'Helpline: +91 94460 02666',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColor.fromInt(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Downloads and saves the real PDF invoice on the device's storage,
  /// opens/views it, and returns the saved File object.
  Future<File?> downloadAndSaveInvoice({
    required BuildContext context,
    required OrderModel order,
    required BillModel bill,
  }) async {
    try {
      // 1. Permission check (for Android <= 12)
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final status = await Permission.storage.status;
          if (!status.isGranted && !status.isLimited) {
            await Permission.storage.request();
          }
        } catch (e) {
          debugPrint('[InvoicePdfService] Permission request warning: $e');
        }
      }

      // 2. Resolve target directory for saving file
      Directory? targetDir;
      if (!kIsWeb && Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          targetDir = downloadDir;
        } else {
          targetDir = await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory();
        }
      } else if (!kIsWeb && Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      } else {
        targetDir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final invoiceNumber =
          bill.billId > 0 ? 'FLT-INV-${bill.billId}' : 'FLT-INV-68';
      final safeInvoiceNo =
          invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final fileName = '${safeInvoiceNo}_Invoice.pdf';
      File file = File('${targetDir.path}/$fileName');

      // 3. Generate real PDF bytes
      final pdfBytes =
          await generateInvoicePdfBytes(order: order, bill: bill);

      // 4. Write bytes to file on phone with fallback
      try {
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        await file.writeAsBytes(pdfBytes, flush: true);
      } catch (writeErr) {
        debugPrint(
            '[InvoicePdfService] Primary write error: $writeErr, falling back to app documents directory');
        final fallbackDir = await getApplicationDocumentsDirectory();
        if (!await fallbackDir.exists()) {
          await fallbackDir.create(recursive: true);
        }
        final fallbackFile = File('${fallbackDir.path}/$fileName');
        await fallbackFile.writeAsBytes(pdfBytes, flush: true);
        file = fallbackFile;
      }

      // 5. Open and view the PDF with phone's available app
      try {
        await OpenFilex.open(file.path);
      } catch (openErr) {
        debugPrint('[InvoicePdfService] OpenFilex error: $openErr');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice saved: $fileName'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Share',
              textColor: const Color(0xFF4ADE80),
              onPressed: () {
                shareInvoice(context: context, order: order, bill: bill);
              },
            ),
          ),
        );
      }

      return file;
    } catch (e) {
      debugPrint('[InvoicePdfService] Error saving invoice: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  /// Opens the phone's native print spooler / printer selector to print the invoice.
  Future<void> printInvoice({
    required BuildContext context,
    required OrderModel order,
    required BillModel bill,
  }) async {
    try {
      final pdfBytes =
          await generateInvoicePdfBytes(order: order, bill: bill);
      final invoiceNumber =
          bill.billId > 0 ? 'FLT-INV-${bill.billId}' : 'FLT-INV-68';
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '${invoiceNumber}_Invoice.pdf',
      );
    } catch (e) {
      debugPrint('[InvoicePdfService] Print error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print invoice: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Opens the phone's native sharing sheet (WhatsApp, Gmail, Files, Drive, etc.).
  Future<void> shareInvoice({
    required BuildContext context,
    required OrderModel order,
    required BillModel bill,
  }) async {
    try {
      final pdfBytes =
          await generateInvoicePdfBytes(order: order, bill: bill);
      final invoiceNumber =
          bill.billId > 0 ? 'FLT-INV-${bill.billId}' : 'FLT-INV-68';
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${invoiceNumber}_Invoice.pdf',
      );
    } catch (e) {
      debugPrint('[InvoicePdfService] Share error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share invoice: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
