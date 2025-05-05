import 'dart:developer';

import 'package:logger/logger.dart';

class TLoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    // Customize the log levels based on your needs
    level: Level.debug,
  );

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [dynamic error]) {
    _logger.e(message, error: error, stackTrace: StackTrace.current);
  }

  static void customPrint(dynamic message, [String? endpoint]) {
    final trace = StackTrace.current;
    final traceLines = trace.toString().split('\n');
    final callerLine = traceLines[1]; // Get the caller's line information
    log('[$callerLine] ${endpoint ?? ""} $message');
  }
}
