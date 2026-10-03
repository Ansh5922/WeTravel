import 'user_entity.dart';

class AuthResponseEntity {
  final UserEntity user;
  final String? token;

  const AuthResponseEntity({
    required this.user,
    this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponseEntity &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          token == other.token;

  @override
  int get hashCode => user.hashCode ^ token.hashCode;

  @override
  String toString() => 'AuthResponseEntity(user: $user, token: $token)';
}
