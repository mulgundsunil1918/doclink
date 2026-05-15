// Web stub — razorpay_flutter is NOT imported so it is fully excluded from
// the web bundle. Web builds complete the booking without a payment modal.

class RazorpayService {
  void Function(String)? _onSuccess;
  void Function(String)? _onError;

  void init({
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
  }

  void open({
    required String keyId,
    required int amountPaise,
    required String name,
    required String description,
    String? contact,
  }) {
    _onSuccess?.call('web_${DateTime.now().millisecondsSinceEpoch}');
  }

  void dispose() {}
}
