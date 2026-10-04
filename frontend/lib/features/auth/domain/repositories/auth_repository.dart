import '../entities/user_entity.dart';
import '../entities/auth_response_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  });

  Future<AuthResponseEntity> signup({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? phone,
  });

  Future<UserEntity> getCurrentUser(String token);
}
