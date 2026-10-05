import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/get_preferences_usecase.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import 'preferences_event.dart';
import 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetPreferencesUseCase getPreferencesUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;

  PreferencesBloc({
    required this.getPreferencesUseCase,
    required this.updatePreferencesUseCase,
  }) : super(PreferencesInitialState()) {
    on<PreferencesFetchRequested>(_onPreferencesFetchRequested);
    on<PreferencesUpdateRequested>(_onPreferencesUpdateRequested);
  }

  Future<void> _onPreferencesFetchRequested(
    PreferencesFetchRequested event,
    Emitter<PreferencesState> emit,
  ) async {
    debugPrint('[PREFERENCES_BLOC] ⚙️ Event: PreferencesFetchRequested');
    emit(PreferencesLoadingState());

    try {
      final preferences = await getPreferencesUseCase();
      debugPrint('[PREFERENCES_BLOC] ✅ Fetch Success! Style: ${preferences.travelStyle}, Dietary: ${preferences.dietaryPreference}');
      emit(PreferencesLoadedState(preferences: preferences));
    } on ServerException catch (e) {
      debugPrint('[PREFERENCES_BLOC] ❌ Fetch Error: ${e.message}');
      emit(PreferencesErrorState(message: e.message));
    } catch (e) {
      debugPrint('[PREFERENCES_BLOC] 💥 Unexpected Fetch Error: $e');
      emit(PreferencesErrorState(message: 'Failed to fetch travel preferences: ${e.toString()}'));
    }
  }

  Future<void> _onPreferencesUpdateRequested(
    PreferencesUpdateRequested event,
    Emitter<PreferencesState> emit,
  ) async {
    debugPrint('[PREFERENCES_BLOC] ✏️ Event: PreferencesUpdateRequested -> Style=${event.travelStyle}, Dietary=${event.dietaryPreference}, Budget=${event.budget}');
    emit(PreferencesLoadingState());

    try {
      final result = await updatePreferencesUseCase(
        travelStyle: event.travelStyle,
        dietaryPreference: event.dietaryPreference,
        budget: event.budget,
        budgetTier: event.budgetTier,
        pacePreference: event.pacePreference,
        rawPreferenceNotes: event.rawPreferenceNotes,
      );

      debugPrint('[PREFERENCES_BLOC] ✅ Update Success: ${result.message}');
      emit(PreferencesLoadedState(
        preferences: result.preferences,
        successMessage: result.message,
      ));
    } on ServerException catch (e) {
      debugPrint('[PREFERENCES_BLOC] ❌ Update Error: ${e.message}');
      emit(PreferencesErrorState(message: e.message));
    } catch (e) {
      debugPrint('[PREFERENCES_BLOC] 💥 Unexpected Update Error: $e');
      emit(PreferencesErrorState(message: 'Failed to update travel preferences: ${e.toString()}'));
    }
  }
}
