class BillModel {
  final String userName;
  final int pickupId;
  final int billId;
  final double weight;
  final double rate;
  final double totalAmount;
  final double? subtotal;
  final String paymentMethod;
  final String paymentStatus;
  final String transactionId;
  final String paymentGateway;
  final String remarks;
  final String? invoiceNo;
  final String? invoiceDate;
  final String? companyName;
  final String? tagline;
  final String? logoUrl;
  final String? supportEmail;
  final String? helpline;
  final String? itemDescription;
  final double? gst;
  final String? primaryColor;
  final String? accentColor;

  const BillModel({
    required this.userName,
    required this.pickupId,
    required this.billId,
    required this.weight,
    required this.rate,
    required this.totalAmount,
    this.subtotal,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    required this.paymentGateway,
    required this.remarks,
    this.invoiceNo,
    this.invoiceDate,
    this.companyName,
    this.tagline,
    this.logoUrl,
    this.supportEmail,
    this.helpline,
    this.itemDescription,
    this.gst,
    this.primaryColor,
    this.accentColor,
  });

  String get formattedInvoiceNo {
    if (invoiceNo != null && invoiceNo!.isNotEmpty) return invoiceNo!;
    return billId > 0 ? 'FLT-INV-$billId' : 'FLT-INV-68';
  }

  String get formattedDate {
    if (invoiceDate != null && invoiceDate!.isNotEmpty) return invoiceDate!;
    return '26-10-2026 10:38:00';
  }

  double get wasteProcessingAmount => weight * rate;

  double get disposalFeeGst {
    final fee = totalAmount - wasteProcessingAmount;
    return fee > 0 ? fee : 7.56;
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    // Check if response is wrapped under 'invoice' or 'bill'
    final Map<String, dynamic> data = (json['invoice'] is Map)
        ? Map<String, dynamic>.from(json['invoice'] as Map)
        : (json['bill'] is Map)
            ? Map<String, dynamic>.from(json['bill'] as Map)
            : json;

    // Handle /api/download-bill-invoice/ structure
    if (data.containsKey('invoice_meta') || data.containsKey('customer_details')) {
      final customerDetails = data['customer_details'] is Map
          ? Map<String, dynamic>.from(data['customer_details'] as Map)
          : null;
      final invoiceMeta = data['invoice_meta'] is Map
          ? Map<String, dynamic>.from(data['invoice_meta'] as Map)
          : null;
      final paymentInfo = data['payment_info'] is Map
          ? Map<String, dynamic>.from(data['payment_info'] as Map)
          : null;
      final financials = data['financials'] is Map
          ? Map<String, dynamic>.from(data['financials'] as Map)
          : null;
      final items = data['item_details'] is List && (data['item_details'] as List).isNotEmpty
          ? (data['item_details'] as List).first as Map?
          : null;
      final branding = data['branding'] is Map
          ? Map<String, dynamic>.from(data['branding'] as Map)
          : null;
      final designTheme = data['design_theme'] is Map
          ? Map<String, dynamic>.from(data['design_theme'] as Map)
          : null;

      final invoiceNo = invoiceMeta?['invoice_no']?.toString() ?? '';
      final billIdParsed = int.tryParse(invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 68;
      final pickupIdParsed = int.tryParse(customerDetails?['pickup_id']?.toString() ?? '') ?? 182;

      double parseNum(dynamic val, double fallback) {
        if (val == null) return fallback;
        if (val is num) return val.toDouble();
        final match = RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(val.toString());
        if (match != null) {
          return double.tryParse(match.group(0)!) ?? fallback;
        }
        return fallback;
      }

      final weight = parseNum(items?['weight_kg'], 1.0);
      final rate = parseNum(items?['rate_per_kg'], 42.0);
      final subtotal = parseNum(
        financials?['subtotal'],
        parseNum(financials?['total_amount'], 0.0),
      );
      final totalAmount = subtotal > 0
          ? subtotal
          : parseNum(financials?['total_amount'], 0.0);
      final gst = parseNum(financials?['gst'], 0.0);

      return BillModel(
        userName: customerDetails?['name']?.toString() ?? '917306929058',
        pickupId: pickupIdParsed,
        billId: billIdParsed,
        weight: weight,
        rate: rate,
        totalAmount: totalAmount,
        subtotal: subtotal,
        paymentMethod: paymentInfo?['method']?.toString() ?? 'cash',
        paymentStatus: invoiceMeta?['status']?.toString().toLowerCase() ?? 'paid',
        transactionId: paymentInfo?['transaction_id']?.toString() ?? 'BILL-252',
        paymentGateway: paymentInfo?['gateway']?.toString() ?? '',
        remarks: data['remarks']?.toString() ?? 'Waste collection payment',
        invoiceNo: invoiceNo.isNotEmpty ? invoiceNo : null,
        invoiceDate: invoiceMeta?['date']?.toString(),
        companyName: branding?['company_name']?.toString(),
        tagline: branding?['tagline']?.toString(),
        logoUrl: branding?['logo_url']?.toString(),
        supportEmail: branding?['support_email']?.toString(),
        helpline: branding?['helpline']?.toString(),
        itemDescription: items?['description']?.toString(),
        gst: gst,
        primaryColor: designTheme?['primary_color']?.toString(),
        accentColor: designTheme?['accent_color']?.toString(),
      );
    }

    return BillModel(
      userName: data['user_name']?.toString() ?? '917306929058',
      pickupId: (data['pickup_id'] as num?)?.toInt() ??
          int.tryParse(data['pickup_id']?.toString() ?? '') ??
          168,
      billId: (data['bill_id'] as num?)?.toInt() ??
          int.tryParse(data['bill_id']?.toString() ?? '') ??
          66,
      weight: (data['weight'] as num?)?.toDouble() ??
          double.tryParse(data['weight']?.toString() ?? '') ??
          1.0,
      rate: (data['rate'] as num?)?.toDouble() ??
          double.tryParse(data['rate']?.toString() ?? '') ??
          42.0,
      totalAmount: (data['subtotal'] as num?)?.toDouble() ??
          double.tryParse(data['subtotal']?.toString() ?? '') ??
          (data['total_amount'] as num?)?.toDouble() ??
          double.tryParse(data['total_amount']?.toString() ?? '') ??
          0.0,
      subtotal: (data['subtotal'] as num?)?.toDouble() ??
          double.tryParse(data['subtotal']?.toString() ?? ''),
      paymentMethod: data['payment_method']?.toString() ?? 'cash',
      paymentStatus: data['payment_status']?.toString() ?? 'paid',
      transactionId:
          data['transaction_id']?.toString() ?? 'CASH-1791886722066',
      paymentGateway: data['payment_gateway']?.toString() ?? '',
      remarks: data['remarks']?.toString() ?? 'Waste collection payment',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_name': userName,
        'pickup_id': pickupId,
        'bill_id': billId,
        'weight': weight,
        'rate': rate,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'transaction_id': transactionId,
        'payment_gateway': paymentGateway,
        'remarks': remarks,
      };

  static const BillModel sample = BillModel(
    userName: '917306929058',
    pickupId: 182,
    billId: 68,
    weight: 1.00,
    rate: 42.00,
    totalAmount: 49.56,
    subtotal: 49.56,
    paymentMethod: 'cash',
    paymentStatus: 'paid',
    transactionId: 'BILL-252',
    paymentGateway: '',
    remarks: 'Gross: ₹49.56 | Voucher (FLT-250): -₹0.00 | Wallet: -₹0.00 | Paid: ₹49.56 via cash',
  );
}
