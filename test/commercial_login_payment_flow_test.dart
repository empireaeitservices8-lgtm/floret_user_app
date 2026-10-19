import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/auth/screen/otp_screen.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/features/wallet/screen/payment_successful_screen.dart';
import 'package:floret_app/features/wallet/screen/razorpay_checkout_screen.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/models/send_otp_model.dart';
import 'package:floret_app/models/verify_otp_model.dart';
import 'package:floret_app/repositories/auth_repository.dart';
import 'package:floret_app/utils/routes.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:floret_app/viewmodels/otp_viewmodel.dart';

class MockSuccessAuthRepository extends AuthRepository {
  final String accountType;

  MockSuccessAuthRepository({this.accountType = 'Commercial'});

  @override
  Future<SendOtpModel> sendOtp(String phoneNumber) async {
    return const SendOtpModel(
      message: 'OTP sent successfully',
      otp: '1234',
    );
  }

  @override
  Future<VerifyOtpModel> verifyOtp(String phoneNumber, String otp) async {
    await SpHelper.saveString(sp_keys.keyToken, 'test_jwt_token');
    await SpHelper.saveString('account_type', accountType);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sp_keys.keyToken, 'test_jwt_token');
    await prefs.setString('account_type', accountType);

    return const VerifyOtpModel(
      message: 'OTP verified successfully',
      phoneNumber: '+919995723146',
      isRegistered: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
  });

  testWidgets(
      'Commercial user after login navigates to Razorpay, and after payment success goes to Home page',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockSuccessAuthRepository(accountType: 'Commercial');
    final otpViewModel = OtpViewModel(authRepository: mockRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OtpViewModel>.value(value: otpViewModel),
        ],
        child: MaterialApp(
          routes: appRoutes(),
          home: OtpScreen(
            mobileNumber: '9995723146',
            viewModel: otpViewModel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Enter OTP '1234'
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pumpAndSettle();

    // 2. Tap Verify & Login
    expect(find.text('Verify & Login'), findsOneWidget);
    await tester.tap(find.text('Verify & Login'));
    await tester.pumpAndSettle();

    // 3. User is commercial -> navigates to RazorpayCheckoutScreen (NOT HomeScreen yet)
    expect(find.byType(RazorpayCheckoutScreen), findsOneWidget);
    expect(find.text('Commercial Registration Fee'), findsOneWidget);
    expect(find.text('₹1000.00'), findsWidgets);
    expect(find.byType(HomeScreen), findsNothing);

    // 4. Tap PAY VIA RAZORPAY
    await tester.tap(find.byKey(const Key('pay_via_razorpay_button')));
    await tester.pumpAndSettle();

    // 5. 3D Secure Authentication modal appears
    expect(find.text('3D Secure Authentication'), findsOneWidget);

    // 6. Tap Authorize Payment
    await tester.tap(find.text('Authorize Payment'));
    // Wait for simulated authorization delay
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 7. Should land on PaymentSuccessfulScreen
    expect(find.byType(PaymentSuccessfulScreen), findsOneWidget);
    expect(find.text('Payment Successful!'), findsOneWidget);

    // 8. Tap 'Go to Home' button
    await tester.tap(find.byKey(const Key('go_to_home_button')));
    await tester.pumpAndSettle();

    // 9. Should now land on HomeScreen!
    expect(find.byType(HomeScreen), findsOneWidget);

    // 10. Verify commercial_fee_paid is now true
    final isPaid = await SpHelper.getBoolean('commercial_fee_paid');
    expect(isPaid, isTrue);
  });

  testWidgets(
      'Residential / non-commercial user after login navigates directly to Home screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockSuccessAuthRepository(accountType: 'Residential');
    final otpViewModel = OtpViewModel(authRepository: mockRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OtpViewModel>.value(value: otpViewModel),
        ],
        child: MaterialApp(
          routes: appRoutes(),
          home: OtpScreen(
            mobileNumber: '9995723146',
            viewModel: otpViewModel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Enter OTP '1234'
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pumpAndSettle();

    // 2. Tap Verify & Login
    await tester.tap(find.text('Verify & Login'));
    await tester.pumpAndSettle();

    // 3. User is residential -> goes directly to HomeScreen, bypassing Razorpay
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(RazorpayCheckoutScreen), findsNothing);
  });
}
