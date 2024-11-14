import 'dart:developer';

import 'package:googleapis/logging/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:logger/logger.dart';

import 'feature_remote_logging_service.dart';

class GoogleCloudLoggingServiceImpl extends FeatureRemoteLoggingService {
  late Map<String, dynamic> _serviceAccount;
  late String _projectId;
  String env;

  GoogleCloudLoggingServiceImpl({
    required Map<String, dynamic> serviceAccount,
    required this.env,
  }) {
    _serviceAccount = serviceAccount;

    assert(_serviceAccount.containsKey('project_id'));
    _projectId = _serviceAccount['project_id'];
  }

  late LoggingApi _loggingApi;
  bool _isSetup = false;

  @override
  Future<void> init() async {
    if (_isSetup) return;

    try {
      // Create credentials using ServiceAccountCredentials
      final credentials = ServiceAccountCredentials.fromJson(
        _serviceAccount,
      );

      // Authenticate using ServiceAccountCredentials and obtain an AutoRefreshingAuthClient authorized client
      final authClient = await clientViaServiceAccount(
        credentials,
        [LoggingApi.loggingWriteScope],
      );

      // Initialize the Logging API with the authorized client
      _loggingApi = LoggingApi(authClient);

      // Mark the Logging API setup as complete
      _isSetup = true;
      log("successfully setup google cloud logging api", level: Level.info.value);
    } catch (e) {
      log("failed to setup google cloud logging api", level: Level.error.value);
    }
  }

  @override
  void writeLog({required Level level, required String message, Map<String, String>? labels}) {
    if (!_isSetup) {
      // If Logging API is not setup, return
      log('cloud logging not initialized');
      return;
    }

    // It should in the format projects/[PROJECT_ID]/logs/[LOG_ID]
    final logName = 'projects/$_projectId/logs/$env';

    // Create a monitored resource
    final resource = MonitoredResource()..type = 'global';

    // Map log levels to severity levels
    final severityFromLevel = getSeverityLevel(level);

    // Create labels
    final currentLabels = {
      'project_id': _projectId,
      // Must match the project ID with the one in the JSON key file
      'level': level.name.toUpperCase(),
      'environment': env,
      // Optional but useful to filter logs by environment
      // 'user_id': 'your-app-user-id', // Useful to filter logs by userID
      // 'app_instance_id': 'your-app-instance-id', // Useful to filter logs by app instance ID e.g device ID + app version (iPhone-12-ProMax-v1.0.0)
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

    // Create a log entry
    final logEntry = LogEntry()
      ..logName = logName
      ..jsonPayload = {'message': message}
      ..resource = resource
      ..severity = severityFromLevel
      ..labels = currentLabels;

    // Create a write log entries request
    final request = WriteLogEntriesRequest()..entries = [logEntry];

    // Write the log entry using the Logging API and handle errors
    _loggingApi.entries.write(request).then((value) {
      log("success send remote log");
    }).catchError((error) {
      log('failed send remote log: $error', level: Level.error.value);
    });
  }
}
