import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Target environment for the API and WebSocket connections.
enum ApiEnvironment {
  /// Remote Oracle Cloud VM deployment (for shared APK builds with teammates & remote testing)
  oracleCloud,

  /// Local development on PC routed to physical phone via USB (`adb reverse tcp:3000 tcp:3000`)
  localUsb,

  /// Tunneling services (ngrok, localtunnel, etc.)
  tunnel,
}

class ApiConstants {
  /// Toggle this to switch default mode without command line arguments:
  /// - [ApiEnvironment.oracleCloud]: for sharing APK with teammates (connects over internet)
  /// - [ApiEnvironment.localUsb]: for local testing on USB-connected phone with local backend
  static const ApiEnvironment defaultEnvironment = ApiEnvironment.oracleCloud;

  /// Optional command-line override via `--dart-define=API_ENV=oracle` or `--dart-define=API_ENV=usb`
  static const String _envOverride = String.fromEnvironment('API_ENV');

  static ApiEnvironment get activeEnvironment {
    final env = _envOverride.toLowerCase();
    if (env == 'usb' || env == 'local') return ApiEnvironment.localUsb;
    if (env == 'tunnel') return ApiEnvironment.tunnel;
    if (env == 'oracle' || env == 'oraclecloud') return ApiEnvironment.oracleCloud;
    return defaultEnvironment;
  }

  /// Oracle Cloud VM Domain or Public IP.
  /// Defaults to live verified HTTPS domain 'wetravel-server.duckdns.org' (IP: 130.210.35.133).
  /// Can be overridden via `--dart-define=ORACLE_HOST=...`.
  static const String oracleHost = String.fromEnvironment(
    'ORACLE_HOST',
    defaultValue: 'wetravel-server.duckdns.org',
  );

  /// Optional override for the entire backend base URL via `--dart-define=BACKEND_URL=...`
  static const String _customBackendUrl = String.fromEnvironment('BACKEND_URL');

  static const String _tunnelHost = 'social-donuts-crash.loca.lt';

  static String get _host {
    if (kIsWeb) return 'localhost';
    switch (activeEnvironment) {
      case ApiEnvironment.oracleCloud:
        return oracleHost;
      case ApiEnvironment.localUsb:
        if (Platform.isAndroid) return '127.0.0.1';
        return 'localhost';
      case ApiEnvironment.tunnel:
        return _tunnelHost;
    }
  }

  /// Backend REST API base URL
  /// - Oracle Cloud: Uses secure HTTPS domain 'https://wetravel-server.duckdns.org'
  /// - Local USB: Uses 'http://127.0.0.1:3000' via `adb reverse`
  static String get backendBaseUrl {
    if (_customBackendUrl.isNotEmpty) return _customBackendUrl;
    switch (activeEnvironment) {
      case ApiEnvironment.tunnel:
        return 'https://$_tunnelHost';
      case ApiEnvironment.oracleCloud:
        // If domain has https already or is duckdns, route through HTTPS without port 3000 (Caddy reverse proxy)
        if (oracleHost.contains('duckdns.org') || oracleHost.startsWith('https://')) {
          final domain = oracleHost.replaceAll('https://', '').replaceAll('http://', '');
          return 'https://$domain';
        }
        // Direct IP address fallback
        return 'http://$oracleHost:3000';
      case ApiEnvironment.localUsb:
        return 'http://$_host:3000';
    }
  }

  /// AI microservice base URL (FastAPI on port 8000)
  static String get aiBaseUrl {
    switch (activeEnvironment) {
      case ApiEnvironment.tunnel:
        return 'https://$_tunnelHost';
      case ApiEnvironment.oracleCloud:
        final domain = oracleHost.replaceAll('https://', '').replaceAll('http://', '');
        return 'http://$domain:8000';
      case ApiEnvironment.localUsb:
        return 'http://$_host:8000';
    }
  }

  /// WebSocket base URL for real-time chat & live polls
  /// - Oracle Cloud: Uses secure WSS 'wss://wetravel-server.duckdns.org/ws'
  /// - Local USB: Uses 'ws://127.0.0.1:3000/ws' via `adb reverse`
  static String get wsBaseUrl {
    switch (activeEnvironment) {
      case ApiEnvironment.tunnel:
        return 'wss://$_tunnelHost/ws';
      case ApiEnvironment.oracleCloud:
        if (oracleHost.contains('duckdns.org') || oracleHost.startsWith('wss://') || oracleHost.startsWith('https://')) {
          final domain = oracleHost.replaceAll('wss://', '').replaceAll('https://', '').replaceAll('http://', '');
          return 'wss://$domain/ws';
        }
        return 'ws://$oracleHost:3000/ws';
      case ApiEnvironment.localUsb:
        return 'ws://$_host:3000/ws';
    }
  }

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String signup = '/api/auth/signup';
  static const String googleSignIn = '/api/auth/google';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String me = '/api/auth/me';

  // User endpoints
  static const String userProfile = '/api/users/profile';
  static const String deleteAccount = '/api/users/account';

  // Friends endpoints
  static const String friendRequest = '/api/friends/request';
  static const String friendRequests = '/api/friends/requests';
  static const String friends = '/api/friends';

  // Trips endpoints
  static const String trips = '/api/trips';
  static const String myInvites = '/api/trips/invites/me';

  // Itinerary endpoints
  static String tripItineraries(String tripId) => '/api/trips/$tripId/itineraries';
  static String generateItinerary(String tripId) => '/api/trips/$tripId/itinerary/generate';

  // Expense endpoints
  static String tripExpenses(String tripId) => '/api/trips/$tripId/expenses';
  static String tripLedger(String tripId) => '/api/trips/$tripId/expenses/ledger';
  static String tripSettlements(String tripId) => '/api/trips/$tripId/expenses/settlements';

  // Chat & Poll endpoints
  static String tripChatMessages(String tripId) => '/api/trips/$tripId/chat/messages';
  static String tripChatImageKitAuth(String tripId) => '/api/trips/$tripId/chat/imagekit-auth';
  static String tripChatImage(String tripId) => '/api/trips/$tripId/chat/image';
  static String tripPolls(String tripId) => '/api/trips/$tripId/chat/polls';

  // Memory endpoints
  static String tripMemories(String tripId) => '/api/trips/$tripId/memories';
  static String tripMemoriesHighlights(String tripId) => '/api/trips/$tripId/memories/highlights';
}

