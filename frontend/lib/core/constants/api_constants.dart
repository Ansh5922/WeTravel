import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '127.0.0.1'; // Works with 'adb reverse' on physical devices and emulators
    return 'localhost';
  }

  static String get backendBaseUrl => 'http://$_host:3000';
  static String get aiBaseUrl => 'http://$_host:8000';
  static String get wsBaseUrl => 'ws://$_host:3000/ws';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String signup = '/api/auth/signup';
  static const String googleSignIn = '/api/auth/google';
  static const String me = '/api/auth/me';

  // User endpoints
  static const String userProfile = '/api/users/profile';

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

