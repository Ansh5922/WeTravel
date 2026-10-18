// Clean Architecture UseCase: Dispatches password reset request.
import '../repositories/auth_repository.dart';

/// Single-responsibility use case for requesting a password reset email.
class ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  Future<String> execute(String email) async {
    return await _repository.forgotPassword(email: email);
  }
}
