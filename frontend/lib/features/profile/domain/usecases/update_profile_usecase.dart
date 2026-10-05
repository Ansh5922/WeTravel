import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Clean Architecture UseCase for updating user profile and preferences.
class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<({ProfileEntity profile, UserEntity? user, String message})> execute({
    required String token,
    String? fullName,
    String? phone,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  }) async {
    return await repository.updateProfile(
      token: token,
      fullName: fullName,
      phone: phone,
      travelStyle: travelStyle,
      dietaryPreference: dietaryPreference,
      budget: budget,
      budgetTier: budgetTier,
      pacePreference: pacePreference,
      rawPreferenceNotes: rawPreferenceNotes,
    );
  }
}
