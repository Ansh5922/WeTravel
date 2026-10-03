class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server exception occurred.', this.statusCode]);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException([this.message = 'Authentication exception occurred.', this.statusCode]);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache exception occurred.']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network exception occurred.']);

  @override
  String toString() => message;
}
