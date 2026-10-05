class WalletBalanceModel {
  final double balance;
  final int rewardPoints;
  final double pendingAmount;

  const WalletBalanceModel({
    this.balance = 250.00,
    this.rewardPoints = 120,
    this.pendingAmount = 0.00,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 250.00,
      rewardPoints: json['rewardPoints'] as int? ?? 120,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.00,
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'rewardPoints': rewardPoints,
        'pendingAmount': pendingAmount,
      };
}

class WalletTransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final String status;

  const WalletTransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.status = 'Success',
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isCredit: json['isCredit'] as bool? ?? false,
      status: json['status'] as String? ?? 'Success',
    );
  }
}

class EcoRewardModel {
  final String id;
  final String title;
  final int pointsRequired;
  final String discountText;

  const EcoRewardModel({
    required this.id,
    required this.title,
    required this.pointsRequired,
    required this.discountText,
  });
}
