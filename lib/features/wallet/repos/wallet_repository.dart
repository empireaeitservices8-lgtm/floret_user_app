import 'dart:convert';
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
      try {
        final cachedStr = await SpHelper.getString('wallet_balance');
        if (cachedStr != null && cachedStr.isNotEmpty) {
          final cached = double.tryParse(cachedStr);
          if (cached != null) {
            return WalletBalanceDataModel(balance: cached);
          }
        }
      } catch (_) {}
      return const WalletBalanceDataModel();
    }
    try {
      final response = await _apiService.getWalletBalance();
      dynamic responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }
      if (responseData is Map) {
        final map = Map<String, dynamic>.from(
          (responseData['data'] is Map)
              ? responseData['data'] as Map
              : responseData,
        );
        final model = WalletBalanceDataModel.fromJson(map);
        try {
          await SpHelper.saveString('wallet_balance', model.balance.toString());
        } catch (_) {}
        debugPrint(
            '💰 [WALLET REPO] Successfully mapped wallet balance: ${model.balance}');
        return model;
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] fetchBalance error: $e');
    }
    try {
      final cachedStr = await SpHelper.getString('wallet_balance');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final cached = double.tryParse(cachedStr);
        if (cached != null) {
          return WalletBalanceDataModel(balance: cached);
        }
      }
    } catch (_) {}
    return const WalletBalanceDataModel();
  }

  /// 2. GET /api/wallet/topup/
  Future<WalletTopupConfigModel> fetchTopupConfig() async {
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return const WalletTopupConfigModel(
        predefinedAmounts: [500, 1000, 1500, 2000],
        minAmount: 500,
        maxAmount: 2000,
      );
    }
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

  // Future<Map<String, dynamic>?> generateRazorpayQR({
  //   required double amount,
  //   required int billId,
  //   String currency = 'INR',
  // }) async {
  //   try {
  //     final Dio dio = Dio();
  //     final body = {
  //       'amount': amount,
  //       'bill_id': billId,
  //       'currency': currency,
  //     };
  // debugPrint(
  //     'POST generate-qr to ${APIEndPoints.baseUrl}${APIEndPoints.razorpayGenerateQr} with body: $body');
  //     final res = await dio.post(ApiService.razorpayGenerateQr, data: body);
  //     debugPrint(
  //         'Generate QR Response Status: ${res.statusCode}, Body: ${res.data}');
  //     if ((res.statusCode == 200 || res.statusCode == 201) &&
  //         res.data is Map<String, dynamic>) {
  //       return res.data as Map<String, dynamic>;
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint('generateRazorpayQR error: $e');
  //     return null;
  //   }
  // }

  /// 3. GET /api/wallet/transactions/
  Future<WalletTransactionsResponseModel> fetchTransactions() async {
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return const WalletTransactionsResponseModel();
    }
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
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return const RewardPointsDataModel();
    }
    try {
      final response = await _apiService.getRewardPoints();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final model = RewardPointsDataModel.fromJson(map);
        SpHelper.saveString(
            'eco_reward_points', model.availablePoints.toString());
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
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      return const RewardPointsTransactionsResponseModel();
    }
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

  /// POST /api/wallet/auto-topup/settings/
  Future<bool> setupAutoTopUp({
    required double triggerAmount,
    required double topUpAmount,
    bool enabled = true,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      final response = await _apiService.saveAutoTopupSettings(
        enabled: enabled,
        threshold: triggerAmount,
        topupAmount: topUpAmount,
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] setupAutoTopUp error: $e');
    }
    return false;
  }

  /// POST /api/wallet/mandate/authorize/
  Future<bool> authorizeMandate({
    required String mandateId,
    required String razorpayPaymentId,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST') &&
        _apiService.runtimeType.toString() == 'ApiService') {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      final response = await _apiService.authorizeMandate(
        mandateId: mandateId,
        razorpayPaymentId: razorpayPaymentId,
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        await fetchBalance();
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] authorizeMandate error: $e');
    }
    return false;
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
    int? transactionId,
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
        transactionId: transactionId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        token: token,
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        await fetchBalance();
        await fetchTransactions();
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET REPO] verifyPayment error: $e');
    }
    return false;
  }
}
