class BillModel {
  final String userName;
  final int pickupId;
  final int billId;
  final double weight;
  final double rate;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String transactionId;
  final String paymentGateway;
  final String remarks;

  const BillModel({
    required this.userName,
    required this.pickupId,
    required this.billId,
    required this.weight,
    required this.rate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    required this.paymentGateway,
    required this.remarks,
  });

  double get wasteProcessingAmount => weight * rate;

  double get disposalFeeGst {
    final fee = totalAmount - wasteProcessingAmount;
    return fee > 0 ? fee : 7.56;
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      userName: json['user_name']?.toString() ?? '917306929058',
      pickupId: (json['pickup_id'] as num?)?.toInt() ?? 168,
      billId: (json['bill_id'] as num?)?.toInt() ?? 66,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 42.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 49.56,
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      paymentStatus: json['payment_status']?.toString() ?? 'paid',
      transactionId:
          json['transaction_id']?.toString() ?? 'CASH-1791886722066',
      paymentGateway: json['payment_gateway']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? 'Waste collection payment',
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
    pickupId: 168,
    billId: 66,
    weight: 1.00,
    rate: 42.00,
    totalAmount: 49.56,
    paymentMethod: 'cash',
    paymentStatus: 'paid',
    transactionId: 'CASH-1791886722066',
    paymentGateway: '',
    remarks: 'Waste collection payment',
  );
}
