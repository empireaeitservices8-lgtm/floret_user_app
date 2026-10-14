import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/models/verify_otp_model.dart';
import 'package:floret_app/repositories/auth_repository.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/features/splashscreen/screen/splashscreen.dart';
import 'package:floret_app/features/auth/screen/login_screen.dart';
import 'package:floret_app/features/home/screen/home_screen.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:dio/dio.dart';

class MockApiService extends ApiService {
  final bool isRegistered;
  final bool shouldFail;

  MockApiService({this.isRegistered = true, this.shouldFail = false});

  @override
  Future<Response> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    if (shouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/otp/verify/'),
        error: 'Invalid OTP',
      );
    }
    return Response(
      requestOptions: RequestOptions(path: '/api/otp/verify/'),
      statusCode: 200,
      data: {
        'message': 'OTP verified successfully.',
        'phone_number': phoneNumber,
        'is_registered': isRegistered,
      },
    );
  }

  @override
  Future<Response> login({
    required String phoneNumber,
    required String otp,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: '/api/login/'),
      statusCode: 200,
      data: {
        'user_id': '101',
        'username': 'TestUser',
        'phone_number': phoneNumber,
        'account_type': 'Individual',
        'mou_status': 'Approved',
        'mou_document_uploaded': false,
        'can_access_app': true,
        'token': 'test_token_123',
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
  });

  group('VerifyOtpModel Deserialization Tests', () {
    test('Correctly deserializes is_registered as boolean', () {
      final modelTrue = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': true,
      });
      expect(modelTrue.isRegistered, isTrue);

      final modelFalse = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': false,
      });
      expect(modelFalse.isRegistered, isFalse);
    });

    test('Correctly deserializes is_registered from integer (1/0)', () {
      final model1 = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': 1,
      });
      expect(model1.isRegistered, isTrue);

      final model0 = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': 0,
      });
      expect(model0.isRegistered, isFalse);
    });

    test('Correctly deserializes is_registered from string ("true"/"false"/"1")', () {
      final modelStringTrue = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': 'true',
      });
      expect(modelStringTrue.isRegistered, isTrue);

      final modelString1 = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': '1',
      });
      expect(modelString1.isRegistered, isTrue);

      final modelStringFalse = VerifyOtpModel.fromJson({
        'message': 'Success',
        'phone_number': '+919876543210',
        'is_registered': 'false',
      });
      expect(modelStringFalse.isRegistered, isFalse);
    });
  });

  group('AuthRepository Login & Verify Flow Tests', () {
    test('Successful verifyOtp with registered user logs in and stores credentials', () async {
      final mockApi = MockApiService(isRegistered: true);
      final repo = AuthRepository(apiService: mockApi);

      final result = await repo.verifyOtp('+919876543210', '123456');

      expect(result.isRegistered, isTrue);
      final savedToken = await repo.getSavedToken();
      expect(savedToken, 'test_token_123');

      final isAuth = await repo.checkAuthStatus();
      expect(isAuth, isTrue);
    });

    test('Failed verifyOtp with unregistered phone throws error instead of misdirecting to register', () async {
      final mockApi = MockApiService(isRegistered: false);
      final repo = AuthRepository(apiService: mockApi);

      expect(
        () async => await repo.verifyOtp('+919876543210', '123456'),
        throwsA(isA<Exception>()),
      );

      final savedToken = await repo.getSavedToken();
      expect(savedToken, isNull);
    });
  });

  group('Splash Screen Auth Gate Tests', () {
    testWidgets('Authenticated user navigates to HomeScreen and NOT RegisterScreen', (tester) async {
      SharedPreferences.setMockInitialValues({
        'token': 'existing_valid_token',
      });

      String? navigatedRoute;

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (context) => const SplashScreen(),
            HomeScreen.routeName: (context) {
              navigatedRoute = HomeScreen.routeName;
              return const Scaffold(body: Text('Home Screen'));
            },
            LoginScreen.routeName: (context) {
              navigatedRoute = LoginScreen.routeName;
              return const Scaffold(body: Text('Login Screen'));
            },
          },
        ),
      );

      // Pump frames until splash delay completes
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      expect(navigatedRoute, equals(HomeScreen.routeName));
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Login Screen'), findsNothing);
    });

    testWidgets('Unauthenticated user navigates to LoginScreen', (tester) async {
      SharedPreferences.setMockInitialValues({});

      String? navigatedRoute;

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (context) => const SplashScreen(),
            HomeScreen.routeName: (context) {
              navigatedRoute = HomeScreen.routeName;
              return const Scaffold(body: Text('Home Screen'));
            },
            LoginScreen.routeName: (context) {
              navigatedRoute = LoginScreen.routeName;
              return const Scaffold(body: Text('Login Screen'));
            },
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      expect(navigatedRoute, equals(LoginScreen.routeName));
      expect(find.text('Login Screen'), findsOneWidget);
      expect(find.text('Home Screen'), findsNothing);
    });
  });
}
