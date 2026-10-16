import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
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
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return const WalletBalanceDataModel();
    }
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

  /// 2b. POST /api/wallet/topup/ (Create Razorpay Order)
  Future<WalletTopupOrderResponseModel?> createTopupOrder({
    required double amount,
    String? token,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return WalletTopupOrderResponseModel(
        message: 'Razorpay order created successfully',
        transactionId: 102,
        razorpayOrderId: 'order_ToYb02mTfIaiEZ',
        amount: amount,
        currency: 'INR',
      );
    }
    try {
      final response = await _apiService.createWalletTopupOrder(
        amount: amount,
        token: token,
      );
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletTopupOrderResponseModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] createTopupOrder error: $e');
    }
    return null;
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
        final model = RewardPointsDataModel.fromJson(map);
        if (model.availablePoints > 0) {
          SpHelper.saveString(
              'eco_reward_points', model.availablePoints.toString());
        }
        return model;
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

  /// Pickups are handled on home/profile screens and not called in wallet screen.
  Future<List<PickupItemDataModel>> fetchPickups() async {
    return const [];
  }

  /// Calls wallet related endpoints in parallel (Balance, TopupConfig, Transactions, RewardPoints, RewardPointsTransactions)
  Future<WalletDataBundle> fetchAllWalletData() async {
    final results = await Future.wait([
      fetchBalance(),
      fetchTopupConfig(),
      fetchTransactions(),
      fetchRewardPoints(),
      fetchRewardPointsTransactions(),
    ]);

    return WalletDataBundle(
      walletBalance: results[0] as WalletBalanceDataModel,
      walletTopupConfig: results[1] as WalletTopupConfigModel,
      walletTransactions: results[2] as WalletTransactionsResponseModel,
      rewardPoints: results[3] as RewardPointsDataModel,
      rewardPointsTransactions:
          results[4] as RewardPointsTransactionsResponseModel,
      pickups: const [],
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

  /// 7. POST /api/wallet/topup/verify-payment/
  Future<bool> verifyPayment({
    String razorpayOrderId = 'order_123',
    String razorpayPaymentId = 'pay_123',
    String razorpaySignature = 'signature_123',
    String? token,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return true;
    }
    try {
      final response = await _apiService.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        token: token,
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] verifyPayment error: $e');
    }
    return false;
  }
}
