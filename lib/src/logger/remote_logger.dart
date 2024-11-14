import 'package:flutter_feature_remote_logging/src/event/remote_logger_event.dart';
import 'package:logger/logger.dart';

typedef RemoteLoggerCallback = void Function(RemoteLoggerEvent event);

class FeatureRemoteLogger {
  static final Set<RemoteLoggerCallback> _logCallbacks = {};

  /// Register a [RemoteLoggerCallback] which is called for each new [RemoteLoggerEvent].
  static void addLogListener(RemoteLoggerCallback callback) {
    _logCallbacks.add(callback);
  }

  /// Removes a [RemoteLoggerCallback] which was previously registered.
  ///
  /// Returns whether the callback was successfully removed.
  static bool removeLogListener(RemoteLoggerCallback callback) {
    return _logCallbacks.remove(callback);
  }

  void log(
    Level level,
    String message, {
    Map<String, String>? labels,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final event = RemoteLoggerEvent(
      level,
      message,
      labels: labels,
      time: time,
      error: error,
      stackTrace: stackTrace,
    );
    for (final callback in _logCallbacks) {
      callback(event);
    }

    switch(level){
      case Level.debug:
        Logger().d(message);
        break;
      case Level.error:
        Logger().e(message);
        break;
      case Level.info:
        Logger().i(message);
        break;
      case Level.warning:
        Logger().w(message);
        break;
      case Level.fatal:
        Logger().f(message);
        break;
      default:
        Logger().log(level, message);
        break;
    }
  }
}
