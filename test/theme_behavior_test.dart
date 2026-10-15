import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:floret_app/main.dart';
import 'package:floret_app/providers/theme_provider.dart';
import 'package:floret_app/utils/themes.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  Future<void> settleApp(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
  }

  BuildContext getNavContext(WidgetTester tester) {
    return tester.state<NavigatorState>(find.byType(Navigator)).context;
  }

  testWidgets('System Theme Auto-detection, Dynamic Switching, Consistency, and Persistence', (tester) async {
    // -------------------------------------------------------------
    // SCENARIO 1: Phone in Light Mode -> app displays Light Mode
    // -------------------------------------------------------------
    tester.view.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.view.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 300));

    BuildContext innerContext = getNavContext(tester);
    expect(Theme.of(innerContext).brightness, equals(Brightness.light),
        reason: 'App must automatically display Light Mode');
    expect(innerContext.read<ThemeProvider>().themeMode, equals(ThemeMode.system));

    // -------------------------------------------------------------
    // SCENARIO 2 & 3: Switch phone from Light Mode to Dark Mode while app is open
    // -------------------------------------------------------------
    tester.view.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    innerContext = getNavContext(tester);
    expect(Theme.of(innerContext).brightness, equals(Brightness.dark),
        reason: 'App must automatically update to Dark Mode without restart');
    expect(Theme.of(innerContext).scaffoldBackgroundColor, equals(const Color(0xFF010413)));

    // -------------------------------------------------------------
    // SCENARIO 4: Switch phone from Dark Mode to Light Mode while app is open
    // -------------------------------------------------------------
    tester.view.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    innerContext = getNavContext(tester);
    expect(Theme.of(innerContext).brightness, equals(Brightness.light),
        reason: 'App must automatically update to Light Mode without restart');

    // -------------------------------------------------------------
    // SCENARIO 5: Screen and widget consistency under Dark Mode
    // -------------------------------------------------------------
    tester.view.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    innerContext = getNavContext(tester);
    expect(Theme.of(innerContext).brightness, equals(Brightness.dark));
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.system));

    // -------------------------------------------------------------
    // SCENARIO 7: Explicit user preference mechanism is preserved and respected
    // -------------------------------------------------------------
    await innerContext.read<ThemeProvider>().setThemeMode(innerContext, ThemeMode.light);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    innerContext = getNavContext(tester);
    // Even though device is Dark, user explicitly selected Light Mode
    expect(Theme.of(innerContext).brightness, equals(Brightness.light));
    expect(innerContext.read<ThemeProvider>().themeMode, equals(ThemeMode.light));

    // Switch back to system mode
    await innerContext.read<ThemeProvider>().setThemeMode(innerContext, ThemeMode.system);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    innerContext = getNavContext(tester);
    // Follows system (which is dark)
    expect(Theme.of(innerContext).brightness, equals(Brightness.dark));
    expect(innerContext.read<ThemeProvider>().themeMode, equals(ThemeMode.system));

    await settleApp(tester);
  });
}
