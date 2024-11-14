library feature_remote_logging_package_interface;

import 'dart:developer';

import 'package:logger/logger.dart';

abstract class FeatureRemoteLoggingService {
  Future<void> init();

  final _defaultLabels = <String, String> {};
  Map<String, String> get defaultLabels => _defaultLabels;

  void addLabels({required Map<String, String> labels}) {
    log("current default label: $defaultLabels");
    labels.forEach((key, value) {
      defaultLabels[key] = value;
    });
    log("modified default label: $defaultLabels");
  }

  void removeLabels({required List<String> labels}){
    for (final label in labels) {
      defaultLabels.removeWhere((key, value) => value == label);
    }
  }

  String getSeverityLevel(Level level){
    // Map log levels to severity levels
    final severityFromLevel = switch (level) {
      Level.fatal => 'CRITICAL',
      Level.error => 'ERROR',
      Level.warning => 'WARNING',
      Level.info => 'INFO',
      Level.debug => 'DEBUG',
      _ => 'NOTICE',
    };
    return severityFromLevel;
  }

  void writeLog({required Level level, required String message, Map<String, String>? labels});
}
