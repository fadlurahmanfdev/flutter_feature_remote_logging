import 'package:logger/logger.dart';

class RemoteLoggerEvent {
  final Level level;
  final String message;
  final Map<String, String>? labels;
  final Object? error;
  final StackTrace? stackTrace;

  /// Time when this log was created.
  final DateTime time;

  RemoteLoggerEvent(
    this.level,
    this.message, {
    this.labels,
    DateTime? time,
    this.error,
    this.stackTrace,
  }) : time = time ?? DateTime.now();
}
