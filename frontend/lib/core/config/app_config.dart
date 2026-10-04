import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  final String apiBaseUrl;
  final String aiBaseUrl;
  final String wsBaseUrl;

  const AppConfig({
    required this.apiBaseUrl,
    required this.aiBaseUrl,
    required this.wsBaseUrl,
  });

  factory AppConfig.development() {
    final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
    return AppConfig(
      apiBaseUrl: 'http://$host:3000',
      aiBaseUrl: 'http://$host:8000',
      wsBaseUrl: 'ws://$host:3000/ws',
    );
  }
}
