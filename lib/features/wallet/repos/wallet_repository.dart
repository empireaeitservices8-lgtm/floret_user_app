import 'package:flutter/foundation.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/services/web_api_services.dart';
import '../model/wallet_model.dart';

class WalletRepository {
  final WebAPIService _webAPIService;
  final ApiService _apiService;

  WalletRepository({
    WebAPIService? webAPIService,
    ApiService? apiService,
  })  : _webAPIService = webAPIService ?? WebAPIService(),
        _apiService = apiService ?? ApiService();

  WebAPIService get webAPIService => _webAPIService;
  ApiService get apiService => _apiService;

  /// 1. GET /api/wallet/balance/
  Future<WalletBalanceDataModel> fetchBalance() async {
    try {
      final response = await _apiService.getWalletBalance();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletBalanceDataModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchBalance error: $e');
    }
    return const WalletBalanceDataModel();
  }

  /// 2. GET /api/wallet/topup/
  Future<WalletTopupConfigModel> fetchTopupConfig() async {
    try {
      final response = await _apiService.getWalletTopup();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletTopupConfigModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchTopupConfig error: $e');
    }
    return const WalletTopupConfigModel();
  }

  /// 3. GET /api/wallet/transactions/
  Future<WalletTransactionsResponseModel> fetchTransactions() async {
    try {
      final response = await _apiService.getWalletTransactions();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletTransactionsResponseModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchTransactions error: $e');
    }
    return const WalletTransactionsResponseModel();
  }

  /// 4. GET /api/reward-points/
  Future<RewardPointsDataModel> fetchRewardPoints() async {
    try {
      final response = await _apiService.getRewardPoints();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return RewardPointsDataModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchRewardPoints error: $e');
    }
    return const RewardPointsDataModel();
  }

  /// 5. GET /api/reward-points/transactions/
  Future<RewardPointsTransactionsResponseModel>
      fetchRewardPointsTransactions() async {
    try {
      final response = await _apiService.getRewardPointsTransactions();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return RewardPointsTransactionsResponseModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchRewardPointsTransactions error: $e');
    }
    return const RewardPointsTransactionsResponseModel();
  }

  /// 6. GET /api/pickups/
  Future<List<PickupItemDataModel>> fetchPickups() async {
    try {
      final response = await _apiService.getPickups();
      if (response.data is List) {
        final list = response.data as List;
        return list
            .map((item) => PickupItemDataModel.fromJson(
                item is Map ? Map<String, dynamic>.from(item) : {}))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchPickups error: $e');
    }
    return const [];
  }

  /// Calls all 6 wallet related endpoints in parallel
  Future<WalletDataBundle> fetchAllWalletData() async {
    final results = await Future.wait([
      fetchBalance(),
      fetchTopupConfig(),
      fetchTransactions(),
      fetchRewardPoints(),
      fetchRewardPointsTransactions(),
      fetchPickups(),
    ]);

    return WalletDataBundle(
      walletBalance: results[0] as WalletBalanceDataModel,
      walletTopupConfig: results[1] as WalletTopupConfigModel,
      walletTransactions: results[2] as WalletTransactionsResponseModel,
      rewardPoints: results[3] as RewardPointsDataModel,
      rewardPointsTransactions:
          results[4] as RewardPointsTransactionsResponseModel,
      pickups: results[5] as List<PickupItemDataModel>,
    );
  }

  Future<bool> topUpWallet(double amount) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> setupAutoTopUp({
    required double triggerAmount,
    required double topUpAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> setupMandate({
    required String bankName,
    required String accountNumber,
    required double maxLimit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> redeemRewards(int points) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
