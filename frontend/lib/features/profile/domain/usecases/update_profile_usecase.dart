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
    String? username,
    String? phone,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    Map<String, dynamic>? healthConstraints,
    Map<String, dynamic>? climateSensitivities,
    String? rawPreferenceNotes,
  }) async {
    return await repository.updateProfile(
      token: token,
      fullName: fullName,
      username: username,
      phone: phone,
      travelStyle: travelStyle,
      dietaryPreference: dietaryPreference,
      budget: budget,
      budgetTier: budgetTier,
      pacePreference: pacePreference,
      healthConstraints: healthConstraints,
      climateSensitivities: climateSensitivities,
      rawPreferenceNotes: rawPreferenceNotes,
    );
  }
}
