import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Default Firebase configuration options for the eSIM Marketplace.
///
/// This class is generated / curated to hold the configuration for all
/// supported platforms. On Web the real project values are used; on
/// Android and iOS the Firebase SDK reads the `google-services.json` /
/// `GoogleService-Info.plist` at build time, so the values here are
/// placeholders to satisfy the API.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// Returns the [FirebaseOptions] for the platform on which the app is
  /// currently running.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _web;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iOS;
    }
    // Android resolves its configuration from `google-services.json`
    // at build time. The values below are safe placeholders that will be
    // overridden by the native SDK.
    return _android;
  }

  // ---------------------------------------------------------------------------
  // PLATFORM CONFIGURATIONS
  // ---------------------------------------------------------------------------

  /// Firebase options for the web platform.
  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: 'AIzaSyCzp7PG-hqZN9yEZNoIW-x5ZOxVTQw217E',
    authDomain: 'koperasi-ksmi.firebaseapp.com',
    projectId: 'koperasi-ksmi',
    storageBucket: 'koperasi-ksmi.firebasestorage.app',
    messagingSenderId: '725328966175',
    appId: '1:725328966175:web:c590e7fec432dafecf5b2a',
    measurementId: 'G-3Q1S6PGC7B',
  );

  /// Firebase options for Android.
  ///
  /// The actual values are injected by the Google Services Gradle plugin
  /// from `android/app/google-services.json`. The constants below are
  /// minimal placeholders required by the `firebase_core` API.
  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_ANDROID',
    appId: 'PLACEHOLDER_ANDROID',
    messagingSenderId: 'PLACEHOLDER_ANDROID',
    projectId: 'PLACEHOLDER_ANDROID',
  );

  /// Firebase options for iOS.
  ///
  /// The actual values are injected at build time from
  /// `ios/Runner/GoogleService-Info.plist`. The constants below are
  /// minimal placeholders required by the `firebase_core` API.
  static const FirebaseOptions _iOS = FirebaseOptions(
    apiKey: 'PLACEHOLDER_IOS',
    appId: 'PLACEHOLDER_IOS',
    messagingSenderId: 'PLACEHOLDER_IOS',
    projectId: 'PLACEHOLDER_IOS',
  );
}