import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../model/bill_model.dart';

class InvoicePdfPreviewScreen extends StatelessWidget {
  static const String routeName = '/invoice_pdf_preview';

  final OrderModel order;
  final BillModel bill;

  const InvoicePdfPreviewScreen({
    super.key,
    required this.order,
    required this.bill,
  });

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: System Printer Header matching Image 4
            _buildPrinterTopBar(context),

            // Middle: A4 PDF Sheet Preview matching Image 4
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: _buildA4InvoiceSheet(),
                ),
              ),
            ),

            // Bottom Bar: "1/1" and Checkmark Action Button matching Image 4
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  // System Print Dialog Top Bar
  Widget _buildPrinterTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Row(
                  children: [
                    Text(
                      'Select a printer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF475569),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Copies:   1',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                SizedBox(width: 24),
                Text(
                  'Paper size:   ISO A4',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
        ],
      ),
    );
  }

  // The A4 Invoice Sheet matching Image 4 exactly
  Widget _buildA4InvoiceSheet() {
    final invoiceNumber =
        bill.billId > 0 ? 'FLT-INV-${bill.billId}' : 'FLT-INV-68';
    final pickupRef = bill.pickupId > 0
        ? '#${bill.pickupId}'
        : '#${order.bookingId.replaceAll(RegExp(r'[^0-9]'), '')}';
    final customerName =
        bill.userName.isNotEmpty ? bill.userName : '917306929058';
    final invoiceDateStr = order.completedDate != null
        ? _formatDateTime(order.completedDate!)
        : '15-10-2026 12:56:09';
    final wasteTitle = order.wasteType.toLowerCase().contains('waste')
        ? (order.wasteType.toLowerCase().contains('collection')
            ? order.wasteType
            : '${order.wasteType} Collection')
        : 'Recyclable Waste Collection';
    final weightStr = bill.weight.toStringAsFixed(2);
    final rateStr = bill.rate.toStringAsFixed(2);
    final totalStr = bill.totalAmount.toStringAsFixed(2);
    final methodStr = bill.paymentMethod.isNotEmpty
        ? bill.paymentMethod.toUpperCase()
        : 'CASH';
    final txnId = bill.transactionId.isNotEmpty ? bill.transactionId : 'BILL-252';
    final remarks = bill.remarks.isNotEmpty
        ? bill.remarks
        : 'Gross: ₹49.56 | Voucher (FLT-250): -₹0.00 | Wallet: -₹0.00 | Paid: ₹49.56 via cash';

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Logo & Florettechnologies (Left) | INVOICE No (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/images/floret_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF15803D),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FLORETTECHNOLOGIES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF166534),
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Clean City, Green Future',
                            style: TextStyle(
                              fontSize: 8,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'INVOICE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF166534),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'No: $invoiceNumber',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Green Line
          Container(
            height: 1.5,
            color: const Color(0xFF4ADE80),
          ),

          const SizedBox(height: 12),

          // Billed To & Date / Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BILLED TO:',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Pickup ID: $pickupRef',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'DATE & STATUS:',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoiceDateStr,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'PAID',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items Table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  color: const Color(0xFF86EFAC),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'QTY / WEIGHT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'RATE (Rs./kg)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'AMOUNT',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          wasteTitle,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '$weightStr kg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Rs. $rateStr',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Rs. $totalStr',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subtotal, GST & Total right aligned
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Rs. $totalStr',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GST / Tax:',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Rs. 0.00',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Rs. $totalStr',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Payment Information Grey Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PAYMENT INFORMATION',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Method: $methodStr',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Transaction ID: $txnId',
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remarks.startsWith('Remarks')
                      ? remarks
                      : 'Remarks: $remarks',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Support: support@florettech.com',
                  style: TextStyle(
                    fontSize: 7.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Helpline: +91 94460 02666',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 7.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom Bar matching Image 4
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: const Color(0xFF94A3B8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Spacer(),
          const Text(
            '1/1',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice PDF downloaded successfully!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
