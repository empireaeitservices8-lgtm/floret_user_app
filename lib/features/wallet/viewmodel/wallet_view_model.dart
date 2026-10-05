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
  WalletBalanceModel _balance = const WalletBalanceModel();
  List<WalletTransactionModel> _transactions = [];

  int get selectedActivityTab => _selectedActivityTab;
  WalletBalanceModel get balance => _balance;
  List<WalletTransactionModel> get transactions => _transactions;

  void setActivityTab(int index) {
    if (_selectedActivityTab != index) {
      _selectedActivityTab = index;
      notifyListeners();
    }
  }

  Future<void> loadWalletData() async {
    showLoading();
    try {
      _balance = await _repository.fetchBalance();
      _transactions = await _repository.fetchTransactions();
      notifyListeners();
    } finally {
      hideLoading();
    }
  }

  Future<bool> topUp(double amount) async {
    showLoading();
    try {
      final success = await _repository.topUpWallet(amount);
      if (success) {
        await loadWalletData();
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
      return await _repository.setupAutoTopUp(
        triggerAmount: triggerAmount,
        topUpAmount: topUpAmount,
      );
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
      return await _repository.setupMandate(
        bankName: bankName,
        accountNumber: accountNumber,
        maxLimit: maxLimit,
      );
    } finally {
      hideLoading();
    }
  }

  Future<bool> redeemRewards(int points) async {
    showLoading();
    try {
      final success = await _repository.redeemRewards(points);
      if (success) {
        await loadWalletData();
      }
      return success;
    } finally {
      hideLoading();
    }
  }
}
