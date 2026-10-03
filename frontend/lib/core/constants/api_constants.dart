class ApiConstants {
  static const String backendBaseUrl = 'http://localhost:3000';
  static const String aiBaseUrl = 'http://localhost:8000';
  static const String wsBaseUrl = 'ws://localhost:3000/ws';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String signup = '/api/auth/signup';
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
