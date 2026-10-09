import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SplashViewModel();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final status = await _viewModel.checkAuthStatus(
      minDisplayDuration: const Duration(milliseconds: 2500),
    );
    if (!mounted) return;

    if (status == AuthGateStatus.authenticated) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Floret Technologies Logo
              Image.asset(
                'assets/images/floret_logo.png',
                width: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC8A86B),
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.stream,
                          color: Color(0xFF4A4E5A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Floret Technologies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB8934A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 44),

              // Animated slim loading progress bar
              SizedBox(
                width: 80,
                height: 3.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: const Color(0xFFF3EDE7),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF262A36),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
