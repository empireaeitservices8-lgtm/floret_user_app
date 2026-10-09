import 'package:intl/intl.dart';

/// Helper to format date strings safely
String formatWalletDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return '';
  try {
    final parsed = DateTime.parse(rawDate).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  } catch (_) {
    return rawDate;
  }
}

/// Helper to format date-only strings
String formatShortDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return '';
  try {
    final parsed = DateTime.parse(rawDate).toLocal();
    return DateFormat('dd MMM yyyy').format(parsed);
  } catch (_) {
    return rawDate;
  }
}

/// Model for GET /api/wallet/balance/
class WalletBalanceDataModel {
  final int? id;
  final int? user;
  final double balance;
  final bool autoTopupEnabled;
  final double? autoTopupTriggerAmount;
  final double? autoTopupAmount;
  final bool mandateAuthorized;
  final String? mandateId;
  final String? mandateAuthorizedAt;
  final String? createdAt;
  final String? updatedAt;

  const WalletBalanceDataModel({
    this.id,
    this.user,
    this.balance = 0.0,
    this.autoTopupEnabled = false,
    this.autoTopupTriggerAmount,
    this.autoTopupAmount,
    this.mandateAuthorized = false,
    this.mandateId,
    this.mandateAuthorizedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletBalanceDataModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceDataModel(
      id: (json['id'] as num?)?.toInt(),
      user: (json['user'] as num?)?.toInt(),
      balance: (json['balance'] is String)
          ? double.tryParse(json['balance']) ?? 0.0
          : (json['balance'] as num?)?.toDouble() ?? 0.0,
      autoTopupEnabled: json['auto_topup_enabled'] as bool? ?? false,
      autoTopupTriggerAmount:
          (json['auto_topup_trigger_amount'] as num?)?.toDouble(),
      autoTopupAmount: (json['auto_topup_amount'] as num?)?.toDouble(),
      mandateAuthorized: json['mandate_authorized'] as bool? ?? false,
      mandateId: json['mandate_id']?.toString(),
      mandateAuthorizedAt: json['mandate_authorized_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'balance': balance,
        'auto_topup_enabled': autoTopupEnabled,
        'auto_topup_trigger_amount': autoTopupTriggerAmount,
        'auto_topup_amount': autoTopupAmount,
        'mandate_authorized': mandateAuthorized,
        'mandate_id': mandateId,
        'mandate_authorized_at': mandateAuthorizedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

/// Model for GET /api/wallet/topup/
class WalletTopupConfigModel {
  final List<int> predefinedAmounts;
  final int minAmount;
  final int maxAmount;

  const WalletTopupConfigModel({
    this.predefinedAmounts = const [500, 1000, 1500, 2000],
    this.minAmount = 500,
    this.maxAmount = 2000,
  });

  factory WalletTopupConfigModel.fromJson(Map<String, dynamic> json) {
    return WalletTopupConfigModel(
      predefinedAmounts: (json['predefined_amounts'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [500, 1000, 1500, 2000],
      minAmount: (json['min_amount'] as num?)?.toInt() ?? 500,
      maxAmount: (json['max_amount'] as num?)?.toInt() ?? 2000,
    );
  }

  Map<String, dynamic> toJson() => {
        'predefined_amounts': predefinedAmounts,
        'min_amount': minAmount,
        'max_amount': maxAmount,
      };
}

/// Model for single transaction item in GET /api/wallet/transactions/
class WalletTransactionItemModel {
  final dynamic id;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final String status;
  final String paymentMethod;
  final Map<String, dynamic> rawJson;

  const WalletTransactionItemModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.status = 'Completed',
    this.paymentMethod = 'razorpay',
    this.rawJson = const {},
  });

  factory WalletTransactionItemModel.fromJson(Map<String, dynamic> json) {
    // Amount parsing
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      parsedAmount = (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] as num?)?.toDouble() ?? 0.0;
    } else if (json['final_payable_amount'] != null) {
      parsedAmount = (json['final_payable_amount'] is String)
          ? double.tryParse(json['final_payable_amount']) ?? 0.0
          : (json['final_payable_amount'] as num?)?.toDouble() ?? 0.0;
    } else if (json['wallet_amount_used'] != null) {
      parsedAmount = (json['wallet_amount_used'] is String)
          ? double.tryParse(json['wallet_amount_used']) ?? 0.0
          : (json['wallet_amount_used'] as num?)?.toDouble() ?? 0.0;
    }

    // Is credit check
    bool credit = false;
    if (json['is_credit'] != null) {
      credit = json['is_credit'] == true;
    } else if (json['transaction_type'] != null) {
      final type = json['transaction_type'].toString().toLowerCase();
      credit = type.contains('credit') || type.contains('topup') || type.contains('add');
    } else if (json['type'] != null) {
      final type = json['type'].toString().toLowerCase();
      credit = type.contains('credit') || type.contains('topup') || type.contains('add');
    }

    // Title / Description
    String title = json['title']?.toString() ??
        json['description']?.toString() ??
        json['remarks']?.toString() ??
        json['notes']?.toString() ??
        (credit ? 'Manual wallet top-up' : 'Doorstep Pickup Payment');

    // Date formatting
    final rawDate = json['created_at']?.toString() ??
        json['date']?.toString() ??
        json['pickup_date']?.toString() ??
        '';
    final formattedDate = formatWalletDate(rawDate);

    // Status
    final status = json['status']?.toString().toUpperCase() ?? 'COMPLETED';

    // Payment method
    final paymentMethod = json['payment_method']?.toString() ??
        json['gateway']?.toString() ??
        json['source']?.toString() ??
        'razorpay';

    return WalletTransactionItemModel(
      id: json['id'] ?? '',
      title: title,
      date: formattedDate.isNotEmpty ? formattedDate : rawDate,
      amount: parsedAmount,
      isCredit: credit,
      status: status,
      paymentMethod: paymentMethod,
      rawJson: json,
    );
  }
}

/// Model for GET /api/wallet/transactions/
class WalletTransactionsResponseModel {
  final List<WalletTransactionItemModel> transactions;
  final int total;
  final double currentBalance;

  const WalletTransactionsResponseModel({
    this.transactions = const [],
    this.total = 0,
    this.currentBalance = 0.0,
  });

  factory WalletTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['transactions'] as List<dynamic>? ?? const [];
    final items = rawList
        .map((e) => WalletTransactionItemModel.fromJson(
            e is Map ? Map<String, dynamic>.from(e) : {}))
        .toList();

    return WalletTransactionsResponseModel(
      transactions: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      currentBalance: (json['current_balance'] is String)
          ? double.tryParse(json['current_balance']) ?? 0.0
          : (json['current_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model for config object in GET /api/reward-points/
class RewardPointsConfigModel {
  final int? id;
  final double earningsRatio;
  final double redemptionValue;
  final int pointsExpiryDays;
  final int minimumRedemptionPoints;
  final bool isActive;
  final String? updatedAt;

  const RewardPointsConfigModel({
    this.id,
    this.earningsRatio = 100.0,
    this.redemptionValue = 0.25,
    this.pointsExpiryDays = 30,
    this.minimumRedemptionPoints = 1000,
    this.isActive = true,
    this.updatedAt,
  });

  factory RewardPointsConfigModel.fromJson(Map<String, dynamic> json) {
    return RewardPointsConfigModel(
      id: (json['id'] as num?)?.toInt(),
      earningsRatio: (json['earnings_ratio'] is String)
          ? double.tryParse(json['earnings_ratio']) ?? 100.0
          : (json['earnings_ratio'] as num?)?.toDouble() ?? 100.0,
      redemptionValue: (json['redemption_value'] is String)
          ? double.tryParse(json['redemption_value']) ?? 0.25
          : (json['redemption_value'] as num?)?.toDouble() ?? 0.25,
      pointsExpiryDays: (json['points_expiry_days'] as num?)?.toInt() ?? 30,
      minimumRedemptionPoints:
          (json['minimum_redemption_points'] as num?)?.toInt() ?? 1000,
      isActive: json['is_active'] as bool? ?? true,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

/// Model for GET /api/reward-points/
class RewardPointsDataModel {
  final int? id;
  final int? user;
  final int totalEarned;
  final int totalRedeemed;
  final int totalExpired;
  final int availablePoints;
  final double monetaryValue;
  final RewardPointsConfigModel? config;
  final String? createdAt;
  final String? updatedAt;

  const RewardPointsDataModel({
    this.id,
    this.user,
    this.totalEarned = 0,
    this.totalRedeemed = 0,
    this.totalExpired = 0,
    this.availablePoints = 0,
    this.monetaryValue = 0.0,
    this.config,
    this.createdAt,
    this.updatedAt,
  });

  factory RewardPointsDataModel.fromJson(Map<String, dynamic> json) {
    return RewardPointsDataModel(
      id: (json['id'] as num?)?.toInt(),
      user: (json['user'] as num?)?.toInt(),
      totalEarned: (json['total_earned'] as num?)?.toInt() ?? 0,
      totalRedeemed: (json['total_redeemed'] as num?)?.toInt() ?? 0,
      totalExpired: (json['total_expired'] as num?)?.toInt() ?? 0,
      availablePoints: (json['available_points'] as num?)?.toInt() ?? 0,
      monetaryValue: (json['monetary_value'] is String)
          ? double.tryParse(json['monetary_value']) ?? 0.0
          : (json['monetary_value'] as num?)?.toDouble() ?? 0.0,
      config: json['config'] is Map<String, dynamic>
          ? RewardPointsConfigModel.fromJson(
              json['config'] as Map<String, dynamic>)
          : (json['config'] is Map
              ? RewardPointsConfigModel.fromJson(
                  Map<String, dynamic>.from(json['config'] as Map))
              : null),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

/// Model for single transaction item in GET /api/reward-points/transactions/
class RewardPointsTransactionItemModel {
  final dynamic id;
  final String title;
  final String date;
  final int points;
  final String type; // 'earned', 'redeemed', 'expired'
  final String status;
  final Map<String, dynamic> rawJson;

  const RewardPointsTransactionItemModel({
    required this.id,
    required this.title,
    required this.date,
    required this.points,
    required this.type,
    this.status = 'Completed',
    this.rawJson = const {},
  });

  factory RewardPointsTransactionItemModel.fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as num?)?.toInt() ??
        (json['amount'] as num?)?.toInt() ??
        0;
    final type = json['transaction_type']?.toString().toLowerCase() ??
        json['type']?.toString().toLowerCase() ??
        (points >= 0 ? 'earned' : 'redeemed');

    final title = json['title']?.toString() ??
        json['description']?.toString() ??
        (type == 'earned'
            ? 'Points Earned'
            : (type == 'redeemed' ? 'Points Redeemed' : 'Points Expired'));

    final rawDate = json['created_at']?.toString() ??
        json['date']?.toString() ??
        '';
    final formattedDate = formatWalletDate(rawDate);

    return RewardPointsTransactionItemModel(
      id: json['id'] ?? '',
      title: title,
      date: formattedDate.isNotEmpty ? formattedDate : rawDate,
      points: points.abs(),
      type: type,
      status: json['status']?.toString().toUpperCase() ?? 'COMPLETED',
      rawJson: json,
    );
  }
}

/// Model for GET /api/reward-points/transactions/
class RewardPointsTransactionsResponseModel {
  final List<RewardPointsTransactionItemModel> transactions;
  final int total;
  final int availablePoints;
  final int totalEarned;
  final int totalRedeemed;
  final int totalExpired;

  const RewardPointsTransactionsResponseModel({
    this.transactions = const [],
    this.total = 0,
    this.availablePoints = 0,
    this.totalEarned = 0,
    this.totalRedeemed = 0,
    this.totalExpired = 0,
  });

  factory RewardPointsTransactionsResponseModel.fromJson(
      Map<String, dynamic> json) {
    final rawList = json['transactions'] as List<dynamic>? ?? const [];
    final items = rawList
        .map((e) => RewardPointsTransactionItemModel.fromJson(
            e is Map ? Map<String, dynamic>.from(e) : {}))
        .toList();

    return RewardPointsTransactionsResponseModel(
      transactions: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      availablePoints: (json['available_points'] as num?)?.toInt() ?? 0,
      totalEarned: (json['total_earned'] as num?)?.toInt() ?? 0,
      totalRedeemed: (json['total_redeemed'] as num?)?.toInt() ?? 0,
      totalExpired: (json['total_expired'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Model for item in GET /api/pickups/
class PickupItemDataModel {
  final dynamic id;
  final int? bagsUsed;
  final String? rejectionReason;
  final String? fullName;
  final String? email;
  final String? contactNumber;
  final String? street;
  final String? city;
  final String? zipCode;
  final String? state;
  final String? district;
  final String? localbody;
  final String? wardName;
  final String? landmark;
  final String? pickupDate;
  final String? pickupTimeSlot;
  final String? status;
  final String? itemsDescription;
  final String? wasteType;
  final String? createdAt;
  final String? collectorName;
  final String? vehicleName;
  final String? vehicleNumber;
  final double walletAmountUsed;
  final double finalPayableAmount;
  final int? user;
  final Map<String, dynamic> rawJson;

  const PickupItemDataModel({
    this.id,
    this.bagsUsed,
    this.rejectionReason,
    this.fullName,
    this.email,
    this.contactNumber,
    this.street,
    this.city,
    this.zipCode,
    this.state,
    this.district,
    this.localbody,
    this.wardName,
    this.landmark,
    this.pickupDate,
    this.pickupTimeSlot,
    this.status,
    this.itemsDescription,
    this.wasteType,
    this.createdAt,
    this.collectorName,
    this.vehicleName,
    this.vehicleNumber,
    this.walletAmountUsed = 0.0,
    this.finalPayableAmount = 0.0,
    this.user,
    this.rawJson = const {},
  });

  factory PickupItemDataModel.fromJson(Map<String, dynamic> json) {
    return PickupItemDataModel(
      id: json['id'],
      bagsUsed: (json['bags_used'] as num?)?.toInt(),
      rejectionReason: json['rejection_reason'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      contactNumber: json['contact_number'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      zipCode: json['zip_code']?.toString(),
      state: json['state'] as String?,
      district: json['district'] as String?,
      localbody: json['localbody'] as String?,
      wardName: json['ward_name'] as String?,
      landmark: json['landmark'] as String?,
      pickupDate: json['pickup_date'] as String?,
      pickupTimeSlot: json['pickup_time_slot'] as String?,
      status: json['status'] as String?,
      itemsDescription: json['items_description'] as String?,
      wasteType: json['waste_type'] as String?,
      createdAt: json['created_at'] as String?,
      collectorName: json['collector_name'] as String?,
      vehicleName: json['vehicle_name'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      walletAmountUsed: (json['wallet_amount_used'] is String)
          ? double.tryParse(json['wallet_amount_used']) ?? 0.0
          : (json['wallet_amount_used'] as num?)?.toDouble() ?? 0.0,
      finalPayableAmount: (json['final_payable_amount'] is String)
          ? double.tryParse(json['final_payable_amount']) ?? 0.0
          : (json['final_payable_amount'] as num?)?.toDouble() ?? 0.0,
      user: (json['user'] as num?)?.toInt(),
      rawJson: json,
    );
  }
}

/// Aggregate bundle model for WalletScreen state
class WalletDataBundle {
  final WalletBalanceDataModel walletBalance;
  final WalletTopupConfigModel walletTopupConfig;
  final WalletTransactionsResponseModel walletTransactions;
  final RewardPointsDataModel rewardPoints;
  final RewardPointsTransactionsResponseModel rewardPointsTransactions;
  final List<PickupItemDataModel> pickups;

  const WalletDataBundle({
    this.walletBalance = const WalletBalanceDataModel(),
    this.walletTopupConfig = const WalletTopupConfigModel(),
    this.walletTransactions = const WalletTransactionsResponseModel(),
    this.rewardPoints = const RewardPointsDataModel(),
    this.rewardPointsTransactions =
        const RewardPointsTransactionsResponseModel(),
    this.pickups = const [],
  });
}
