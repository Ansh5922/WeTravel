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

  Future<AuthResponseEntity> googleLogin({
    required String idToken,
  });

  Future<UserEntity> getCurrentUser(String token);

  Future<String> forgotPassword({required String email});
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}

