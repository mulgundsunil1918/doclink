import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  final Razorpay _rp = Razorpay();
  void Function(String)? onSuccess;
  void Function(String)? onError;

  void init({
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
  }) {
    this.onSuccess = onSuccess;
    this.onError = onError;
    _rp.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse r) => onSuccess(r.paymentId ?? ''));
    _rp.on(Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse r) => onError(r.message ?? 'Payment failed'));
    _rp.on(Razorpay.EVENT_EXTERNAL_WALLET,
        (ExternalWalletResponse _) {});
  }

  void open({
    required String keyId,
    required int amountPaise,
    required String name,
    required String description,
    String? contact,
  }) {
    _rp.open({
      'key': keyId,
      'amount': amountPaise,
      'name': name,
      'description': description,
      'currency': 'INR',
      'prefill': {'contact': contact ?? ''},
      'theme': {'color': '#4F46E5'},
    });
  }

  void dispose() => _rp.clear();
}
