
class AppConfig {
  final String apiBaseUrl;
  final String aiBaseUrl;
  final String wsBaseUrl;

  const AppConfig({
    required this.apiBaseUrl,
    required this.aiBaseUrl,
    required this.wsBaseUrl,
  });

  // Cloud Server URLs (Oracle VM / Caddy SSL):
  static const String defaultBackendBaseUrl = 'https://wetravel-server.duckdns.org';
  static const String defaultAiBaseUrl      = 'http://wetravel-server.duckdns.org:8000';
  static const String defaultWsBaseUrl      = 'wss://wetravel-server.duckdns.org/ws';

  factory AppConfig.cloud() {
    return const AppConfig(
      apiBaseUrl: defaultBackendBaseUrl,
      aiBaseUrl: defaultAiBaseUrl,
      wsBaseUrl: defaultWsBaseUrl,
    );
  }

  factory AppConfig.development() {
    return AppConfig.cloud();
  }
}
