import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floret_app/features/wallet/model/wallet_model.dart';
import 'package:floret_app/features/wallet/repos/wallet_repository.dart';
import 'package:floret_app/features/wallet/screen/wallet_screen.dart';
import 'package:floret_app/features/wallet/viewmodel/wallet_view_model.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService {
  final dynamic responseData;
  MockApiService(this.responseData);

  Future<Response> getWalletBalance({String? token}) async {
    return Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/wallet/balance/'),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpHelper.clearAll();
  });

  group('Wallet Balance API & Display Tests', () {
    test('Parses exact backend response {id: 44, user: 396, balance: 1500.00, ...}', () {
      final json = {
        'id': 44,
        'user': 396,
        'balance': 1500.00,
        'auto_topup_enabled': false,
        'auto_topup_trigger_amount': null,
        'auto_topup_amount': null,
        'mandate_authorized': false,
        'mandate_id': null,
        'mandate_authorized_at': null,
        'created_at': '2026-10-17T05:54:47.478486Z',
        'updated_at': '2026-10-17T12:18:45.901470Z',
      };

      final model = WalletBalanceDataModel.fromJson(json);

      expect(model.id, 44);
      expect(model.user, 396);
      expect(model.balance, 1500.00);
      expect(model.autoTopupEnabled, false);
      expect(model.mandateAuthorized, false);
    });

    test('Parses balance if backend returns balance as a string or nested in data', () {
      final json1 = {'balance': '1500.00'};
      final model1 = WalletBalanceDataModel.fromJson(json1);
      expect(model1.balance, 1500.00);

      final json2 = {'data': {'id': 44, 'balance': 1500.00}};
      final map2 = Map<String, dynamic>.from(json2['data'] as Map);
      final model2 = WalletBalanceDataModel.fromJson(map2);
      expect(model2.balance, 1500.00);
    });

    testWidgets('WalletScreen displays formatted wallet balance ₹ 1500.00 from cached / fetched balance', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await SpHelper.saveString('wallet_balance', '1500.00');

      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // WALLETS BALANCE card should show ₹ 1500.00
      expect(find.text('WALLETS BALANCE'), findsOneWidget);
      expect(find.text('₹ 1500.00'), findsOneWidget);
    });

    test('WalletViewModel calculates total amount from wallet activity amounts', () {
      final repository = WalletRepository();
      final vm = WalletViewModel(repository: repository);

      final transactions = [
        const WalletTransactionItemModel(
          id: 119,
          title: 'Manual wallet top-up',
          date: '19 Oct 2026',
          amount: 500.00,
          isCredit: true,
          status: 'completed',
        ),
        const WalletTransactionItemModel(
          id: 116,
          title: 'Manual wallet top-up',
          date: '19 Oct 2026',
          amount: 500.00,
          isCredit: true,
          status: 'completed',
        ),
        const WalletTransactionItemModel(
          id: 111,
          title: 'Manual wallet top-up',
          date: '17 Oct 2026',
          amount: 1000.00,
          isCredit: true,
          status: 'completed',
        ),
        const WalletTransactionItemModel(
          id: 110,
          title: 'Pickup waste charge',
          date: '16 Oct 2026',
          amount: 200.00,
          isCredit: false,
          status: 'completed',
        ),
        const WalletTransactionItemModel(
          id: 109,
          title: 'Cancelled top-up',
          date: '15 Oct 2026',
          amount: 999.00,
          isCredit: true,
          status: 'failed',
        ),
      ];

      // Set bundle with transactions
      vm.setWalletBundle(
        vm.walletBundle.copyWith(
          walletTransactions: WalletTransactionsResponseModel(
            transactions: transactions,
            total: transactions.length,
          ),
        ),
      );

      // Total = 500 + 500 + 1000 - 200 = 1800.00 (failed 999 ignored)
      expect(vm.walletBalance, 1800.00);
      expect(vm.balanceModel.balance, 1800.00);
    });

    testWidgets('WalletScreen displays calculated wallet balance from wallet activity in WALLETS BALANCE card', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = WalletRepository();
      final vm = WalletViewModel(repository: repository);

      final transactions = [
        const WalletTransactionItemModel(
          id: 119,
          title: 'Manual wallet top-up',
          date: '19 Oct 2026',
          amount: 500.00,
          isCredit: true,
          status: 'completed',
        ),
        const WalletTransactionItemModel(
          id: 116,
          title: 'Manual wallet top-up',
          date: '19 Oct 2026',
          amount: 500.00,
          isCredit: true,
          status: 'completed',
        ),
        const WalletTransactionItemModel(
          id: 111,
          title: 'Manual wallet top-up',
          date: '17 Oct 2026',
          amount: 1000.00,
          isCredit: true,
          status: 'completed',
        ),
      ];

      vm.setWalletBundle(
        vm.walletBundle.copyWith(
          walletTransactions: WalletTransactionsResponseModel(
            transactions: transactions,
            total: transactions.length,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WalletScreen(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // WALLETS BALANCE card should show calculated total amount: 500 + 500 + 1000 = ₹ 2000.00
      expect(find.text('WALLETS BALANCE'), findsOneWidget);
      expect(find.text('₹ 2000.00'), findsOneWidget);
    });
  });
}
