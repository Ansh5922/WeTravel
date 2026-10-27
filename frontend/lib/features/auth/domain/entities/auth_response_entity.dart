import 'user_entity.dart';

class AuthResponseEntity {
  final UserEntity user;
  final String? token;
  final bool isFirstTimeUser;

  const AuthResponseEntity({
    required this.user,
    this.token,
    this.isFirstTimeUser = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponseEntity &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          token == other.token &&
          isFirstTimeUser == other.isFirstTimeUser;

  @override
  int get hashCode => user.hashCode ^ token.hashCode ^ isFirstTimeUser.hashCode;

  @override
  String toString() =>
      'AuthResponseEntity(user: $user, token: $token, isFirstTimeUser: $isFirstTimeUser)';
}
