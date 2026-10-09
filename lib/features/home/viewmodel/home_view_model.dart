import 'package:floret_app/providers/view_model.dart';
import '../model/home_model.dart';
import '../repos/home_repository.dart';

class HomeViewModel extends ViewModel {
  final HomeRepository _repository;

  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepository() {
    loadHomeData();
  }

  String _userName = 'user';
  int _selectedNavIndex = 0;
  HomeDataBundle _homeBundle = const HomeDataBundle();
  List<PickupOptionModel> _pickupOptions = const [];
  bool _isRefreshing = false;

  String get userName {
    if (_userName.isNotEmpty && _userName.toLowerCase() != 'user') {
      return _userName;
    }
    if (_homeBundle.homeOverview.username != null &&
        _homeBundle.homeOverview.username!.isNotEmpty &&
        _homeBundle.homeOverview.username!.toLowerCase() != 'user') {
      return _homeBundle.homeOverview.username!;
    }
    return _userName;
  }

  /// Formatted user display name
  String get displayName {
    final name = userName.trim();
    if (name.isEmpty || name.toLowerCase() == 'user') {
      return '';
    }
    // Capitalize first letter of name if alphabetic
    if (name.length > 1 && !name.startsWith('+') && !RegExp(r'^[0-9]+$').hasMatch(name)) {
      return name[0].toUpperCase() + name.substring(1);
    }
    return name;
  }

  /// Greeting based on current local time of the day
  String get timeBasedGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning 🌅';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening 🌆';
    } else {
      return 'Good night 🌙';
    }
  }

  /// Welcome back text with username
  String get welcomeBackText => 'Welcome back, $displayName';

  int get selectedNavIndex => _selectedNavIndex;
  HomeDataBundle get homeBundle => _homeBundle;
  HomeOverviewModel get homeOverview => _homeBundle.homeOverview;
  WalletBalanceDataModel get walletBalance => _homeBundle.walletBalance;
  WalletTransactionsResponseModel get walletTransactions =>
      _homeBundle.walletTransactions;
  WalletTopupConfigModel get walletTopupConfig =>
      _homeBundle.walletTopupConfig;
  RewardPointsDataModel get rewardPoints => _homeBundle.rewardPoints;
  RewardPointsTransactionsResponseModel get rewardPointsTransactions =>
      _homeBundle.rewardPointsTransactions;
  List<PickupItemDataModel> get pickups => _homeBundle.pickups;
  List<PickupOptionModel> get pickupOptions => _pickupOptions;
  bool get isRefreshing => _isRefreshing;

  int get pendingBillsCount => _homeBundle.homeOverview.pendingBills;
  int get activePickupsCount =>
      _homeBundle.homeOverview.scheduledPickups > 0
          ? _homeBundle.homeOverview.scheduledPickups
          : _homeBundle.pickups.length;
  int get ecoPoints => _homeBundle.rewardPoints.availablePoints;
  double get walletAmount => _homeBundle.walletBalance.balance;

  Future<void> loadHomeData({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      notifyListeners();
    } else {
      showLoading();
    }

    try {
      _userName = await _repository.getUserName();
      _pickupOptions = await _repository.getPickupOptions();
      _homeBundle = await _repository.fetchAllHomeData();
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

  void setSelectedNavIndex(int index) {
    if (_selectedNavIndex != index) {
      _selectedNavIndex = index;
      notifyListeners();
    }
  }

  Future<bool> bookPickup(PickupBookingModel booking) async {
    showLoading();
    try {
      final success = await _repository.bookPickup(booking);
      if (success) {
        await loadHomeData(isRefresh: true);
      }
      return success;
    } finally {
      hideLoading();
    }
  }
}
