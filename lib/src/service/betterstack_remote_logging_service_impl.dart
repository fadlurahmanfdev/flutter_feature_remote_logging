import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'feature_remote_logging_service.dart';

class FeatureBetterStackRemoteLoggingServiceImpl extends FeatureRemoteLoggingService {
  late String _sourceToken;

  FeatureBetterStackRemoteLoggingServiceImpl({required String sourceToken}) {
    _sourceToken = sourceToken;
  }

  @override
  Future<void> init() async {}

  @override
  void writeLog({required Level level, required String message, Map<String, String>? labels}) {
    try {
      // Map log levels to severity levels
      final severityFromLevel = getSeverityLevel(level);

      final body = <String, dynamic>{};
      body['message'] = '[$severityFromLevel] - $message';

      final currentLabels = <String, String>{
        'level': level.name.toUpperCase(),
      };

      if (defaultLabels.isNotEmpty) {
        defaultLabels.forEach((key, value) {
          currentLabels[key] = value;
        });
      }

      if (labels != null) {
        labels.forEach((key, value) {
          currentLabels[key] = value;
        });
      }

      body['labels'] = currentLabels;

      unawaited(http.post(
        Uri.parse('https://in.logs.betterstack.com'),
        headers: {
          'Authorization': 'Bearer $_sourceToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).then((value) {
        if (value.statusCode == 202) {
          log("${value.statusCode} - success send remote log");
        } else {
          log("${value.statusCode} - failed send remote log");
        }
      }));
    } catch (e) {
      log("failed to write remote log: $e");
    }
  }
}
