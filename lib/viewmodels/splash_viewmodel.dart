import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

enum AuthGateStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SplashViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  AuthGateStatus _status = AuthGateStatus.initial;
  bool _isLoading = false;

  AuthGateStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthGateStatus.authenticated;

  /// Performs the Auth Gate check during splash display.
  /// Ensures the splash screen remains visible for at least [minDisplayDuration]
  /// to allow the loading animation to complete smoothly.
  Future<AuthGateStatus> checkAuthStatus({
    Duration minDisplayDuration = const Duration(milliseconds: 2400),
  }) async {
    _status = AuthGateStatus.loading;
    _isLoading = true;
    notifyListeners();

    debugPrint('🚀 [SPLASH VIEWMODEL] Checking authentication status...');

    final stopwatch = Stopwatch()..start();
    bool isUserAuthenticated = false;

    try {
      isUserAuthenticated = await _authRepository.checkAuthStatus();
    } catch (e) {
      debugPrint('❌ [SPLASH VIEWMODEL] Error verifying authentication: $e');
      isUserAuthenticated = false;
    }

    // Wait for the remaining animation duration
    final elapsed = stopwatch.elapsed;
    if (elapsed < minDisplayDuration) {
      final remaining = minDisplayDuration - elapsed;
      await Future.delayed(remaining);
    }

    _status = isUserAuthenticated
        ? AuthGateStatus.authenticated
        : AuthGateStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();

    debugPrint('🏁 [SPLASH VIEWMODEL] Auth check completed. Status: $_status');
    return _status;
  }
}
