import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:example/data/dto/model/feature_model.dart';
import 'package:example/presentation/widget/feature_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_feature_remote_logging/flutter_feature_remote_logging.dart';
import 'package:logger/logger.dart';

late GoogleCloudLoggingServiceImpl googleServiceImpl;
late FeatureBetterStackRemoteLoggingServiceImpl betterstackServiceImpl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // google cloud logging
      try {
        DefaultAssetBundle.of(context).loadString('assets/example-learn-purpose-4dd93f634791.json').then((value) {
          final serviceAccount = json.decode(value) as Map<String, dynamic>;
          log("service-account: $serviceAccount");
          googleServiceImpl = GoogleCloudLoggingServiceImpl(
            serviceAccount: serviceAccount,
            env: "dev",
          );
          googleServiceImpl.init();
        });
      } catch (e) {
        log("failed init google service: $e");
      }

      // betterstack
      try {
        dotenv.load(fileName: '.env').then((value) {
          final sourceToken = dotenv.env['BETTERSTACK_SOURCE_TOKEN'];
          if (sourceToken == null) throw Exception('source token missing');
          betterstackServiceImpl = FeatureBetterStackRemoteLoggingServiceImpl(sourceToken: sourceToken);
          betterstackServiceImpl.init();
        });
      } catch (e) {
        log("failed init betterstack: $e");
      }

      Future.delayed(const Duration(seconds: 3), () {
        FeatureRemoteLogger.addLogListener((event) {
          googleServiceImpl.writeLog(level: event.level, message: event.message, labels: event.labels);
          betterstackServiceImpl.writeLog(level: event.level, message: event.message, labels: event.labels);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Remote Logging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Remote Logging Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FeatureModel> features = [
    FeatureModel(
      title: 'Log something',
      desc: 'Log something',
      key: 'LOG_SOMETHING',
    ),
    FeatureModel(
      title: 'Google Cloud Add Default Label',
      desc: 'Google Cloud Add Default Label',
      key: 'GOOGLE_CLOUD_ADD_DEFAULT_LABEL',
    ),
    FeatureModel(
      title: 'Betterstack Add Default Label',
      desc: 'Betterstack Add Default Label',
      key: 'BETTERSTACK_ADD_DEFAULT_LABEL',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 5), () {
        FeatureRemoteLogger().log(Level.info, "start app");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Logger')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: features.length,
        itemBuilder: (_, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () async {
              switch (feature.key) {
                case "LOG_SOMETHING":
                  FeatureRemoteLogger().log(
                    Level.info,
                    "fadlurahmanfdev log something",
                  );
                  break;
                case "GOOGLE_CLOUD_ADD_DEFAULT_LABEL":
                  googleServiceImpl.addLabels(labels: {
                    'platform': Platform.operatingSystem,
                  });
                  break;
                case "BETTERSTACK_ADD_DEFAULT_LABEL":
                  betterstackServiceImpl.addLabels(labels: {
                    'platform': Platform.operatingSystem,
                  });
                  break;
              }
            },
            child: ItemFeatureWidget(feature: feature),
          );
        },
      ),
    );
  }
}
