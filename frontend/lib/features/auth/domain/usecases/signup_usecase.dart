// Clean Architecture UseCase: Executes user registration.
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

/// Single-responsibility use case for registering new users.
class SignupUseCase {
  final AuthRepository _repository;

  const SignupUseCase(this._repository);

  Future<AuthResponseEntity> execute({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? phone,
  }) async {
    return await _repository.signup(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
      phone: phone,
    );
  }
}
