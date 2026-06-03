import 'dart:ui';

/// Static application-wide configuration constants.
///
/// This class centralizes values that don't change at runtime: app metadata,
/// supported locales, theme configuration, and currency defaults.
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // APP METADATA
  // ---------------------------------------------------------------------------

  /// The display name of the application.
  static const String appName = 'eSIM Marketplace';

  /// The package name (bundle ID) — used for RevenueCat & analytics.
  static const String packageName = 'com.esim.marketplace';

  /// The current app version shown in the UI.
  static const String appVersion = '1.0.0';

  // ---------------------------------------------------------------------------
  // LOCALIZATION (EasyLocalization)
  // ---------------------------------------------------------------------------

  /// Path inside the `assets/` folder where `.arb` translation files live.
  static const String translationsPath = 'assets/translations';

  /// All locales that the application supports.
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('id', 'ID'),
    Locale('ru', 'RU'),
  ];

  /// The locale that is used when the user's preferred locale is not in
  /// [supportedLocales].
  static const Locale fallbackLocale = Locale('en', 'US');

  /// The locale that the app starts with (before user preference is loaded).
  static const Locale defaultLocale = Locale('en', 'US');

  /// Human-readable labels for each supported locale (shown in language picker).
  static const Map<String, String> localeLabels = {
    'en_US': 'English',
    'id_ID': 'Bahasa Indonesia',
    'ru_RU': 'Русский',
  };

  // ---------------------------------------------------------------------------
  // CURRENCY
  // ---------------------------------------------------------------------------

  /// The default currency code (ISO 4217) used for display.
  static const String defaultCurrencyCode = 'USD';

  /// The currency symbol displayed in the UI.
  static const String defaultCurrencySymbol = r'$';

  // ---------------------------------------------------------------------------
  // THEME
  // ---------------------------------------------------------------------------

  /// Key used in [SharedPreferences] to persist the user's theme mode choice.
  static const String themeModeKey = 'theme_mode';

  /// The supported theme modes.
  static const List<String> themeModeLabels = [
    'System',
    'Light',
    'Dark',
  ];

  // ---------------------------------------------------------------------------
  // LIMITS
  // ---------------------------------------------------------------------------

  /// Maximum number of eSIMs a user can purchase in a single transaction.
  static const int maxESIMsPerOrder = 10;

  /// Minimum top-up amount in USD cents.
  static const double minTopupAmount = 5.0;

  /// Maximum top-up amount in USD cents.
  static const double maxTopupAmount = 500.0;
}