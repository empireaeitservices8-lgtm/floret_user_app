import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/wallet/model/wallet_model.dart';
import 'package:floret_app/features/wallet/repos/wallet_repository.dart';
import 'package:floret_app/features/wallet/screen/redeem_rewards_bottom_sheet.dart';
import 'package:floret_app/features/wallet/viewmodel/wallet_view_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_endpoints.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
  });

  group('Wallet Redeem API & Model Tests', () {
    test('ApiEndpoints and ApiService constants match exact endpoint', () {
      expect(ApiEndpoints.walletRedeem, '/api/wallet/redeem/');
      expect(ApiService.walletRedeemEndpoint, '/api/wallet/redeem/');
    });

    test('WalletRedeemResponseModel parses exact user response correctly', () {
      final json = {
        "message": "Wallet redemption successful",
        "amount_redeemed": "5.00",
        "remaining_balance": "3.00",
        "transaction_id": "REDEEM_1795004876"
      };

      final model = WalletRedeemResponseModel.fromJson(json);

      expect(model.success, isTrue);
      expect(model.message, "Wallet redemption successful");
      expect(model.amountRedeemed, "5.00");
      expect(model.remainingBalance, "3.00");
      expect(model.transactionId, "REDEEM_1795004876");
    });

    test('WalletRedeemResponseModel handles failure responses gracefully', () {
      final json = {
        "error": "Insufficient wallet balance",
      };

      final model = WalletRedeemResponseModel.fromJson(json, success: false);

      expect(model.success, isFalse);
      expect(model.message, "Insufficient wallet balance");
      expect(model.amountRedeemed, isNull);
    });

    test('WalletRepository.redeemWallet returns mock response in test environment', () async {
      final repo = WalletRepository();
      final result = await repo.redeemWallet(walletAmount: 5);

      expect(result.success, isTrue);
      expect(result.message, 'Wallet redemption successful');
      expect(result.amountRedeemed, '5.00');
    });

    test('WalletViewModel.redeemWallet invokes repo and completes', () async {
      final vm = WalletViewModel();
      final result = await vm.redeemWallet(5);

      expect(result.success, isTrue);
      expect(result.message, 'Wallet redemption successful');
    });

    testWidgets('RedeemRewardsBottomSheet Confirm Redeem passes wallet amount 5', (tester) async {
      num? capturedAmount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RedeemRewardsBottomSheet(
              availablePoints: 0,
              onConfirmRedeem: (amount) {
                capturedAmount = amount;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find Confirm Redeem button
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm Redeem');
      expect(confirmBtn, findsOneWidget);

      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Amount should be passed even if available points is 0
      expect(capturedAmount, 5);
    });
  });
}
