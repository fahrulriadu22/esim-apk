import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// A centralized logging utility for the eSIM Marketplace application.
///
/// Provides static methods for different log levels:
/// - [debug] / [info] : printed to console only (development logs).
/// - [warn] / [error] : printed to console AND recorded to Firebase Crashlytics
///   for remote monitoring in production.
///
/// All log messages are formatted with a UTC timestamp and log level prefix.
class AppLogger {
  AppLogger._();

  // ---------------------------------------------------------------------------
  // HELPER
  // ---------------------------------------------------------------------------

  /// Generates a formatted timestamp string (UTC) for log messages.
  static String get _timestamp {
    final DateTime now = DateTime.now().toUtc();
    final String year = now.year.toString().padLeft(4, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    final String second = now.second.toString().padLeft(2, '0');
    final String millisecond = now.millisecond.toString().padLeft(3, '0');
    return '$year-$month-$day $hour:$minute:$second.$millisecond';
  }

  /// Builds the formatted log line used for console output.
  static String _formatMessage(String level, String message) {
    return '[$_timestamp] [$level] $message';
  }

  // ---------------------------------------------------------------------------
  // PUBLIC LOG LEVELS
  // ---------------------------------------------------------------------------

  /// Log an informational message (console only).
  ///
  /// Use for general application flow and state changes that are useful during
  /// development but do not indicate any issues.
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    final String formatted = _formatMessage('INFO', message);
    debugPrint(formatted);
  }

  /// Log a debug message (console only).
  ///
  /// Use for detailed diagnostics during active debugging sessions. These logs
  /// are never sent to Crashlytics.
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    final String formatted = _formatMessage('DEBUG', message);
    debugPrint(formatted);
  }

  /// Log a warning message (console + Crashlytics).
  ///
  /// Warnings indicate potentially harmful situations that do not stop the
  /// application from functioning but deserve attention.
  static void warn(String message, [Object? error, StackTrace? stackTrace]) {
    final String formatted = _formatMessage('WARN', message);
    debugPrint(formatted);

    // Record non-fatal warning to Crashlytics for remote visibility.
    // Wrapped in try-catch because Crashlytics may not be available on web
    // or in development builds without GoogleService-Info.plist.
    try {
      FirebaseCrashlytics.instance.recordError(
        Exception('[$_timestamp] [WARN] $message'),
        stackTrace ?? StackTrace.current,
        reason: message,
        fatal: false,
      );
    } catch (_) {
      // Crashlytics unavailable — silently ignore
    }
  }

  /// Log an error message (console + Crashlytics).
  ///
  /// Errors indicate a failure that prevents a feature from working correctly.
  /// These are always recorded as non-fatal issues in Crashlytics so the team
  /// can monitor and address them.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    final String formatted = _formatMessage('ERROR', message);
    debugPrint(formatted);

    // Build a descriptive exception for Crashlytics
    final Exception exception = error is Exception
        ? error
        : Exception('[$_timestamp] [ERROR] $message');

    // Wrapped in try-catch because Crashlytics may not be available on web
    // or in development builds without GoogleService-Info.plist.
    try {
      FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace ?? StackTrace.current,
        reason: message,
        fatal: false,
      );
    } catch (_) {
      // Crashlytics unavailable — silently ignore
    }
  }
}