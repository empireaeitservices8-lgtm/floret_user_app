import 'package:flutter/foundation.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import '../model/home_model.dart';

class HomeRepository {
  final WebAPIService _webAPIService;
  final ApiService _apiService;

  HomeRepository({
    WebAPIService? webAPIService,
    ApiService? apiService,
  })  : _webAPIService = webAPIService ?? WebAPIService(),
        _apiService = apiService ?? ApiService();

  WebAPIService get webAPIService => _webAPIService;
  ApiService get apiService => _apiService;

  /// Retrieves the cached or local user name
  Future<String> getUserName() async {
    final firstName = await SpHelper.getString('first_name');
    if (firstName != null && firstName.trim().isNotEmpty && firstName.trim().toLowerCase() != 'user') {
      return firstName.trim();
    }
    final name = await SpHelper.getString(sp_keys.keyUserName);
    if (name != null && name.trim().isNotEmpty && name.trim().toLowerCase() != 'user') {
      return name.trim();
    }
    final rawUname = await SpHelper.getString('username');
    if (rawUname != null && rawUname.trim().isNotEmpty && rawUname.trim().toLowerCase() != 'user') {
      return rawUname.trim();
    }
    final raw = await SpHelper.getString('user_name');
    if (raw != null && raw.trim().isNotEmpty && raw.trim().toLowerCase() != 'user') {
      return raw.trim();
    }
    final homeUname = await SpHelper.getString('home_username');
    if (homeUname != null && homeUname.trim().isNotEmpty && homeUname.trim().toLowerCase() != 'user') {
      return homeUname.trim();
    }
    return '';
  }

  /// 1. GET /api/home/
  Future<HomeOverviewModel> fetchHomeOverview() async {
    try {
      final response = await _apiService.getHome();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final model = HomeOverviewModel.fromJson(map);
        // Also save username/message if present and not generic
        if (model.username != null &&
            model.username!.isNotEmpty &&
            model.username!.toLowerCase() != 'user') {
          await SpHelper.saveString('home_username', model.username!);
        }
        return model;
      }
    } catch (e) {
      debugPrint('⚠️ [HOME REPO] fetchHomeOverview error: $e');
    }
    return const HomeOverviewModel();
  }

  /// 2. GET /api/wallet/balance/
  Future<WalletBalanceDataModel> fetchWalletBalance() async {
    try {
      final response = await _apiService.getWalletBalance();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletBalanceDataModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [HOME REPO] fetchWalletBalance error: $e');
    }
    return const WalletBalanceDataModel();
  }

  /// 3. GET /api/wallet/transactions/
  Future<WalletTransactionsResponseModel> fetchWalletTransactions() async {
    try {
      final response = await _apiService.getWalletTransactions();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletTransactionsResponseModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [HOME REPO] fetchWalletTransactions error: $e');
    }
    return const WalletTransactionsResponseModel();
  }

  /// 4. GET /api/wallet/topup/
  Future<WalletTopupConfigModel> fetchWalletTopupConfig() async {
    try {
      final response = await _apiService.getWalletTopup();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return WalletTopupConfigModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [HOME REPO] fetchWalletTopupConfig error: $e');
    }
    return const WalletTopupConfigModel();
  }

  /// 5. GET /api/reward-points/
  Future<RewardPointsDataModel> fetchRewardPoints() async {
    try {
      final response = await _apiService.getRewardPoints();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return RewardPointsDataModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [HOME REPO] fetchRewardPoints error: $e');
    }
    return const RewardPointsDataModel();
  }

  /// 6. GET /api/reward-points/transactions/
  Future<RewardPointsTransactionsResponseModel>
      fetchRewardPointsTransactions() async {
    try {
      final response = await _apiService.getRewardPointsTransactions();
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return RewardPointsTransactionsResponseModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('⚠️ [HOME REPO] fetchRewardPointsTransactions error: $e');
    }
    return const RewardPointsTransactionsResponseModel();
  }

  /// 7. GET /api/pickups/
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
      debugPrint('⚠️ [HOME REPO] fetchPickups error: $e');
    }
    return const [];
  }

  /// Calls all 7 Home APIs in parallel
  Future<HomeDataBundle> fetchAllHomeData() async {
    final results = await Future.wait([
      fetchHomeOverview(),
      fetchWalletBalance(),
      fetchWalletTransactions(),
      fetchWalletTopupConfig(),
      fetchRewardPoints(),
      fetchRewardPointsTransactions(),
      fetchPickups(),
    ]);

    return HomeDataBundle(
      homeOverview: results[0] as HomeOverviewModel,
      walletBalance: results[1] as WalletBalanceDataModel,
      walletTransactions: results[2] as WalletTransactionsResponseModel,
      walletTopupConfig: results[3] as WalletTopupConfigModel,
      rewardPoints: results[4] as RewardPointsDataModel,
      rewardPointsTransactions:
          results[5] as RewardPointsTransactionsResponseModel,
      pickups: results[6] as List<PickupItemDataModel>,
    );
  }

  Future<List<PickupOptionModel>> getPickupOptions() async {
    return const [
      PickupOptionModel(
        id: 'doorstep',
        title: 'Daily Doorstep Collection',
        subtitle: 'Scheduled recurring waste collection at your doorstep',
        iconName: 'doorbell',
        estimatedWeight: '1 - 5 kg',
      ),
      PickupOptionModel(
        id: 'bulk',
        title: 'Bulk Waste Pickup',
        subtitle: 'Large quantity commercial or residential waste pickup',
        iconName: 'truck',
        estimatedWeight: '10+ kg',
      ),
      PickupOptionModel(
        id: 'recyclables',
        title: 'Recyclables Segregated',
        subtitle: 'Sorted dry plastics, papers, cans, and electronic scrap',
        iconName: 'recycling',
        estimatedWeight: '2 - 8 kg',
      ),
    ];
  }

  Future<bool> bookPickup(PickupBookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
