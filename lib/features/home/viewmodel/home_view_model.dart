import 'dart:io';
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

  /// Calculates monthly completed pickups count for the user for the given month.
  int getMonthlyCompletedPickupsCount([List<OrderModel>? ordersList, DateTime? forMonth]) {
    final now = forMonth ?? DateTime.now();
    final list = ordersList ??
        (OrderStore.instance.orders.value.isNotEmpty
            ? OrderStore.instance.orders.value
            : _orderHistory);
    if (list.isNotEmpty) {
      final monthlyList = list.where((o) {
        final date = o.completedDate ?? o.pickupDate;
        return date.year == now.year && date.month == now.month;
      }).toList();

      final completed =
          monthlyList.where((o) => o.status == OrderStatus.completed).toList();
      return completed.length;
    }

    if (_homeBundle.pickups.isNotEmpty) {
      final monthlyPickups = _homeBundle.pickups.where((p) {
        final rawStatus = (p.status ?? '').toLowerCase().trim();
        final isCompleted = rawStatus.contains('complete') ||
            rawStatus.contains('deliver') ||
            rawStatus.contains('collect') ||
            rawStatus.contains('picked') ||
            rawStatus.contains('done') ||
            rawStatus.contains('finish') ||
            rawStatus.contains('paid');
        if (!isCompleted) return false;

        if (p.pickupDate != null && p.pickupDate!.isNotEmpty) {
          final s = p.pickupDate!.trim();
          DateTime? parsed = DateTime.tryParse(s);
          if (parsed == null) {
            final parts = s.split(RegExp(r'[-/]'));
            if (parts.length == 3) {
              final p0 = int.tryParse(parts[0]);
              final p1 = int.tryParse(parts[1]);
              final p2 = int.tryParse(parts[2]);
              if (p0 != null && p1 != null && p2 != null) {
                if (parts[2].length == 4) {
                  parsed = DateTime(p2, p1, p0);
                } else if (parts[0].length == 4) {
                  parsed = DateTime(p0, p1, p2);
                }
              }
            }
          }
          if (parsed != null) {
            return parsed.year == now.year && parsed.month == now.month;
          }
        }
        return false;
      }).toList();
      return monthlyPickups.length;
    }

    return 0;
  }

  /// Calculates monthly CO₂ reduced for the user in kg for the active month (14.3 kg per completed pickup).
  /// Preserves separate records per month.
  double getUserCo2Reduced([List<OrderModel>? ordersList, DateTime? forMonth]) {
    final now = forMonth ?? DateTime.now();
    final list = ordersList ??
        (OrderStore.instance.orders.value.isNotEmpty
            ? OrderStore.instance.orders.value
            : _orderHistory);
    if (list.isNotEmpty) {
      final monthlyList = list.where((o) {
        final date = o.completedDate ?? o.pickupDate;
        return date.year == now.year && date.month == now.month;
      }).toList();

      final completed =
          monthlyList.where((o) => o.status == OrderStatus.completed).toList();
      return completed.length * 14.3;
    }

    if (_homeBundle.pickups.isNotEmpty) {
      final count = getMonthlyCompletedPickupsCount([], now);
      return count * 14.3;
    }

    return 0.0;
  }

  /// Calculates monthly pickup weight for the user in kg for the active month (target 50kg monthly).
  /// Increases by 5 kg per completed pickup.
  /// Automatically resets and updates at the start of every month while preserving records.
  double getUserPickupWeight([List<OrderModel>? ordersList, DateTime? forMonth]) {
    final now = forMonth ?? DateTime.now();
    final list = ordersList ??
        (OrderStore.instance.orders.value.isNotEmpty
            ? OrderStore.instance.orders.value
            : _orderHistory);
    if (list.isNotEmpty) {
      final monthlyList = list.where((o) {
        final date = o.completedDate ?? o.pickupDate;
        return date.year == now.year && date.month == now.month;
      }).toList();

      final completed =
          monthlyList.where((o) => o.status == OrderStatus.completed).toList();
      final valid =
          monthlyList.where((o) => o.status != OrderStatus.cancelled).toList();
      final target = completed.isNotEmpty ? completed : valid;
      return target.length * 5.0;
    }

    if (_homeBundle.pickups.isNotEmpty) {
      final monthlyPickups = _homeBundle.pickups.where((p) {
        if (p.pickupDate != null && p.pickupDate!.isNotEmpty) {
          final s = p.pickupDate!.trim();
          DateTime? parsed = DateTime.tryParse(s);
          if (parsed == null) {
            final parts = s.split(RegExp(r'[-/]'));
            if (parts.length == 3) {
              final p0 = int.tryParse(parts[0]);
              final p1 = int.tryParse(parts[1]);
              final p2 = int.tryParse(parts[2]);
              if (p0 != null && p1 != null && p2 != null) {
                if (parts[2].length == 4) {
                  parsed = DateTime(p2, p1, p0);
                } else if (parts[0].length == 4) {
                  parsed = DateTime(p0, p1, p2);
                }
              }
            }
          }
          if (parsed != null) {
            return parsed.year == now.year && parsed.month == now.month;
          }
        }
        return false;
      }).toList();
      return monthlyPickups.length * 5.0;
    }

    return 0.0;
  }

  /// Fetches order history from backend API, updates local state,
  /// and synchronizes OrderStore so all home metrics react immediately.
  Future<List<OrderModel>> fetchOrderHistory() async {
    _isLoadingOrders = true;
    notifyListeners();
    try {
      await OrderStore.instance.loadForUser();
      final remoteOrders = await _repository.fetchOrderHistory();
      if (remoteOrders.isNotEmpty ||
          !Platform.environment.containsKey('FLUTTER_TEST')) {
        _orderHistory = remoteOrders;
        OrderStore.instance.mergeRemoteOrders(remoteOrders);
      }
      return remoteOrders;
    } catch (e) {
      debugPrint('⚠️ [HOME VIEWMODEL] fetchOrderHistory error: $e');
      return [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Fetches wallet balance directly from GET /api/wallet/balance/
  Future<WalletBalanceDataModel> fetchWalletBalance() async {
    try {
      final balance = await _repository.fetchWalletBalance();
      _homeBundle = _homeBundle.copyWith(walletBalance: balance);
      notifyListeners();
      return balance;
    } catch (e) {
      debugPrint('⚠️ [HOME VIEWMODEL] fetchWalletBalance error: $e');
      return _homeBundle.walletBalance;
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
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        await OrderStore.instance.loadForUser();
      }
      _userName = await _repository.getUserName();
      _pickupOptions = await _repository.getPickupOptions();
      _homeBundle = await _repository.fetchAllHomeData();

      // Fetch wallet balance directly
      try {
        final bal = await _repository.fetchWalletBalance();
        if (bal.id != null || bal.balance > 0) {
          _homeBundle = _homeBundle.copyWith(walletBalance: bal);
        }
      } catch (balErr) {
        debugPrint('⚠️ [HOME VIEWMODEL] walletBalance in loadHomeData error: $balErr');
      }

      // Call order history API in parallel or immediately after home bundle
      try {
        final remoteOrders = await _repository.fetchOrderHistory();
        if (remoteOrders.isNotEmpty ||
            !Platform.environment.containsKey('FLUTTER_TEST')) {
          _orderHistory = remoteOrders;
          OrderStore.instance.mergeRemoteOrders(remoteOrders);
        }
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
