// Clean Architecture UseCase: Executes user email & password login.
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

/// Single-responsibility use case for authenticating users via email & password.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<AuthResponseEntity> execute({
    required String email,
    required String password,
  }) async {
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}
