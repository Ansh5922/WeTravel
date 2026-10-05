import '../../domain/entities/preferences_entity.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_remote_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDataSource remoteDataSource;

  PreferencesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PreferencesEntity> getPreferences() {
    return remoteDataSource.getPreferences();
  }

  @override
  Future<({PreferencesEntity preferences, String message})> updatePreferences({
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  }) async {
    final result = await remoteDataSource.updatePreferences(
      travelStyle: travelStyle,
      dietaryPreference: dietaryPreference,
      budget: budget,
      budgetTier: budgetTier,
      pacePreference: pacePreference,
      rawPreferenceNotes: rawPreferenceNotes,
    );
    return (preferences: result.preferences, message: result.message);
  }
}
