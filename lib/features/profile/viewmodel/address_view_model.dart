import 'package:floret_app/providers/view_model.dart';
import '../model/address_model.dart';
import '../repos/profile_repository.dart';

class AddressViewModel extends ViewModel {
  final ProfileRepository _repository;

  AddressViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  final List<AddressModel> _addresses = [];

  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  bool get hasAddresses => _addresses.isNotEmpty;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  void addAddress({
    required String type,
    required String addressLine,
    required String area,
    required String city,
    required String pincode,
    bool isDefault = false,
  }) {
    final bool makeDefault = isDefault || _addresses.isEmpty;

    if (makeDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }

    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      addressLine: addressLine,
      area: area,
      city: city,
      pincode: pincode,
      isDefault: makeDefault,
    );

    _addresses.add(newAddress);
    _repository.saveAddress(newAddress);
    notifyListeners();
  }

  void deleteAddress(String id) {
    final int index = _addresses.indexWhere((a) => a.id == id);
    if (index != -1) {
      final bool wasDefault = _addresses[index].isDefault;
      _addresses.removeAt(index);
      if (wasDefault && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
      _repository.deleteAddress(id);
      notifyListeners();
    }
  }

  void setDefaultAddress(String id) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == id,
      );
    }
    notifyListeners();
  }
}
