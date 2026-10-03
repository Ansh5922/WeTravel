abstract class Failure implements Exception {
  final String message;
  final int? statusCode;
  const Failure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.', super.statusCode]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.', super.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A cache error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}
