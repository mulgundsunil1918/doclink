class AppConstants {
  AppConstants._();

  static const String appName = 'Doclink';
  static const String appVersion = '1.0.0';

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Session
  static const int sessionExpiryHours = 1;
  static const int refreshTokenDays = 30;

  // Consultation
  static const int preCallNotificationMinutes = 10;
  static const int callReconnectSeconds = 30;

  // Pagination
  static const int defaultPageSize = 20;

  // Slot
  static const int defaultSlotDurationMinutes = 15;
  static const int defaultBufferMinutes = 5;
}
