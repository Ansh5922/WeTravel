import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../../core/error/failures.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Clean Architecture Business Logic Component (BLoC) for Profile operations.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const ProfileInitialState()) {
    on<ProfileFetchRequested>(_onProfileFetchRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  /// Handles profile fetching request.
  Future<void> _onProfileFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('[PROFILE_BLOC] 👤 Event: ProfileFetchRequested -> Fetching profile from GET /api/users/profile...');
    emit(const ProfileLoadingState());

    try {
      final profile = await _getProfileUseCase.execute(event.token);
      debugPrint('[PROFILE_BLOC] ✅ Profile Loaded successfully! Style: ${profile.travelStyle ?? 'Default'}, Budget: ${profile.budget ?? profile.budgetTier ?? 'N/A'}');
      emit(ProfileLoadedState(profile: profile));
    } on Failure catch (e) {
      debugPrint('[PROFILE_BLOC] ❌ Profile Fetch Failure: ${e.message}');
      emit(ProfileErrorState(e.message));
    } catch (e) {
      debugPrint('[PROFILE_BLOC] 💥 Unexpected Profile Fetch Error: $e');
      emit(ProfileErrorState(e.toString()));
    }
  }

  /// Handles profile update request.
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('[PROFILE_BLOC] ✏️ Event: ProfileUpdateRequested -> Updating attributes: Style=${event.travelStyle}, Dietary=${event.dietaryPreference}, Budget=${event.budget}');
    emit(const ProfileLoadingState());

    try {
      final result = await _updateProfileUseCase.execute(
        token: event.token,
        fullName: event.fullName,
        phone: event.phone,
        travelStyle: event.travelStyle,
        dietaryPreference: event.dietaryPreference,
        budget: event.budget,
        budgetTier: event.budgetTier,
        pacePreference: event.pacePreference,
        rawPreferenceNotes: event.rawPreferenceNotes,
      );

      debugPrint('[PROFILE_BLOC] ✅ Profile Updated! Message: ${result.message}');
      emit(
        ProfileLoadedState(
          profile: result.profile,
          user: result.user,
          message: result.message,
        ),
      );
    } on Failure catch (e) {
      debugPrint('[PROFILE_BLOC] ❌ Profile Update Failure: ${e.message}');
      emit(ProfileErrorState(e.message));
    } catch (e) {
      debugPrint('[PROFILE_BLOC] 💥 Unexpected Profile Update Error: $e');
      emit(ProfileErrorState(e.toString()));
    }
  }
}
