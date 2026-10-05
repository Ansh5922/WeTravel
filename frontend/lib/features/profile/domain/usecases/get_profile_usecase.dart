import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Clean Architecture UseCase for fetching user travel profile.
class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  Future<ProfileEntity> execute(String token) async {
    return await repository.getProfile(token);
  }
}
