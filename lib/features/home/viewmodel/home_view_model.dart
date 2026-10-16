import 'package:flutter/foundation.dart';
import 'package:floret_app/providers/view_model.dart';
import '../model/home_model.dart';
import '../repos/home_repository.dart';
import '../../profile/model/order_model.dart';
import '../../profile/repos/profile_repository.dart';

class HomeViewModel extends ViewModel {
  final HomeRepository _repository;

  HomeViewModel({
    HomeRepository? repository,
    ProfileRepository? profileRepository,
  })  : _repository = repository ??
            HomeRepository(profileRepository: profileRepository) {
    _initUserName();
    loadHomeData();
  }

  Future<void> _initUserName() async {
    final cached = await _repository.getUserName();
    if (cached.isNotEmpty) {
      _userName = cached;
      notifyListeners();
    }
  }

  void clear() {
    _userName = '';
    _homeBundle = const HomeDataBundle();
    _orderHistory = const [];
    notifyListeners();
  }

  String _userName = '';
  int _selectedNavIndex = 0;
  HomeDataBundle _homeBundle = const HomeDataBundle();
  List<PickupOptionModel> _pickupOptions = const [];
  List<OrderModel> _orderHistory = const [];
  bool _isRefreshing = false;
  bool _isLoadingOrders = false;

  String get userName {
    if (_userName.isNotEmpty &&
        _userName.toLowerCase() != 'user' &&
        _userName.toLowerCase() != 'null') {
      return _userName;
    }
    return '';
  }

  /// Formatted user display name
  String get displayName {
    final name = userName.trim();
    if (name.isEmpty ||
        name.toLowerCase() == 'user' ||
        name.toLowerCase() == 'null' ||
        name.startsWith('+') ||
        RegExp(r'^[0-9]+$').hasMatch(name)) {
      return '';
    }
    // Capitalize first letter of name if alphabetic
    if (name.length > 1) {
      return name[0].toUpperCase() + name.substring(1);
    }
    return name.toUpperCase();
  }

  /// Greeting based on current local time of the day
  String get timeBasedGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning 🌤️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening 🌙';
    } else {
      return 'Good night 🌙';
    }
  }

  /// Dynamic greeting formatting with optional name override
  String getGreeting({String? name}) {
    final hour = DateTime.now().hour;
    String greetText;
    String emoji;
    if (hour >= 5 && hour < 12) {
      greetText = 'Good morning';
      emoji = '🌤️';
    } else if (hour >= 12 && hour < 17) {
      greetText = 'Good afternoon';
      emoji = '🌤️';
    } else if (hour >= 17 && hour < 21) {
      greetText = 'Good evening';
      emoji = '🌙';
    } else {
      greetText = 'Good night';
      emoji = '🌙';
    }

    final rawName = (name != null &&
            name.trim().isNotEmpty &&
            name.trim().toLowerCase() != 'user' &&
            name.trim().toLowerCase() != 'null')
        ? name.trim()
        : displayName;

    final isPhone =
        rawName.startsWith('+') || RegExp(r'^[0-9]+$').hasMatch(rawName);
    final validName = isPhone ? '' : rawName;

    final formattedName = validName.isNotEmpty
        ? (validName.length > 1
            ? validName[0].toUpperCase() + validName.substring(1)
            : validName.toUpperCase())
        : '';

    if (formattedName.isNotEmpty) {
      return '$greetText, $formattedName $emoji';
    }
    return '$greetText $emoji';
  }

  /// Time-based greeting with user name appended
  /// e.g. "Good morning, John 🌅"
  String get greetingWithName => getGreeting();

  /// Welcome back text with username
  String get welcomeBackText => 'Welcome back, $displayName';

  int get selectedNavIndex => _selectedNavIndex;
  HomeDataBundle get homeBundle => _homeBundle;
  HomeOverviewModel get homeOverview => _homeBundle.homeOverview;
  WalletBalanceDataModel get walletBalance => _homeBundle.walletBalance;
  WalletTransactionsResponseModel get walletTransactions =>
      _homeBundle.walletTransactions;
  WalletTopupConfigModel get walletTopupConfig => _homeBundle.walletTopupConfig;
  RewardPointsDataModel get rewardPoints => _homeBundle.rewardPoints;
  RewardPointsTransactionsResponseModel get rewardPointsTransactions =>
      _homeBundle.rewardPointsTransactions;
  List<PickupItemDataModel> get pickups => _homeBundle.pickups;
  List<PickupOptionModel> get pickupOptions => _pickupOptions;
  bool get isRefreshing => _isRefreshing;

  int get pendingBillsCount => _homeBundle.homeOverview.pendingBills;
  int get activePickupsCount => _homeBundle.homeOverview.scheduledPickups > 0
      ? _homeBundle.homeOverview.scheduledPickups
      : _homeBundle.pickups.length;
  int get ecoPoints => _homeBundle.rewardPoints.availablePoints;
  double get walletAmount => _homeBundle.walletBalance.balance;

  List<OrderModel> get orderHistory => _orderHistory;
  bool get isLoadingOrders => _isLoadingOrders;

  /// Fetches order history from backend API, updates local state,
  /// and synchronizes OrderStore so all home metrics react immediately.
  Future<List<OrderModel>> fetchOrderHistory() async {
    _isLoadingOrders = true;
    notifyListeners();
    try {
      await OrderStore.instance.loadForUser();
      final remoteOrders = await _repository.fetchOrderHistory();
      _orderHistory = remoteOrders;
      OrderStore.instance.mergeRemoteOrders(remoteOrders);
      return remoteOrders;
    } catch (e) {
      debugPrint('⚠️ [HOME VIEWMODEL] fetchOrderHistory error: $e');
      return [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> loadHomeData({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      notifyListeners();
    } else {
      showLoading();
    }

    try {
      await OrderStore.instance.loadForUser();
      _userName = await _repository.getUserName();
      _pickupOptions = await _repository.getPickupOptions();
      _homeBundle = await _repository.fetchAllHomeData();

      // Call order history API in parallel or immediately after home bundle
      try {
        final remoteOrders = await _repository.fetchOrderHistory();
        _orderHistory = remoteOrders;
        OrderStore.instance.mergeRemoteOrders(remoteOrders);
      } catch (orderErr) {
        debugPrint('⚠️ [HOME VIEWMODEL] orderHistory in loadHomeData error: $orderErr');
      }
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
