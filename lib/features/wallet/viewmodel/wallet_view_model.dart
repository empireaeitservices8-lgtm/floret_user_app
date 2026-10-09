import 'package:floret_app/providers/view_model.dart';
import '../model/wallet_model.dart';
import '../repos/wallet_repository.dart';

class WalletViewModel extends ViewModel {
  final WalletRepository _repository;

  WalletViewModel({WalletRepository? repository})
      : _repository = repository ?? WalletRepository() {
    loadWalletData();
  }

  int _selectedActivityTab = 0; // 0: Wallet Activity, 1: Eco Rewards
  WalletDataBundle _walletBundle = const WalletDataBundle();
  bool _isRefreshing = false;

  int get selectedActivityTab => _selectedActivityTab;
  WalletDataBundle get walletBundle => _walletBundle;
  bool get isRefreshing => _isRefreshing;

  // Wallet Balance getters
  WalletBalanceDataModel get balanceModel => _walletBundle.walletBalance;
  double get walletBalance => _walletBundle.walletBalance.balance;
  bool get autoTopupEnabled => _walletBundle.walletBalance.autoTopupEnabled;
  double get autoTopupTriggerAmount =>
      _walletBundle.walletBalance.autoTopupTriggerAmount ?? 100.0;
  double get autoTopupAmount =>
      _walletBundle.walletBalance.autoTopupAmount ?? 500.0;
  bool get mandateAuthorized =>
      _walletBundle.walletBalance.mandateAuthorized;
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
  RewardPointsConfigModel? get rewardConfig => _walletBundle.rewardPoints.config;
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

  Future<void> loadWalletData({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      notifyListeners();
    } else {
      showLoading();
    }

    try {
      _walletBundle = await _repository.fetchAllWalletData();
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

  Future<bool> setupAutoTopUp({
    required double triggerAmount,
    required double topUpAmount,
  }) async {
    showLoading();
    try {
      final success = await _repository.setupAutoTopUp(
        triggerAmount: triggerAmount,
        topUpAmount: topUpAmount,
      );
      if (success) {
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
}
