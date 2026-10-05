import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/preferences/data/models/preferences_model.dart';
import 'package:frontend/features/preferences/domain/entities/preferences_entity.dart';
import 'package:frontend/features/preferences/domain/repositories/preferences_repository.dart';
import 'package:frontend/features/preferences/domain/usecases/get_preferences_usecase.dart';
import 'package:frontend/features/preferences/domain/usecases/update_preferences_usecase.dart';
import 'package:frontend/features/preferences/presentation/bloc/preferences_bloc.dart';
import 'package:frontend/features/preferences/presentation/bloc/preferences_event.dart';
import 'package:frontend/features/preferences/presentation/bloc/preferences_state.dart';

class FakePreferencesRepository implements PreferencesRepository {
  PreferencesEntity? prefsToReturn;
  Exception? exceptionToThrow;

  @override
  Future<PreferencesEntity> getPreferences() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return prefsToReturn ??
        const PreferencesEntity(
          id: 'pref_1',
          travelStyle: 'Relaxed',
          dietaryPreference: 'Vegetarian',
          budget: 300.0,
        );
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
    if (exceptionToThrow != null) throw exceptionToThrow!;
    final updated = PreferencesEntity(
      id: 'pref_1',
      travelStyle: travelStyle ?? 'Relaxed',
      dietaryPreference: dietaryPreference ?? 'Vegetarian',
      budget: budget ?? 300.0,
      budgetTier: budgetTier,
      pacePreference: pacePreference,
      rawPreferenceNotes: rawPreferenceNotes,
    );
    return (preferences: updated, message: 'Preferences updated successfully.');
  }
}

void main() {
  group('PreferencesModel JSON Parsing', () {
    test('fromJson correctly parses user preferences JSON', () {
      final json = {
        'status': 'success',
        'data': {
          'profile': {
            'id': 'prof_999',
            'travelStyle': 'Adventure',
            'dietaryPreference': 'Halal',
            'budget': 450.0,
            'pacePreference': 'Fast',
          }
        }
      };

      final model = PreferencesModel.fromJson(json);

      expect(model.id, 'prof_999');
      expect(model.travelStyle, 'Adventure');
      expect(model.dietaryPreference, 'Halal');
      expect(model.budget, 450.0);
      expect(model.pacePreference, 'Fast');
    });
  });

  group('PreferencesBloc Unit Tests', () {
    late FakePreferencesRepository fakeRepository;
    late PreferencesBloc preferencesBloc;

    setUp(() {
      fakeRepository = FakePreferencesRepository();
      preferencesBloc = PreferencesBloc(
        getPreferencesUseCase: GetPreferencesUseCase(fakeRepository),
        updatePreferencesUseCase: UpdatePreferencesUseCase(fakeRepository),
      );
    });

    tearDown(() {
      preferencesBloc.close();
    });

    test('initial state is PreferencesInitialState', () {
      expect(preferencesBloc.state, isA<PreferencesInitialState>());
    });

    test('PreferencesFetchRequested success emits PreferencesLoadedState', () async {
      preferencesBloc.add(PreferencesFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(preferencesBloc.state, isA<PreferencesLoadedState>());
      final loaded = preferencesBloc.state as PreferencesLoadedState;
      expect(loaded.preferences.travelStyle, 'Relaxed');
    });

    test('PreferencesUpdateRequested emits updated state', () async {
      preferencesBloc.add(const PreferencesUpdateRequested(
        travelStyle: 'Luxury',
        dietaryPreference: 'Vegan',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(preferencesBloc.state, isA<PreferencesLoadedState>());
      final loaded = preferencesBloc.state as PreferencesLoadedState;
      expect(loaded.preferences.travelStyle, 'Luxury');
      expect(loaded.preferences.dietaryPreference, 'Vegan');
      expect(loaded.successMessage, 'Preferences updated successfully.');
    });
  });
}
