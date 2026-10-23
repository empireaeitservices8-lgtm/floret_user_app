import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../model/wallet_model.dart';

/// Thin wrapper around the real Razorpay checkout SDK.
class RazorpayService {
  final Razorpay _razorpay = Razorpay();

  void Function(PaymentSuccessResponse)? _onSuccess;
  void Function(PaymentFailureResponse)? _onError;
  void Function(ExternalWalletResponse)? _onExternalWallet;

  RazorpayService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      _onSuccess?.call(r);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      _onError?.call(r);
    });
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {
      _onExternalWallet?.call(r);
    });
  }

  /// Opens the Razorpay checkout using the order returned by POST /api/wallet/topup/.
  void openCheckout({
    required WalletTopupOrderResponseModel order,
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    void Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;

    final options = <String, dynamic>{
      'key': order.keyId,
      'order_id': order.razorpayOrderId,
      'amount': order.amountInPaise ?? (order.amount * 100).round(),
      'currency': order.currency ?? 'INR',
      'name': order.name ?? 'Floret Technologies',
      'description': order.description ?? 'Wallet Balance Top-Up',
      if (order.prefill != null) 'prefill': order.prefill,
      'theme': {'color': '#0F1E36'},
    };
    debugPrint('💳 [RAZORPAY] Opening checkout: $options');
    _razorpay.open(options);
  }

  void dispose() => _razorpay.clear();
}
