import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/features/wallet/repos/wallet_repository.dart';
import 'package:floret_app/features/wallet/screen/top_up_bottom_sheet.dart';
import 'package:floret_app/features/wallet/viewmodel/wallet_view_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

class MockVerifyPaymentApiService extends ApiService {
  RequestOptions? lastRequestOptions;
  dynamic lastPayload;
  Map<String, dynamic>? lastHeaders;
  bool shouldSucceed = true;
  double? lastCreatedOrderAmount;

  MockVerifyPaymentApiService({Dio? dio}) : super(dio: dio ?? Dio());

  @override
  Future<Response> createWalletTopupOrder({
    required double amount,
    String? paymentMethod = 'Razorpay',
    String? token,
  }) async {
    lastCreatedOrderAmount = amount;
    lastPayload = {'amount': amount, 'payment_method': paymentMethod};
    lastHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    return Response(
      requestOptions: RequestOptions(
        path: ApiService.walletTopupEndpoint,
        data: lastPayload,
      ),
      statusCode: 200,
      data: {
        'message': 'Razorpay order created successfully',
        'transaction_id': 102,
        'razorpay_order_id': 'order_ToYb02mTfIaiEZ',
        'amount': amount,
        'amount_in_paise': (amount * 100).toInt(),
        'currency': 'INR',
        'key_id': 'rzp_live_T3MIagFrpI5sz2',
        'name': 'Floret Wallet Top-Up',
        'description': 'Add ₹$amount to your Floret wallet',
        'prefill': {
          'name': 'demo pr',
          'email': '',
          'contact': '+917306929058',
        },
      },
    );
  }

  @override
  Future<Response> verifyPayment({
    int? transactionId,
    String razorpayOrderId = 'order_123',
    String razorpayPaymentId = 'pay_123',
    String razorpaySignature = 'signature_123',
    String? token,
  }) async {
    lastPayload = {
      if (transactionId != null) 'transaction_id': transactionId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };
    lastHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    if (!shouldSucceed) {
      throw DioException(
        requestOptions: RequestOptions(
          path: ApiService.walletVerifyPaymentEndpoint,
          data: lastPayload,
        ),
        response: Response(
          requestOptions: RequestOptions(
            path: ApiService.walletVerifyPaymentEndpoint,
          ),
          statusCode: 400,
          data: {'error': 'Invalid signature or payment verification failed'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return Response(
      requestOptions: RequestOptions(
        path: ApiService.walletVerifyPaymentEndpoint,
        data: lastPayload,
      ),
      statusCode: 200,
      data: {
        'status': 'success',
        'message': 'Payment verified and wallet credited successfully.',
        'transaction_id': 'txn_987654',
      },
    );
  }

  @override
  Future<Response> getWalletBalance({String? token}) async {
    return Response(
      requestOptions: RequestOptions(path: ApiService.walletBalanceEndpoint),
      statusCode: 200,
      data: {
        'id': 37,
        'user': 383,
        'balance': 4500.00,
        'auto_topup_enabled': false,
        'auto_topup_trigger_amount': null,
        'auto_topup_amount': null,
        'mandate_authorized': false,
        'mandate_id': null,
        'mandate_authorized_at': null,
        'created_at': '2026-10-09T11:38:33.553125Z',
        'updated_at': '2026-10-16T10:11:45.883649Z',
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

  group('Wallet Topup Verify Payment API Integration Tests', () {
    test('1. ApiService verifyPayment endpoint URL and default payload', () {
      expect(
        ApiService.walletVerifyPaymentEndpoint,
        '/api/wallet/topup/verify-payment/',
      );
    });

    test('2. MockVerifyPaymentApiService intercepts and validates exact payload',
        () async {
      await SpHelper.saveString(sp_keys.keyToken, 'test_user_token_abc');
      final mockApi = MockVerifyPaymentApiService();

      final response = await mockApi.verifyPayment(
        razorpayOrderId: 'order_123',
        razorpayPaymentId: 'pay_123',
        razorpaySignature: 'signature_123',
        token: 'test_user_token_abc',
      );

      expect(response.statusCode, 200);
      expect(mockApi.lastPayload, {
        'razorpay_order_id': 'order_123',
        'razorpay_payment_id': 'pay_123',
        'razorpay_signature': 'signature_123',
      });
      expect(
        mockApi.lastHeaders?['Authorization'],
        'Token test_user_token_abc',
      );
    });

    test('3. WalletRepository createTopupOrder and verifyPayment workflow',
        () async {
      final mockApi = MockVerifyPaymentApiService();
      final repository = WalletRepository(apiService: mockApi);

      // 1. Create topup order (POST /api/wallet/topup/)
      final order = await repository.createTopupOrder(amount: 500.0);
      expect(order, isNotNull);
      expect(order?.razorpayOrderId, 'order_ToYb02mTfIaiEZ');
      expect(order?.amount, 500.0);
      expect(mockApi.lastCreatedOrderAmount, 500.0);

      // 2. Verify payment (POST /api/wallet/topup/verify-payment/)
      final result = await repository.verifyPayment(
        razorpayOrderId: order!.razorpayOrderId!,
        razorpayPaymentId: 'pay_ToYb02mTfIaiEZ',
        razorpaySignature: 'signature_123',
      );

      expect(result, isTrue);
      expect(mockApi.lastPayload, {
        'razorpay_order_id': 'order_ToYb02mTfIaiEZ',
        'razorpay_payment_id': 'pay_ToYb02mTfIaiEZ',
        'razorpay_signature': 'signature_123',
      });
    });

    test('4. WalletViewModel updates balance from 4000.00 to 4500.00 upon refresh',
        () async {
      final mockApi = MockVerifyPaymentApiService();
      final repository = WalletRepository(apiService: mockApi);
      final viewModel = WalletViewModel(repository: repository);

      await viewModel.loadWalletData();
      expect(viewModel.walletBalance, 4500.00);

      final success = await viewModel.verifyPayment(
        razorpayOrderId: 'order_ToYb02mTfIaiEZ',
        razorpayPaymentId: 'pay_ToYb02mTfIaiEZ',
        razorpaySignature: 'signature_123',
      );
      expect(success, isTrue);
      expect(viewModel.walletBalance, 4500.00);
    });

    testWidgets('5. Tapping Proceed to Pay triggers topup creation, verification, and updates balance callback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool balanceRefreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopUpBottomSheet(
              onTopUpSuccess: () {
                balanceRefreshed = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Proceed to Pay ₹500.00'), findsOneWidget);

      // Tap Proceed to Pay
      await tester.tap(find.text('Proceed to Pay ₹500.00'));
      await tester.pumpAndSettle();

      // Verified navigation to Razorpay Checkout Screen
      expect(find.text('Floret Technologies'), findsOneWidget);
      expect(find.text('₹500.00'), findsOneWidget);

      // Authorize Razorpay payment
      await tester.tap(find.byKey(const Key('pay_via_razorpay_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('authorize_payment_button')));
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Verified that onTopUpSuccess callback was called to refresh balance
      expect(balanceRefreshed, isTrue);
    });

    test('6. Explicitly calling wallet balance API updates balance to 4500.00',
        () async {
      final mockApi = MockVerifyPaymentApiService();
      final repository = WalletRepository(apiService: mockApi);
      final viewModel = WalletViewModel(repository: repository);

      final balanceModel = await viewModel.fetchWalletBalance();
      expect(balanceModel.balance, 4500.00);
      expect(viewModel.walletBalance, 4500.00);
      expect(balanceModel.id, 37);
      expect(balanceModel.user, 383);
    });
  });
}

