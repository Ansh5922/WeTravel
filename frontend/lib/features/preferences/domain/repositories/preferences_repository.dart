import '../entities/preferences_entity.dart';

abstract class PreferencesRepository {
  Future<PreferencesEntity> getPreferences();
  Future<({PreferencesEntity preferences, String message})> updatePreferences({
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  });
}
