import 'package:flutter/material.dart';
import 'package:floret_app/utils/enums.dart';

class AppConfig {
  static const appName = "Safai 360";
  static const bundleId = "com.floret.safai";
  static const designWidth = 390;
  static const designHeight = 844;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  GlobalKey bottomNavigationKey = GlobalKey();
  static bool isDebugMode = true;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;
}
