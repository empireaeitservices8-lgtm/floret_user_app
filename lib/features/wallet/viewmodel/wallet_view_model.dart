import 'package:flutter/foundation.dart';
import 'package:floret_app/providers/view_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import '../model/wallet_model.dart';
import '../repos/wallet_repository.dart';

class WalletViewModel extends ViewModel {
  final WalletRepository _repository;

  WalletViewModel({WalletRepository? repository, int initialPoints = 0})
      : _repository = repository ?? WalletRepository() {
    if (initialPoints > 0) {
      _walletBundle = WalletDataBundle(
        rewardPoints: RewardPointsDataModel(
          availablePoints: initialPoints,
          config: const RewardPointsConfigModel(
            minimumRedemptionPoints: 100,
          ),
        ),
      );
    }
    _initCachedBalance();
    loadWalletData();
  }

  Future<void> _initCachedBalance() async {
    try {
      final cachedAutoStr = await SpHelper.getString('auto_topup_enabled');
      final cachedTriggerStr =
          await SpHelper.getString('auto_topup_trigger_amount');
      final cachedAmountStr = await SpHelper.getString('auto_topup_amount');

      final cachedAuto =
          cachedAutoStr != null ? (cachedAutoStr == 'true') : null;
      final cachedTrigger =
          cachedTriggerStr != null ? double.tryParse(cachedTriggerStr) : null;
      final cachedAmount =
          cachedAmountStr != null ? double.tryParse(cachedAmountStr) : null;

      if (cachedAuto != null) {
        _walletBundle = _walletBundle.copyWith(
          walletBalance: _walletBundle.walletBalance.copyWith(
            autoTopupEnabled:
                cachedAuto ?? _walletBundle.walletBalance.autoTopupEnabled,
            autoTopupTriggerAmount: cachedTrigger ??
                _walletBundle.walletBalance.autoTopupTriggerAmount,
            autoTopupAmount:
                cachedAmount ?? _walletBundle.walletBalance.autoTopupAmount,
          ),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> updateAutoTopUpSettings({
    required bool enabled,
    double? threshold,
    double? amount,
  }) async {
    _walletBundle = _walletBundle.copyWith(
      walletBalance: _walletBundle.walletBalance.copyWith(
        autoTopupEnabled: enabled,
        autoTopupTriggerAmount:
            threshold ?? _walletBundle.walletBalance.autoTopupTriggerAmount,
        autoTopupAmount: amount ?? _walletBundle.walletBalance.autoTopupAmount,
      ),
    );
    notifyListeners();
    await SpHelper.saveString('auto_topup_enabled', enabled ? 'true' : 'false');
    await SpHelper.saveString('auto_topup_user_set', 'true');
    if (threshold != null) {
      await SpHelper.saveString(
          'auto_topup_trigger_amount', threshold.toString());
    }
    if (amount != null) {
      await SpHelper.saveString('auto_topup_amount', amount.toString());
    }
  }

  int _selectedActivityTab = 0; // 0: Wallet Activity, 1: Eco Rewards
  WalletDataBundle _walletBundle = const WalletDataBundle();
  bool _isRefreshing = false;

  int get selectedActivityTab => _selectedActivityTab;
  WalletDataBundle get walletBundle => _walletBundle;
  bool get isRefreshing => _isRefreshing;

  // Wallet Balance getters - Live from API response only
  WalletBalanceDataModel get balanceModel => _walletBundle.walletBalance;

  double get walletBalance => _walletBundle.walletBalance.balance;

  bool get autoTopupEnabled => _walletBundle.walletBalance.autoTopupEnabled;
  double get autoTopupTriggerAmount =>
      _walletBundle.walletBalance.autoTopupTriggerAmount ?? 100.0;
  double get autoTopupAmount =>
      _walletBundle.walletBalance.autoTopupAmount ?? 500.0;
  bool get mandateAuthorized => _walletBundle.walletBalance.mandateAuthorized;
  String? get mandateId => _walletBundle.walletBalance.mandateId;

  // Topup Config
  WalletTopupConfigModel get topupConfig => _walletBundle.walletTopupConfig;

  // Wallet Transactions
  List<WalletTransactionItemModel> get walletTransactions =>
      _walletBundle.walletTransactions.transactions;
  int get walletTransactionsTotal => _walletBundle.walletTransactions.total;

  // Reward Points getters
  RewardPointsDataModel get rewardPoints => _walletBundle.rewardPoints;
  int get availableSafaiPoints => _walletBundle.rewardPoints.availablePoints;
  int get totalEarned => _walletBundle.rewardPoints.totalEarned;
  int get totalRedeemed => _walletBundle.rewardPoints.totalRedeemed;
  int get totalExpired => _walletBundle.rewardPoints.totalExpired;
  double get monetaryValue => _walletBundle.rewardPoints.monetaryValue;
  RewardPointsConfigModel? get rewardConfig =>
      _walletBundle.rewardPoints.config;
  double get earningsRatio =>
      _walletBundle.rewardPoints.config?.earningsRatio ?? 100.0;
  double get redemptionValue =>
      _walletBundle.rewardPoints.config?.redemptionValue ?? 0.25;
  int get minimumRedemptionPoints =>
      _walletBundle.rewardPoints.config?.minimumRedemptionPoints ?? 1000;

  // Reward Points Transactions
  List<RewardPointsTransactionItemModel> get rewardPointsTransactions =>
      _walletBundle.rewardPointsTransactions.transactions;

  // Pickups
  List<PickupItemDataModel> get pickups => _walletBundle.pickups;

  void setActivityTab(int index) {
    if (_selectedActivityTab != index) {
      _selectedActivityTab = index;
      notifyListeners();
    }
    if (index == 1) {
      fetchRewardPoints();
      fetchRewardPointsTransactions();
    }
  }

  /// Fetches reward points directly from GET /api/reward-points/
  Future<RewardPointsDataModel> fetchRewardPoints() async {
    try {
      final points = await _repository.fetchRewardPoints();
      _walletBundle = _walletBundle.copyWith(rewardPoints: points);
      notifyListeners();
      return points;
    } catch (e) {
      debugPrint('⚠️ [WALLET VIEWMODEL] fetchRewardPoints error: $e');
      return _walletBundle.rewardPoints;
    }
  }

  /// Fetches reward points transactions directly from GET /api/reward-points/transactions/
  Future<RewardPointsTransactionsResponseModel>
      fetchRewardPointsTransactions() async {
    try {
      final transactions = await _repository.fetchRewardPointsTransactions();
      _walletBundle =
          _walletBundle.copyWith(rewardPointsTransactions: transactions);
      notifyListeners();
      return transactions;
    } catch (e) {
      debugPrint(
          '⚠️ [WALLET VIEWMODEL] fetchRewardPointsTransactions error: $e');
      return _walletBundle.rewardPointsTransactions;
    }
  }

  void setAvailablePoints(int points) {
    _walletBundle = _walletBundle.copyWith(
      rewardPoints: _walletBundle.rewardPoints.copyWith(
        availablePoints: points,
      ),
    );
    notifyListeners();
  }

  void setWalletBundle(WalletDataBundle bundle) {
    _walletBundle = bundle;
    notifyListeners();
  }

  Future<void> fetchTopupAndTransactions() async {
    try {
      final results = await Future.wait([
        _repository.fetchTopupConfig(),
        _repository.fetchTransactions(),
        _repository.fetchBalance(),
      ]);

      _walletBundle = WalletDataBundle(
        walletBalance: results[2] as WalletBalanceDataModel,
        walletTopupConfig: results[0] as WalletTopupConfigModel,
        walletTransactions: results[1] as WalletTransactionsResponseModel,
        rewardPoints: _walletBundle.rewardPoints,
        rewardPointsTransactions: _walletBundle.rewardPointsTransactions,
        pickups: _walletBundle.pickups,
      );
      notifyListeners();
    } catch (e) {
      // Retain previous state on error
    }
  }

  /// Fetches topup config directly from GET /api/wallet/topup/
  Future<WalletTopupConfigModel> fetchTopupConfig() async {
    try {
      final config = await _repository.fetchTopupConfig();
      _walletBundle = _walletBundle.copyWith(walletTopupConfig: config);
      notifyListeners();
      return config;
    } catch (e) {
      debugPrint('⚠️ [WALLET VIEWMODEL] fetchTopupConfig error: $e');
      return _walletBundle.walletTopupConfig;
    }
  }

  /// Fetches wallet balance directly from GET /api/wallet/balance/
  Future<WalletBalanceDataModel> fetchWalletBalance() async {
    try {
      var balance = await _repository.fetchBalance();
      final cachedAutoStr = await SpHelper.getString('auto_topup_enabled');
      if (cachedAutoStr != null) {
        balance = balance.copyWith(
          autoTopupEnabled: cachedAutoStr == 'true',
        );
      }
      _walletBundle = _walletBundle.copyWith(walletBalance: balance);
      notifyListeners();
      return balance;
    } catch (e) {
      debugPrint('⚠️ [WALLET VIEWMODEL] fetchWalletBalance error: $e');
      return _walletBundle.walletBalance;
    }
  }

  Future<void> loadWalletData({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      notifyListeners();
    } else {
      showLoading();
    }

    try {
      // 1. Fetch wallet balance directly from GET /api/wallet/balance/
      try {
        var bal = await _repository.fetchBalance();
        final cachedAutoStr = await SpHelper.getString('auto_topup_enabled');
        if (cachedAutoStr != null) {
          bal = bal.copyWith(
            autoTopupEnabled: cachedAutoStr == 'true',
          );
        }
        _walletBundle = _walletBundle.copyWith(walletBalance: bal);
        notifyListeners();
      } catch (balErr) {
        debugPrint('⚠️ [WALLET VIEWMODEL] direct balance fetch error: $balErr');
      }

      final bundle = await _repository.fetchAllWalletData();
      var freshBalance = bundle.walletBalance;

      final cachedAutoStr = await SpHelper.getString('auto_topup_enabled');
      if (cachedAutoStr != null) {
        freshBalance = freshBalance.copyWith(
          autoTopupEnabled: cachedAutoStr == 'true',
        );
      }

      _walletBundle = bundle.copyWith(
        walletBalance: freshBalance,
        walletTransactions:
            (_walletBundle.walletTransactions.transactions.isNotEmpty &&
                    bundle.walletTransactions.transactions.isEmpty)
                ? _walletBundle.walletTransactions
                : bundle.walletTransactions,
        rewardPoints: (_walletBundle.rewardPoints.availablePoints > 0 &&
                bundle.rewardPoints.availablePoints == 0)
            ? bundle.rewardPoints.copyWith(
                availablePoints: _walletBundle.rewardPoints.availablePoints,
              )
            : bundle.rewardPoints,
      );
      notifyListeners();
    } catch (e) {
      // Retain previous state on error
    } finally {
      if (isRefresh) {
        _isRefreshing = false;
        notifyListeners();
      } else {
        hideLoading();
      }
    }
  }

  Future<bool> topUp(double amount) async {
    showLoading();
    try {
      final success = await _repository.topUpWallet(amount);
      if (success) {
        await loadWalletData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }

  Future<WalletTopupOrderResponseModel?> createTopupOrder(double amount) async {
    showLoading();
    try {
      return await _repository.createTopupOrder(amount: amount);
    } finally {
      hideLoading();
    }
  }

  Future<bool> setupAutoTopUp({
    required double triggerAmount,
    required double topUpAmount,
    bool enabled = true,
  }) async {
    showLoading();
    try {
      final success = await _repository.setupAutoTopUp(
        triggerAmount: triggerAmount,
        topUpAmount: topUpAmount,
        enabled: enabled,
      );
      if (success) {
        updateAutoTopUpSettings(
          enabled: enabled,
          threshold: triggerAmount,
          amount: topUpAmount,
        );
        await loadWalletData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }

  Future<bool> setupMandate({
    required String bankName,
    required String accountNumber,
    required double maxLimit,
  }) async {
    showLoading();
    try {
      final success = await _repository.setupMandate(
        bankName: bankName,
        accountNumber: accountNumber,
        maxLimit: maxLimit,
      );
      if (success) {
        await loadWalletData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }

  Future<bool> authorizeMandate({
    required String mandateId,
    required String razorpayPaymentId,
  }) async {
    showLoading();
    try {
      final success = await _repository.authorizeMandate(
        mandateId: mandateId,
        razorpayPaymentId: razorpayPaymentId,
      );
      if (success) {
        await loadWalletData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }

  Future<bool> redeemRewards(int points) async {
    showLoading();
    try {
      final success = await _repository.redeemRewards(points);
      if (success) {
        await loadWalletData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }

  Future<bool> verifyPayment({
    int? transactionId,
    String razorpayOrderId = 'order_123',
    String razorpayPaymentId = 'pay_123',
    String razorpaySignature = 'signature_123',
  }) async {
    showLoading();
    try {
      final success = await _repository.verifyPayment(
        transactionId: transactionId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      if (success) {
        await loadWalletData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }
}
