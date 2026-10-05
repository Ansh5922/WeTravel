// Clean Architecture UseCase: Fetches authenticated session profile.
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Single-responsibility use case for retrieving current active user profile.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<UserEntity> execute(String token) async {
    return await _repository.getCurrentUser(token);
  }
}
