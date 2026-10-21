import '../repositories/profile_repository.dart';

/// Clean Architecture UseCase for permanently deleting user account.
class DeleteAccountUseCase {
  final ProfileRepository repository;

  const DeleteAccountUseCase(this.repository);

  Future<void> execute(String token) async {
    return await repository.deleteAccount(token);
  }
}
