import '../entities/preferences_entity.dart';
import '../repositories/preferences_repository.dart';

class GetPreferencesUseCase {
  final PreferencesRepository repository;

  GetPreferencesUseCase(this.repository);

  Future<PreferencesEntity> call() {
    return repository.getPreferences();
  }
}
