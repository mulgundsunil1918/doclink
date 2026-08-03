import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Outcome of trying to hand the patient off to their UPI app.
enum UpiLaunchResult {
  /// A UPI app was opened. The patient still has to come back and submit the
  /// UTR — we get no callback from the bank.
  launched,

  /// No app on this device can handle a `upi://` intent (common on iOS and
  /// always true on web). Show the VPA and let the patient pay manually.
  noUpiApp,

  /// The doctor has not configured a valid UPI ID yet.
  invalidPayee,
}

/// Sends the consultation fee straight to the doctor's own UPI ID.
///
/// Doclink is not in the money path: there is no gateway, no platform merchant
/// account and no cut. The trade-off is that no webhook tells us the payment
/// succeeded, so the patient submits the UTR and the doctor confirms the credit
/// landed in their bank.
class UpiPaymentService {
  /// A VPA looks like `name@bank` — letters, digits, dot, dash or underscore
  /// before the `@`, and an alphabetic handle after it.
  static final _vpaPattern = RegExp(r'^[\w.\-]{2,256}@[A-Za-z]{2,64}$');

  static bool isValidVpa(String? vpa) =>
      vpa != null && _vpaPattern.hasMatch(vpa.trim());

  /// Our own reference for the transaction, echoed back in the UPI app as `tr`.
  /// Alphanumeric only and well under the 35-char limit banks enforce.
  static String newTxnRef() {
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = Random().nextInt(1679616).toRadixString(36).padLeft(4, '0');
    return 'DL$ts$rand'.toUpperCase();
  }

  /// Builds the `upi://pay` deep link. Kept separate from [pay] so it can be
  /// rendered into a QR code for the desktop/web case.
  static Uri buildUri({
    required String payeeVpa,
    required String payeeName,
    required double amount,
    required String note,
    required String txnRef,
  }) {
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': payeeVpa.trim(),
        'pn': payeeName.trim(),
        'am': amount.toStringAsFixed(2),
        'cu': 'INR',
        'tn': note,
        'tr': txnRef,
      },
    );
  }

  /// Opens the patient's UPI app with the doctor's VPA and the amount
  /// pre-filled. Returns what actually happened so the UI can fall back.
  static Future<UpiLaunchResult> pay({
    required String? payeeVpa,
    required String payeeName,
    required double amount,
    required String note,
    required String txnRef,
  }) async {
    if (!isValidVpa(payeeVpa)) return UpiLaunchResult.invalidPayee;

    // Browsers cannot resolve a upi:// intent — go straight to manual.
    if (kIsWeb) return UpiLaunchResult.noUpiApp;

    final uri = buildUri(
      payeeVpa: payeeVpa!,
      payeeName: payeeName,
      amount: amount,
      note: note,
      txnRef: txnRef,
    );

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      return ok ? UpiLaunchResult.launched : UpiLaunchResult.noUpiApp;
    } catch (_) {
      return UpiLaunchResult.noUpiApp;
    }
  }
}
