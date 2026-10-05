import '../entities/profile_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Repository interface contract for Profile management.
abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String token);

  Future<({ProfileEntity profile, UserEntity? user, String message})> updateProfile({
    required String token,
    String? fullName,
    String? phone,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  });
}
