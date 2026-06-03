import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/firebase_options.dart';
import 'utils/logger.dart';

// =============================================================================
// GLOBAL NAVIGATOR KEY
// =============================================================================
// The navigator key is used to access the GoRouter (or Navigator) from
// anywhere in the app — for example, to trigger navigation from a service
// class or a non-widget Dart file that holds no [BuildContext].

/// A global key that references the root [NavigatorState] so that services,
/// providers, and other non-widget code can push/pop routes without needing
/// to obtain a [BuildContext] from the widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// =============================================================================
// ENTRY POINT
// =============================================================================
// The [main] function is the first Dart code that the Flutter engine
// executes. Its responsibilities are:
//
// 1. Ensure Flutter framework bindings are ready.
// 2. Initialize Firebase with platform-specific options.
// 3. Wire up global error handlers → Crashlytics.
// 4. Lock the app to portrait orientation.
// 5. Initialize EasyLocalization (i18n).
// 6. Launch the widget tree wrapped in Riverpod's [ProviderScope]
//    and EasyLocalization's locale management.
//
// Every step is guarded so that a failure in one step (e.g. Firebase being
// unavailable in a development environment) does not prevent the app from
// starting.

Future<void> main() async {
  // -------------------------------------------------------------------------
  // BINDING INITIALIZATION
  // -------------------------------------------------------------------------
  // Must be called first so that async platform channels are available.
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // FIREBASE INITIALIZATION
  // -------------------------------------------------------------------------
  // Firebase is initialized once at startup. The configuration is read from
  // [DefaultFirebaseOptions.currentPlatform] which honours:
  //
  // • Web            → hard-coded Firebase web app config.
  // • Android        → injected by the Google Services Gradle plugin from
  //                    `android/app/google-services.json` at build time.
  // • iOS / macOS    → injected from `ios/Runner/GoogleService-Info.plist`
  //                    (or the macOS equivalent) at build time.
  //
  // If Firebase is missing (e.g. the platform configuration files were not
  // placed correctly) the catch clause logs a warning and the app continues
  // — Crashlytics and Analytics will simply be unavailable for that session.

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // -----------------------------------------------------------------------
    // CRASHLYTICS – FRAMEWORK ERRORS
    // -----------------------------------------------------------------------
    // Every uncaught synchronous exception thrown inside a [build] method
    // (or any other framework callback) is forwarded to Crashlytics as a
    // non‑fatal issue so the team can triage it in the Firebase console.

    FlutterError.onError = (FlutterErrorDetails details) {
      // First, let Flutter's own error presentation run (red screen in
      // debug, grey screen in release/profile).
      FlutterError.presentError(details);

      // Then record the same error in Crashlytics.
      FirebaseCrashlytics.instance.recordFlutterError(details);

      // Also mirror to our own logger for local console output.
      AppLogger.error(
        'FlutterError',
        details.exception,
        details.stack,
      );
    };

    // -----------------------------------------------------------------------
    // CRASHLYTICS – PLATFORM DISPATCHER ERRORS
    // -----------------------------------------------------------------------
    // Uncaught asynchronous errors (e.g. thrown inside a `Future` that is
    // never awaited) are captured here. They are recorded as FATAL because
    // they represent truly unhandled failures.

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: true,
      );

      AppLogger.error(
        'PlatformDispatcher',
        error,
        stack,
      );

      // Returning `true` tells the platform that the error has been handled
      // and the app should not be terminated.
      return true;
    };

    AppLogger.info('Firebase initialized successfully');
  } catch (e, stack) {
    // Firebase may fail to initialize if the platform-specific config files
    // (google-services.json, GoogleService-Info.plist) are missing or
    // malformed. In that case we log a warning and let the app proceed
    // without Firebase features (Crashlytics, Analytics, etc.).

    debugPrint('⚠ Firebase not configured: $e');

    // Still log to our custom logger so the event is visible in any
    // console-based logging pipeline.
    AppLogger.warn(
      'Firebase initialization failed — app will run without Crashlytics',
      e,
      stack,
    );
  }

  // -------------------------------------------------------------------------
  // SCREEN ORIENTATION LOCK
  // -------------------------------------------------------------------------
  // This is a mobile‑first application designed for portrait usage.
  // Landscape orientation is deliberately disabled to keep the UI simple
  // and predictable for all screen sizes.

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Optionally hide the system status bar for a full-bleed look.
  // Uncomment the following two lines if a fully immersive UI is desired.
  //
  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   systemNavigationBarColor: Colors.transparent,
  // ));

  // -------------------------------------------------------------------------
  // EASY LOCALIZATION INITIALIZATION
  // -------------------------------------------------------------------------
  // EasyLocalization reads `.arb` files from `assets/translations/` and
  // provides the `.tr()` extension on all strings. It also persists the
  // user's locale choice via `saveLocale: true`.

  await EasyLocalization.ensureInitialized();

  // -------------------------------------------------------------------------
  // CRASHLYTICS – FLUTTER ERROR PRESENTATION OVERRIDE (OPTIONAL)
  // -------------------------------------------------------------------------
  // In release mode we can replace the default "red screen of death" with
  // a custom error widget. Uncomment the section below if a white‑label
  // crash screen is preferred.
  //
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Material(
  //     child: Container(
  //       color: Colors.white,
  //       child: Center(
  //         child: Padding(
  //           padding: const EdgeInsets.all(24),
  //           child: Text(
  //             'Something went wrong.\nPlease restart the app.',
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // };

  // -------------------------------------------------------------------------
  // RUN APP
  // -------------------------------------------------------------------------
  // The widget tree is wrapped in two layers:
  //
  // 1. [EasyLocalization] – makes locale data and the `.tr()` extension
  //    available to the entire subtree.
  // 2. [ProviderScope]    – the root of Riverpod's provider container;
  //    all `Provider`/`Notifier` instances live here.
  // 3. [ESIMApp]          – the root MaterialApp widget (see `app.dart`).

  runApp(
    EasyLocalization(
      // -----------------------------------------------
      // LOCALE CONFIGURATION
      // -----------------------------------------------
      // The list of locales that the app is translated into.
      // The first locale serves as the fallback when the user's device
      // locale is not among the supported ones.
      supportedLocales: AppConfig.supportedLocales,

      // Path inside the `assets/` directory where `.arb` files are stored.
      path: AppConfig.translationsPath,

      // Used when a requested locale cannot be resolved.
      fallbackLocale: AppConfig.fallbackLocale,

      // The locale the app boots with before any user preference is loaded.
      startLocale: AppConfig.defaultLocale,

      // `true` persists the locale so the user's choice survives app
      // restarts (stored via SharedPreferences).
      saveLocale: true,

      // When `false`, the full language+country code (e.g. "en-US") is
      // used; when `true`, only the language part ("en") is considered.
      useOnlyLangCode: false,

      // -----------------------------------------------
      // WIDGET TREE
      // -----------------------------------------------
      child: const ProviderScope(
        child: ESIMApp(),
      ),
    ),
  );

  // -------------------------------------------------------------------------
  // POST-LAUNCH SETUP
  // -------------------------------------------------------------------------
  // Any one‑time setup that requires the widget tree to be fully mounted
  // can be scheduled here via `WidgetsBinding.instance.addPostFrameCallback`.
  //
  // Example – request notification permissions after the first frame:
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   await _requestNotificationPermissions();
  // });
}

// =============================================================================
// ADDITIONAL HELPERS (uncomment and implement as needed)
// =============================================================================

// /// Requests push-notification permissions from the OS.
// /// Call this *after* the first frame has been rendered (from a
// /// `postFrameCallback`) so the user is not spammed during the splash
// /// screen.
// Future<void> _requestNotificationPermissions() async {
//   // Example using firebase_messaging:
//   // final messaging = FirebaseMessaging.instance;
//   // final settings = await messaging.requestPermission(
//   //   alert: true,
//   //   badge: true,
//   //   sound: true,
//   // );
//   // AppLogger.info('Notification permission: ${settings.authorizationStatus}');
// }

// /// Pre-warms a set of commonly used images so they appear instantly the
// /// first time they are shown (useful for flag assets).
// Future<void> _precacheImages(BuildContext context) async {
//   await Future.wait([
//     precacheImage(const AssetImage('assets/images/placeholder.png'), context),
//   ]);
// }