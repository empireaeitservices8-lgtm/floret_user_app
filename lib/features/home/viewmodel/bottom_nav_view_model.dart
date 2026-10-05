import 'package:floret_app/providers/view_model.dart';

class BottomNavViewModel extends ViewModel {
  int _currentIndex = 0;

  BottomNavViewModel({int initialIndex = 0}) : _currentIndex = initialIndex;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
