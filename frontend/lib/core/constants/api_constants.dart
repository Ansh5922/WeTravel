import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '127.0.0.1';
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
}
