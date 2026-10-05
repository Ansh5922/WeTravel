// Clean Architecture UseCase: Executes Google OAuth 2.0 authentication.
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

/// Single-responsibility use case for authenticating users via Google OAuth 2.0.
class GoogleSignInUseCase {
  final AuthRepository _repository;

  const GoogleSignInUseCase(this._repository);

  Future<AuthResponseEntity> execute({required String idToken}) async {
    return await _repository.googleLogin(idToken: idToken);
  }
}
