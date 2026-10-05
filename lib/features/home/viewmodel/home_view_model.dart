import 'package:floret_app/providers/view_model.dart';
import '../model/home_model.dart';
import '../repos/home_repository.dart';

class HomeViewModel extends ViewModel {
  final HomeRepository _repository;

  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepository() {
    loadHomeData();
  }

  String _userName = 'nicy nicy';
  int _selectedNavIndex = 0;
  List<PickupOptionModel> _pickupOptions = [];

  String get userName => _userName;
  int get selectedNavIndex => _selectedNavIndex;
  List<PickupOptionModel> get pickupOptions => _pickupOptions;

  Future<void> loadHomeData() async {
    showLoading();
    try {
      _userName = await _repository.getUserName();
      _pickupOptions = await _repository.getPickupOptions();
    } finally {
      hideLoading();
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
      return await _repository.bookPickup(booking);
    } finally {
      hideLoading();
    }
  }
}
