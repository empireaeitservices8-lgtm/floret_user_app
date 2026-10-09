import 'package:floret_app/providers/view_model.dart';
import '../model/profile_model.dart';
import '../repos/profile_repository.dart';

class ProfileViewModel extends ViewModel {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository() {
    loadProfile();
  }

  UserProfileModel _profile = const UserProfileModel(
    name: '',
    mobileNumber: '',
    email: '',
    location: 'Kerala, India',
  );

  UserProfileModel get profile => _profile;

  Future<void> loadProfile() async {
    showLoading();
    try {
      _profile = await _repository.getUserProfile();
      notifyListeners();
    } finally {
      hideLoading();
    }
  }
}

class OrderHistoryViewModel extends ViewModel {
  final ProfileRepository _repository;

  OrderHistoryViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository() {
    loadOrders();
  }

  int _selectedFilterIndex = 0;
  final List<String> filters = const [
    'All',
    'Completed',
    'Pending',
    'Reschedule',
  ];
  List<OrderHistoryItemModel> _orders = [];

  int get selectedFilterIndex => _selectedFilterIndex;
  List<OrderHistoryItemModel> get orders => _orders;

  List<OrderHistoryItemModel> get filteredOrders {
    if (_selectedFilterIndex == 0) return _orders;
    final f = filters[_selectedFilterIndex];
    return _orders.where((o) => o.status == f).toList();
  }

  void setFilterIndex(int index) {
    if (_selectedFilterIndex != index) {
      _selectedFilterIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    showLoading();
    try {
      _orders = await _repository.fetchOrderHistory();
    } finally {
      hideLoading();
    }
  }
}
