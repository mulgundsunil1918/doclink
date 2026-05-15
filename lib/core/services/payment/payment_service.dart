// Conditional import: web gets the stub, mobile gets the real Razorpay impl.
export 'payment_web.dart'
    if (dart.library.io) 'payment_native.dart';
