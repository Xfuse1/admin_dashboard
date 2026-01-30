/// Application configuration loaded from environment variables.
///
/// Use --dart-define or --dart-define-from-file to set values.
/// Example: flutter run --dart-define=USE_MOCK_DATA=true
abstract final class AppConfig {

  /// Firebase project ID (optional, for validation).
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  /// Enable debug logging.
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  /// Enable analytics tracking.
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  /// Application environment (dev, staging, prod).
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Whether the app is in production mode.
  static bool get isProduction => environment == 'prod';

  /// Whether the app is in development mode.
  static bool get isDevelopment => environment == 'dev';

  /// Whether the app is in staging mode.
  static bool get isStaging => environment == 'staging';

  /// API base URL (if needed for external services).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Prints current configuration (for debugging).
  static void printConfig() {
    if (!enableLogging) return;

    // ignore: avoid_print
    print('''
╔══════════════════════════════════════════╗
║         APP CONFIGURATION                ║
╠══════════════════════════════════════════╣
║ Environment:    $environment
║ Enable Logging: $enableLogging
║ Analytics:      $enableAnalytics
║ Firebase ID:    ${firebaseProjectId.isEmpty ? 'Not set' : firebaseProjectId}
╚══════════════════════════════════════════╝
    ''');
  }
}
