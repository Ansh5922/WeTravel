import '../entities/preferences_entity.dart';
import '../repositories/preferences_repository.dart';

class UpdatePreferencesUseCase {
  final PreferencesRepository repository;

  UpdatePreferencesUseCase(this.repository);

  Future<({PreferencesEntity preferences, String message})> call({
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  }) {
    return repository.updatePreferences(
      travelStyle: travelStyle,
      dietaryPreference: dietaryPreference,
      budget: budget,
      budgetTier: budgetTier,
      pacePreference: pacePreference,
      rawPreferenceNotes: rawPreferenceNotes,
    );
  }
}
