import 'package:floret_app/services/web_api_services.dart';
import '../model/wallet_model.dart';

class WalletRepository {
  final WebAPIService _webAPIService;

  WalletRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<WalletBalanceModel> fetchBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const WalletBalanceModel(
      balance: 250.00,
      rewardPoints: 120,
      pendingAmount: 0.00,
    );
  }

  Future<List<WalletTransactionModel>> fetchTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      WalletTransactionModel(
        id: 'tx_1',
        title: 'UPI Top-Up',
        date: '12 Sep 2026, 04:30 PM',
        amount: 500.00,
        isCredit: true,
      ),
      WalletTransactionModel(
        id: 'tx_2',
        title: 'Monthly Doorstep Fee',
        date: '01 Sep 2026, 09:00 AM',
        amount: 250.00,
        isCredit: false,
      ),
    ];
  }

  Future<bool> topUpWallet(double amount) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> setupAutoTopUp({
    required double triggerAmount,
    required double topUpAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> setupMandate({
    required String bankName,
    required String accountNumber,
    required double maxLimit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> redeemRewards(int points) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
