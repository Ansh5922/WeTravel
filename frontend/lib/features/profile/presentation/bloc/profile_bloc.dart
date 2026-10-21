import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/error/failures.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Clean Architecture Business Logic Component (BLoC) for Profile operations.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        super(const ProfileInitialState()) {
    on<ProfileFetchRequested>(_onProfileFetchRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileDeleteAccountRequested>(_onProfileDeleteAccountRequested);
  }

  /// Handles profile fetching request.
  Future<void> _onProfileFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('[PROFILE_BLOC] 👤 Event: ProfileFetchRequested -> Fetching profile from GET /api/users/profile...');
    emit(const ProfileLoadingState());

    try {
      final result = await _getProfileUseCase.execute(event.token);
      debugPrint('[PROFILE_BLOC] ✅ Profile Loaded successfully! Style: ${result.profile.travelStyle ?? 'Default'}, User: ${result.user?.fullName ?? result.user?.username ?? 'N/A'}');
      emit(ProfileLoadedState(profile: result.profile, user: result.user));
    } on Failure catch (e) {
      debugPrint('[PROFILE_BLOC] ❌ Profile Fetch Failure: ${e.message}');
      emit(ProfileErrorState(e.message));
    } catch (e) {
      debugPrint('[PROFILE_BLOC] 💥 Unexpected Profile Fetch Error: $e');
      emit(ProfileErrorState(e.toString()));
    }
  }

  /// Handles profile update request with immediate optimistic update for zero lag.
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('[PROFILE_BLOC] ✏️ Event: ProfileUpdateRequested -> Updating attributes');

    // 1. Lag-free optimistic state update: immediately reflect changes in UI
    final currentProfile = state.profile ?? const ProfileEntity();
    final currentUser = state.updatedUser;

    final optimisticUser = currentUser != null
        ? currentUser.copyWith(
            fullName: event.fullName ?? currentUser.fullName,
            username: event.username ?? currentUser.username,
            phone: event.phone ?? currentUser.phone,
          )
        : (event.fullName != null || event.username != null || event.phone != null)
            ? UserEntity(
                id: '',
                email: '',
                fullName: event.fullName,
                username: event.username,
                phone: event.phone,
              )
            : null;

    final optimisticProfile = currentProfile.copyWith(
      travelStyle: event.travelStyle ?? currentProfile.travelStyle,
      dietaryPreference: event.dietaryPreference ?? currentProfile.dietaryPreference,
      budget: event.budget ?? currentProfile.budget,
      budgetTier: event.budgetTier ?? currentProfile.budgetTier,
      pacePreference: event.pacePreference ?? currentProfile.pacePreference,
      healthConstraints: event.healthConstraints ?? currentProfile.healthConstraints,
      climateSensitivities: event.climateSensitivities ?? currentProfile.climateSensitivities,
      rawPreferenceNotes: event.rawPreferenceNotes ?? currentProfile.rawPreferenceNotes,
    );

    emit(ProfileLoadedState(
      profile: optimisticProfile,
      user: optimisticUser ?? currentUser,
    ));

    // 2. Persist asynchronously in backend
    try {
      final result = await _updateProfileUseCase.execute(
        token: event.token,
        fullName: event.fullName,
        username: event.username,
        phone: event.phone,
        travelStyle: event.travelStyle,
        dietaryPreference: event.dietaryPreference,
        budget: event.budget,
        budgetTier: event.budgetTier,
        pacePreference: event.pacePreference,
        healthConstraints: event.healthConstraints,
        climateSensitivities: event.climateSensitivities,
        rawPreferenceNotes: event.rawPreferenceNotes,
      );

      debugPrint('[PROFILE_BLOC] ✅ Profile Updated! Message: ${result.message}');
      emit(
        ProfileLoadedState(
          profile: result.profile,
          user: result.user ?? optimisticUser ?? currentUser,
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

  /// Handles account deletion request.
  Future<void> _onProfileDeleteAccountRequested(
    ProfileDeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('[PROFILE_BLOC] ⚠️ Event: ProfileDeleteAccountRequested');
    emit(const ProfileLoadingState());

    try {
      await _deleteAccountUseCase.execute(event.token);
      debugPrint('[PROFILE_BLOC] ✅ Account deleted successfully');
      emit(const ProfileAccountDeletedState());
    } on Failure catch (e) {
      debugPrint('[PROFILE_BLOC] ❌ Profile Delete Account Failure: ${e.message}');
      emit(ProfileErrorState(e.message));
    } catch (e) {
      debugPrint('[PROFILE_BLOC] 💥 Unexpected Delete Account Error: $e');
      emit(ProfileErrorState(e.toString()));
    }
  }
}
