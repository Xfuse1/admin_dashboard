import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Application-wide logger service.
///
/// Provides consistent logging across the application with
/// different log levels and formatted output.
class AppLogger {
  AppLogger._() {
    _init();
  }

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  late final Logger _logger;

  /// Initializes the logger with appropriate settings.
  void _init() {
    _logger = Logger(
      filter: _AppLogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: null, // Uses default ConsoleOutput
    );

    if (AppConfig.enableLogging) {
      info('Logger initialized');
      AppConfig.printConfig();
    }
  }

  /// Logs a verbose message (for very detailed information).
  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging) return;
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a debug message (for debugging information).
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message (for general information).
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message (for potential issues).
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging) return;
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message (for errors that need attention).
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // Always log errors, even if logging is disabled
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal error (for critical errors).
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // Always log fatal errors
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a BLoC event.
  void blocEvent(String blocName, String eventName,
      [Map<String, dynamic>? data]) {
    if (!AppConfig.enableLogging) return;
    final dataStr = data != null ? ' | Data: $data' : '';
    debug('[$blocName] Event: $eventName$dataStr');
  }

  /// Logs a BLoC state change.
  void blocState(String blocName, String fromState, String toState) {
    if (!AppConfig.enableLogging) return;
    debug('[$blocName] State: $fromState → $toState');
  }

  /// Logs an API request.
  void apiRequest(String method, String endpoint,
      [Map<String, dynamic>? params]) {
    if (!AppConfig.enableLogging) return;
    final paramsStr = params != null ? ' | Params: $params' : '';
    info('API $method: $endpoint$paramsStr');
  }

  /// Logs an API response.
  void apiResponse(String endpoint, int statusCode, [dynamic data]) {
    if (!AppConfig.enableLogging) return;
    info('API Response [$statusCode]: $endpoint');
  }

  /// Logs a Firebase operation.
  void firebase(String operation, String collection, [String? documentId]) {
    if (!AppConfig.enableLogging) return;
    final docStr = documentId != null ? '/$documentId' : '';
    debug('Firebase: $operation $collection$docStr');
  }

  /// Logs a navigation event.
  void navigation(String from, String to) {
    if (!AppConfig.enableLogging) return;
    debug('Navigation: $from → $to');
  }

  /// Logs user action.
  void userAction(String action, [Map<String, dynamic>? details]) {
    if (!AppConfig.enableLogging) return;
    final detailsStr = details != null ? ' | $details' : '';
    info('User Action: $action$detailsStr');
  }
}

/// Custom log filter that respects AppConfig.
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Always show errors and fatal
    if (event.level.index >= Level.error.index) {
      return true;
    }
    // Other logs only if enabled
    return AppConfig.enableLogging;
  }
}

/// Global logger instance for convenience.
final logger = AppLogger.instance;
