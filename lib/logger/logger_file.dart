import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final dynamic data;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.data,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'tag': tag,
      'message': message,
      'data': data?.toString(),
      'stackTrace': stackTrace,
    };
  }

  String get levelIcon {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔥';
    }
  }

  Color get levelColor {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.purple;
    }
  }
}

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final Queue<LogEntry> _logs = Queue<LogEntry>();
  final int _maxLogs = 1000; // Maximum number of logs to keep in memory

  List<LogEntry> get logs => _logs.toList();

  void _addLog(LogLevel level, String tag, String message, {dynamic data, String? stackTrace}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      data: data,
      stackTrace: stackTrace,
    );

    _logs.addLast(entry);

    // Remove old logs if exceeding max limit
    while (_logs.length > _maxLogs) {
      _logs.removeFirst();
    }

    // Also print to console in debug mode
    print('${entry.levelIcon} [${entry.tag}] ${entry.message}');
    if (data != null) print('Data: $data');
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }

  void debug(String tag, String message, {dynamic data}) {
    _addLog(LogLevel.debug, tag, message, data: data);
  }

  void info(String tag, String message, {dynamic data}) {
    _addLog(LogLevel.info, tag, message, data: data);
  }

  void warning(String tag, String message, {dynamic data}) {
    _addLog(LogLevel.warning, tag, message, data: data);
  }

  void error(String tag, String message, {dynamic data, String? stackTrace}) {
    _addLog(LogLevel.error, tag, message, data: data, stackTrace: stackTrace);
  }

  void critical(String tag, String message, {dynamic data, String? stackTrace}) {
    _addLog(LogLevel.critical, tag, message, data: data, stackTrace: stackTrace);
  }

  // Log exceptions with full stack trace
  void logException(String tag, dynamic exception, StackTrace? stackTrace) {
    error(tag, exception.toString(), stackTrace: stackTrace?.toString());
  }

  // Clear all logs
  void clear() {
    _logs.clear();
  }

  // Export logs as JSON string
  String exportLogs() {
    final logsJson = _logs.map((log) => log.toJson()).toList();
    return jsonEncode(logsJson);
  }

  // Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  // Get logs by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag.toLowerCase().contains(tag.toLowerCase())).toList();
  }

  // Search logs by message content
  List<LogEntry> searchLogs(String query) {
    final lowerQuery = query.toLowerCase();
    return _logs.where((log) =>
    log.message.toLowerCase().contains(lowerQuery) ||
        log.tag.toLowerCase().contains(lowerQuery) ||
        (log.data?.toString().toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
}

// Extension for easy logging from any class
extension LoggerExtension on Object {
  void logDebug(String message, {dynamic data}) {
    AppLogger().debug(runtimeType.toString(), message, data: data);
  }

  void logInfo(String message, {dynamic data}) {
    AppLogger().info(runtimeType.toString(), message, data: data);
  }

  void logWarning(String message, {dynamic data}) {
    AppLogger().warning(runtimeType.toString(), message, data: data);
  }

  void logError(String message, {dynamic data, String? stackTrace}) {
    AppLogger().error(runtimeType.toString(), message, data: data, stackTrace: stackTrace);
  }

  void logCritical(String message, {dynamic data, String? stackTrace}) {
    AppLogger().critical(runtimeType.toString(), message, data: data, stackTrace: stackTrace);
  }

  void logException(dynamic exception, StackTrace? stackTrace) {
    AppLogger().logException(runtimeType.toString(), exception, stackTrace);
  }
}
