/// Centralized API configuration for the eSIM Marketplace application.
///
/// All API endpoints, timeout values, and auth-related constants are defined
/// here to avoid scattering magic values across the codebase.
class ApiConfig {
  ApiConfig._();

  // ---------------------------------------------------------------------------
  // BASE URL
  // ---------------------------------------------------------------------------

  /// The root URL of the eSIM Marketplace backend API.
  ///
  /// In production, this should point to the deployed server. For local
  /// development, use the local instance (e.g., http://10.0.2.2:3000 for
  /// Android emulator or http://localhost:3000 for iOS simulator/web).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://roamwi.com',
  );

  // ---------------------------------------------------------------------------
  // TIMEOUTS
  // ---------------------------------------------------------------------------

  /// Default connection timeout for HTTP requests.
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Default receive timeout for HTTP responses.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Timeout for payment-related endpoints (PayPal, TON, Telegram Stars)
  /// which may require longer processing.
  static const Duration paymentTimeout = Duration(seconds: 60);

  /// Interval in seconds for polling payment status (PayPal).
  static const int paymentPollIntervalSeconds = 10;

  /// Maximum number of polling attempts for payment verification.
  static const int maxPaymentPollAttempts = 30;

  // ---------------------------------------------------------------------------
  // AUTH HEADER
  // ---------------------------------------------------------------------------

  /// The header key used to send Telegram initData for authentication.
  static const String telegramDataHeader = 'X-Telegram-Data';

  // ---------------------------------------------------------------------------
  // API ENDPOINTS
  // ---------------------------------------------------------------------------

  // -- Locations -------------------------------------------------------------
  static const String locationsEndpoint = '/api/locations';

  // -- Packages --------------------------------------------------------------
  static const String packagesEndpoint = '/api/package';
  static const String allPackagesEndpoint = '/api/all-packages';
  static const String publicPackagesEndpoint = '/api/public-packages';
  static const String regionPackagesEndpoint = '/api/region-packages';

  // -- Orders ----------------------------------------------------------------
  static const String ordersEndpoint = '/api/orders';
  static const String createOrderEndpoint = '/api/order';

  // -- eSIMs -----------------------------------------------------------------
  static const String esimsEndpoint = '/api/esims';

  // -- Balance & Top-up ------------------------------------------------------
  static const String balanceEndpoint = '/api/balance';
  static const String topupHistoryEndpoint = '/api/topup-history';

  // -- Payments --------------------------------------------------------------
  static const String initPaymentEndpoint = '/api/init-payment';
  static const String paypalCreateEndpoint = '/api/paypal/create';
  static const String verifyTonEndpoint = '/api/verify-ton';

  // -- User ------------------------------------------------------------------
  static const String initUserEndpoint = '/api/init-user';

  // -- Payment History -------------------------------------------------------
  static const String paymentHistoryEndpoint = '/api/payment-history';

  // -- Transaction Detail ----------------------------------------------------
  static const String transactionDetailEndpoint = '/api/transaction-detail';

  // -- Webhook (server-side only, not used by Flutter) -----------------------
  static const String webhookEndpoint = '/api/webhook';

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  /// Default number of items per page for paginated endpoints.
  static const int defaultPageLimit = 5;

  // ---------------------------------------------------------------------------
  // REVENUECAT (optional subscriptions)
  // ---------------------------------------------------------------------------

  /// RevenueCat API key for iOS.
  static const String revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    defaultValue: '',
  );

  /// RevenueCat API key for Android.
  static const String revenueCatGoogleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
    defaultValue: '',
  );
}