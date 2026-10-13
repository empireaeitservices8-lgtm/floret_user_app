import 'dart:async';
import 'package:flutter/material.dart';
import '../../home/screen/home_screen.dart';

class PaymentSuccessfulScreen extends StatefulWidget {
  static const String routeName = '/payment_successful';
  final double amount;

  const PaymentSuccessfulScreen({
    super.key,
    this.amount = 500.00,
  });

  @override
  State<PaymentSuccessfulScreen> createState() =>
      _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _startRedirectTimer();
  }

  void _startRedirectTimer() {
    _redirectTimer = Timer(const Duration(seconds: 3), () {
      _goToHome();
    });
  }

  void _goToHome() {
    _redirectTimer?.cancel();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.routeName,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Glowing green circle with checkmark matching Image 3
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242F),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your payment was processed and verified successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 44),

              // Go to Home Button
              SizedBox(
                width: 190,
                height: 50,
                child: ElevatedButton(
                  key: const Key('go_to_home_button'),
                  onPressed: _goToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
