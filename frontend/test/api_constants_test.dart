import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/config/app_config.dart';

void main() {
  group('ApiConstants Cloud & USB Configuration Tests', () {
    test('Default activeEnvironment is oracleCloud', () {
      expect(ApiConstants.activeEnvironment, equals(ApiEnvironment.oracleCloud));
    });

    test('Oracle Cloud environment produces HTTPS and WSS endpoints', () {
      expect(ApiConstants.backendBaseUrl, equals('https://wetravel-server.duckdns.org'));
      expect(ApiConstants.wsBaseUrl, equals('wss://wetravel-server.duckdns.org/ws'));
      expect(ApiConstants.aiBaseUrl, equals('http://wetravel-server.duckdns.org:8000'));
    });

    test('Auth and Trip endpoints are properly formatted', () {
      expect(ApiConstants.login, equals('/api/auth/login'));
      expect(ApiConstants.signup, equals('/api/auth/signup'));
      expect(ApiConstants.trips, equals('/api/trips'));
      expect(ApiConstants.tripItineraries('trip123'), equals('/api/trips/trip123/itineraries'));
      expect(ApiConstants.tripExpenses('trip123'), equals('/api/trips/trip123/expenses'));
      expect(ApiConstants.tripChatMessages('trip123'), equals('/api/trips/trip123/chat/messages'));
      expect(ApiConstants.tripPolls('trip123'), equals('/api/trips/trip123/chat/polls'));
    });

    test('AppConfig cloud factory returns production endpoints', () {
      final config = AppConfig.cloud();
      expect(config.apiBaseUrl, equals('https://wetravel-server.duckdns.org'));
      expect(config.wsBaseUrl, equals('wss://wetravel-server.duckdns.org/ws'));
      expect(config.aiBaseUrl, equals('http://wetravel-server.duckdns.org:8000'));
    });
  });
}
