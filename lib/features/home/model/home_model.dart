class PickupOptionModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String estimatedWeight;

  const PickupOptionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.estimatedWeight,
  });
}

class PickupBookingModel {
  final String optionId;
  final String pickupDate;
  final String timeSlot;
  final String addressId;
  final String? notes;

  const PickupBookingModel({
    required this.optionId,
    required this.pickupDate,
    required this.timeSlot,
    required this.addressId,
    this.notes,
  });
}

class HomeBannerModel {
  final String title;
  final String subtitle;
  final String actionText;

  const HomeBannerModel({
    required this.title,
    required this.subtitle,
    required this.actionText,
  });
}

/// Model for GET /api/home/
class HomeOverviewModel {
  final String? username;
  final int pendingBills;
  final int scheduledPickups;
  final double totalRecycledWeight;
  final String? message;

  const HomeOverviewModel({
    this.username,
    this.pendingBills = 0,
    this.scheduledPickups = 0,
    this.totalRecycledWeight = 0.0,
    this.message,
  });

  HomeOverviewModel copyWith({
    String? username,
    int? pendingBills,
    int? scheduledPickups,
    double? totalRecycledWeight,
    String? message,
  }) {
    return HomeOverviewModel(
      username: username ?? this.username,
      pendingBills: pendingBills ?? this.pendingBills,
      scheduledPickups: scheduledPickups ?? this.scheduledPickups,
      totalRecycledWeight: totalRecycledWeight ?? this.totalRecycledWeight,
      message: message ?? this.message,
    );
  }

  factory HomeOverviewModel.fromJson(Map<String, dynamic> json) {
    double parseWeight(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return HomeOverviewModel(
      username: json['username']?.toString(),
      pendingBills: (json['pending_bills'] as num?)?.toInt() ?? 0,
      scheduledPickups: (json['scheduled_pickups'] as num?)?.toInt() ?? 0,
      totalRecycledWeight: parseWeight(
        json['total_recycled_weight'] ??
            json['totalRecycledWeight'] ??
            json['recycled_weight'] ??
            json['recycledWeight'],
      ),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'pending_bills': pendingBills,
        'scheduled_pickups': scheduledPickups,
        'total_recycled_weight': totalRecycledWeight,
        'message': message,
      };
}

/// Model for GET /api/recycle-progress/
class RecycleProgressModel {
  final String? username;
  final double totalRecycledWeight;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final int totalPickups;

  const RecycleProgressModel({
    this.username,
    this.totalRecycledWeight = 0.0,
    this.totalPaidAmount = 0.0,
    this.totalPendingAmount = 0.0,
    this.totalPickups = 0,
  });

  RecycleProgressModel copyWith({
    String? username,
    double? totalRecycledWeight,
    double? totalPaidAmount,
    double? totalPendingAmount,
    int? totalPickups,
  }) {
    return RecycleProgressModel(
      username: username ?? this.username,
      totalRecycledWeight: totalRecycledWeight ?? this.totalRecycledWeight,
      totalPaidAmount: totalPaidAmount ?? this.totalPaidAmount,
      totalPendingAmount: totalPendingAmount ?? this.totalPendingAmount,
      totalPickups: totalPickups ?? this.totalPickups,
    );
  }

  factory RecycleProgressModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return RecycleProgressModel(
      username: json['username']?.toString(),
      totalRecycledWeight: parseDouble(
        json['total_recycled_weight'] ??
            json['totalRecycledWeight'] ??
            json['recycled_weight'],
      ),
      totalPaidAmount: parseDouble(
        json['total_paid_amount'] ??
            json['totalPaidAmount'] ??
            json['paid_amount'],
      ),
      totalPendingAmount: parseDouble(
        json['total_pending_amount'] ??
            json['totalPendingAmount'] ??
            json['pending_amount'],
      ),
      totalPickups: parseInt(
        json['total_pickups'] ??
            json['totalPickups'] ??
            json['pickups_count'] ??
            json['pickups'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'total_recycled_weight': totalRecycledWeight,
        'total_paid_amount': totalPaidAmount,
        'total_pending_amount': totalPendingAmount,
        'total_pickups': totalPickups,
      };
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

  WalletBalanceDataModel copyWith({
    int? id,
    int? user,
    double? balance,
    bool? autoTopupEnabled,
    double? autoTopupTriggerAmount,
    double? autoTopupAmount,
    bool? mandateAuthorized,
    String? mandateId,
    String? mandateAuthorizedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return WalletBalanceDataModel(
      id: id ?? this.id,
      user: user ?? this.user,
      balance: balance ?? this.balance,
      autoTopupEnabled: autoTopupEnabled ?? this.autoTopupEnabled,
      autoTopupTriggerAmount:
          autoTopupTriggerAmount ?? this.autoTopupTriggerAmount,
      autoTopupAmount: autoTopupAmount ?? this.autoTopupAmount,
      mandateAuthorized: mandateAuthorized ?? this.mandateAuthorized,
      mandateId: mandateId ?? this.mandateId,
      mandateAuthorizedAt: mandateAuthorizedAt ?? this.mandateAuthorizedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model for GET /api/wallet/transactions/
class WalletTransactionsResponseModel {
  final List<dynamic> transactions;
  final int total;
  final double currentBalance;

  const WalletTransactionsResponseModel({
    this.transactions = const [],
    this.total = 0,
    this.currentBalance = 0.0,
  });

  factory WalletTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponseModel(
      transactions: json['transactions'] as List<dynamic>? ?? const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      currentBalance: (json['current_balance'] is String)
          ? double.tryParse(json['current_balance']) ?? 0.0
          : (json['current_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
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
      earningsRatio: (json['earnings_ratio'] as num?)?.toDouble() ?? 100.0,
      redemptionValue: (json['redemption_value'] as num?)?.toDouble() ?? 0.25,
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
      monetaryValue: (json['monetary_value'] as num?)?.toDouble() ?? 0.0,
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

/// Model for GET /api/reward-points/transactions/
class RewardPointsTransactionsResponseModel {
  final List<dynamic> transactions;
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
    return RewardPointsTransactionsResponseModel(
      transactions: json['transactions'] as List<dynamic>? ?? const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
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
  final String? title;
  final String? status;
  final String? pickupDate;
  final String? timeSlot;
  final String? address;
  final Map<String, dynamic> rawJson;

  const PickupItemDataModel({
    this.id,
    this.title,
    this.status,
    this.pickupDate,
    this.timeSlot,
    this.address,
    this.rawJson = const {},
  });

  factory PickupItemDataModel.fromJson(Map<String, dynamic> json) {
    return PickupItemDataModel(
      id: json['id'],
      title: json['title'] as String? ?? json['type'] as String?,
      status: json['status'] as String?,
      pickupDate: json['pickup_date'] as String? ?? json['date'] as String?,
      timeSlot: json['time_slot'] as String? ?? json['slot'] as String?,
      address: json['address']?.toString(),
      rawJson: json,
    );
  }
}

/// Aggregate bundle model for HomeScreen state
class HomeDataBundle {
  final HomeOverviewModel homeOverview;
  final RecycleProgressModel recycleProgress;
  final WalletBalanceDataModel walletBalance;
  final WalletTransactionsResponseModel walletTransactions;
  final WalletTopupConfigModel walletTopupConfig;
  final RewardPointsDataModel rewardPoints;
  final RewardPointsTransactionsResponseModel rewardPointsTransactions;
  final List<PickupItemDataModel> pickups;

  const HomeDataBundle({
    this.homeOverview = const HomeOverviewModel(),
    this.recycleProgress = const RecycleProgressModel(),
    this.walletBalance = const WalletBalanceDataModel(),
    this.walletTransactions = const WalletTransactionsResponseModel(),
    this.walletTopupConfig = const WalletTopupConfigModel(),
    this.rewardPoints = const RewardPointsDataModel(),
    this.rewardPointsTransactions =
        const RewardPointsTransactionsResponseModel(),
    this.pickups = const [],
  });

  HomeDataBundle copyWith({
    HomeOverviewModel? homeOverview,
    RecycleProgressModel? recycleProgress,
    WalletBalanceDataModel? walletBalance,
    WalletTransactionsResponseModel? walletTransactions,
    WalletTopupConfigModel? walletTopupConfig,
    RewardPointsDataModel? rewardPoints,
    RewardPointsTransactionsResponseModel? rewardPointsTransactions,
    List<PickupItemDataModel>? pickups,
  }) {
    return HomeDataBundle(
      homeOverview: homeOverview ?? this.homeOverview,
      recycleProgress: recycleProgress ?? this.recycleProgress,
      walletBalance: walletBalance ?? this.walletBalance,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      walletTopupConfig: walletTopupConfig ?? this.walletTopupConfig,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardPointsTransactions:
          rewardPointsTransactions ?? this.rewardPointsTransactions,
      pickups: pickups ?? this.pickups,
    );
  }
}

