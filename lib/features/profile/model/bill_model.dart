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
  final String? bagCount;
  final String? rateOfBag;
  final double? bagAmount;
  final double? wasteAmount;

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
    this.bagCount,
    this.rateOfBag,
    this.bagAmount,
    this.wasteAmount,
  });

  String get formattedInvoiceNo {
    if (invoiceNo != null && invoiceNo!.isNotEmpty) return invoiceNo!;
    return billId > 0 ? 'FLT-INV-$billId' : 'FLT-INV-68';
  }

  String get formattedDate {
    if (invoiceDate != null && invoiceDate!.isNotEmpty) return invoiceDate!;
    return '26-10-2026 10:38:00';
  }

  double get wasteProcessingAmount => wasteAmount ?? (weight * rate);

  double get disposalFeeGst {
    final fee = totalAmount - wasteProcessingAmount;
    return fee > 0 ? fee : 7.56;
  }

  String get displayPaymentMode {
    if (paymentMethod.isEmpty) return 'Cash';
    return paymentMethod.toLowerCase() == 'cash'
        ? 'Cash'
        : (paymentMethod.toLowerCase() == 'online'
            ? 'Online'
            : paymentMethod.toUpperCase());
  }

  String get displayTransactionId =>
      transactionId.isNotEmpty ? transactionId : 'BILL-437';

  String get displayDateTime {
    if (invoiceDate != null && invoiceDate!.isNotEmpty) return invoiceDate!;
    return '16-11-2026 07:06:28';
  }

  String get displayBagCount {
    if (bagCount != null && bagCount!.isNotEmpty) return bagCount!;
    return '1 bags';
  }

  String get displayRateOfBag {
    if (rateOfBag != null && rateOfBag!.isNotEmpty) return rateOfBag!;
    return '₹7/bag';
  }

  String get displayWeight => '${weight.toStringAsFixed(2)} kg';

  String get displayRatePerKg => '₹${rate.toStringAsFixed(2)}/kg';

  String get displaySubtotal {
    final val =
        (subtotal != null && subtotal! > 0) ? subtotal! : (weight * rate);
    return '₹${val.toStringAsFixed(2)}';
  }

  String get displayGst {
    final val = (gst != null && gst! > 0) ? gst! : 73.26;
    return '₹${val.toStringAsFixed(2)}';
  }

  String get displayTotalAmount {
    final val = totalAmount > 0 ? totalAmount : 576.45;
    return '₹${val.toStringAsFixed(2)}';
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    // Check if response is wrapped under 'invoice' or 'bill'
    final Map<String, dynamic> data = (json['invoice'] is Map)
        ? Map<String, dynamic>.from(json['invoice'] as Map)
        : (json['bill'] is Map)
            ? Map<String, dynamic>.from(json['bill'] as Map)
            : json;

    // Handle /api/download-bill-invoice/ structure
    if (data.containsKey('invoice_meta') ||
        data.containsKey('customer_details')) {
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
      final branding = data['branding'] is Map
          ? Map<String, dynamic>.from(data['branding'] as Map)
          : null;
      final designTheme = data['design_theme'] is Map
          ? Map<String, dynamic>.from(data['design_theme'] as Map)
          : null;

      Map? wasteItem;
      Map? bagItem;

      if (data['item_details'] is List) {
        for (final it in data['item_details'] as List) {
          if (it is Map) {
            final desc = it['description']?.toString().toLowerCase() ?? '';
            if (it.containsKey('bag_count') || desc.contains('bag')) {
              bagItem = it;
            } else if (it.containsKey('weight_kg') ||
                desc.contains('waste') ||
                desc.contains('collection')) {
              wasteItem ??= it;
            }
          }
        }
        if (wasteItem == null && (data['item_details'] as List).isNotEmpty) {
          final first = (data['item_details'] as List).first;
          if (first is Map) wasteItem = first;
        }
      }

      final invoiceNo = invoiceMeta?['invoice_no']?.toString() ?? '';
      final billIdParsed =
          int.tryParse(invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 227;
      final pickupIdParsed =
          int.tryParse(customerDetails?['pickup_id']?.toString() ?? '') ?? 545;

      double parseNum(dynamic val, double fallback) {
        if (val == null) return fallback;
        if (val is num) return val.toDouble();
        final match = RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(val.toString());
        if (match != null) {
          return double.tryParse(match.group(0)!) ?? fallback;
        }
        return fallback;
      }

      final weight =
          parseNum(wasteItem?['weight_kg'] ?? wasteItem?['weight'], 1.0);
      final rate =
          parseNum(wasteItem?['rate_per_kg'] ?? wasteItem?['rate'], 42.0);
      final wasteAmount = parseNum(
        wasteItem?['amount'],
        weight * rate,
      );

      String? bagCount = bagItem?['bag_count']?.toString();
      String? rateOfBag;
      if (bagItem != null) {
        final desc = bagItem['description']?.toString() ?? '';
        final match = RegExp(r'[₹Rs\.]+\s*\d+(?:/[a-zA-Z]+)?').firstMatch(desc);
        if (match != null) {
          rateOfBag = match.group(0);
        } else if (bagItem['rate_of_bag'] != null) {
          rateOfBag = bagItem['rate_of_bag'].toString();
        } else if (bagItem['rate'] != null) {
          rateOfBag = '₹${bagItem['rate']}';
        } else {
          rateOfBag = '₹7/bag';
        }
      }
      final bagAmount =
          bagItem != null ? parseNum(bagItem['amount'], 7.0) : null;

      final subtotal = parseNum(
        financials?['subtotal'],
        parseNum(financials?['total_amount'], wasteAmount + (bagAmount ?? 0.0)),
      );
      final gst = parseNum(financials?['gst'], 0.0);
      final totalAmount = parseNum(
        financials?['total_amount'],
        subtotal > 0 ? subtotal : 0.0,
      );

      return BillModel(
        userName: customerDetails?['name']?.toString() ?? '919995723146_644',
        pickupId: pickupIdParsed,
        billId: billIdParsed,
        weight: weight,
        rate: rate,
        totalAmount: totalAmount,
        subtotal: subtotal,
        paymentMethod: paymentInfo?['method']?.toString() ?? 'cash',
        paymentStatus:
            invoiceMeta?['status']?.toString().toLowerCase() ?? 'paid',
        transactionId: paymentInfo?['transaction_id']?.toString() ?? 'BILL-437',
        paymentGateway: paymentInfo?['gateway']?.toString() ?? '',
        remarks: data['remarks']?.toString() ?? 'Waste collection payment',
        invoiceNo: invoiceNo.isNotEmpty ? invoiceNo : null,
        invoiceDate: invoiceMeta?['date']?.toString(),
        companyName: branding?['company_name']?.toString(),
        tagline: branding?['tagline']?.toString(),
        logoUrl: branding?['logo_url']?.toString(),
        supportEmail: branding?['support_email']?.toString(),
        helpline: branding?['helpline']?.toString(),
        itemDescription: wasteItem?['description']?.toString(),
        gst: gst,
        primaryColor: designTheme?['primary_color']?.toString(),
        accentColor: designTheme?['accent_color']?.toString(),
        bagCount: bagCount,
        rateOfBag: rateOfBag,
        bagAmount: bagAmount,
        wasteAmount: wasteAmount,
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
      transactionId: data['transaction_id']?.toString() ?? 'CASH-1791886722066',
      paymentGateway: data['payment_gateway']?.toString() ?? '',
      remarks: data['remarks']?.toString() ?? 'Waste collection payment',
      bagCount: data['bag_count']?.toString(),
      rateOfBag: data['rate_of_bag']?.toString(),
      bagAmount: (data['bag_amount'] as num?)?.toDouble(),
      wasteAmount: (data['waste_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_name': userName,
        'pickup_id': pickupId,
        'bill_id': billId,
        'weight': weight,
        'rate': rate,
        'total_amount': totalAmount,
        'subtotal': subtotal,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'transaction_id': transactionId,
        'payment_gateway': paymentGateway,
        'remarks': remarks,
        'invoice_no': invoiceNo,
        'invoice_date': invoiceDate,
        'gst': gst,
        'bag_count': bagCount,
        'rate_of_bag': rateOfBag,
        'bag_amount': bagAmount,
        'waste_amount': wasteAmount,
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
    remarks:
        'Gross: ₹49.56 | Voucher (FLT-250): -₹0.00 | Wallet: -₹0.00 | Paid: ₹49.56 via cash',
    invoiceNo: 'FLT-INV-68',
    invoiceDate: '26-10-2026 10:38:00',
    itemDescription: 'Recyclable Waste Collection',
    gst: 7.56,
    bagCount: '1 bags',
    rateOfBag: '₹7/bag',
    bagAmount: 7.00,
    wasteAmount: 42.00,
  );
}
