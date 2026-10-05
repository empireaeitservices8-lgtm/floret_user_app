class SplashConfigModel {
  final bool isAuthenticated;
  final String appVersion;
  final int animationDurationMs;

  const SplashConfigModel({
    required this.isAuthenticated,
    required this.appVersion,
    this.animationDurationMs = 2400,
  });
}
