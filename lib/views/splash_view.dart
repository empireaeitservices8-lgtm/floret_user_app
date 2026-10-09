import 'package:flutter/material.dart';
import '../features/splashscreen/screen/splashscreen.dart';

/// SplashView alias mapping to SplashScreen for MVVM views directory standard
class SplashView extends StatelessWidget {
  static const String routeName = SplashScreen.routeName;

  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
