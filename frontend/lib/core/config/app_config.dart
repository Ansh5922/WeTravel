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
    return const AppConfig(
      apiBaseUrl: 'http://localhost:3000',
      aiBaseUrl: 'http://localhost:8000',
      wsBaseUrl: 'ws://localhost:3000/ws',
    );
  }
}
