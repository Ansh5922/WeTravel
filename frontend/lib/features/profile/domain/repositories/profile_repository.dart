import '../entities/profile_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Repository interface contract for Profile management.
abstract class ProfileRepository {
  Future<({ProfileEntity profile, UserEntity? user})> getProfile(String token);

  Future<({ProfileEntity profile, UserEntity? user, String message})> updateProfile({
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
  });

  Future<void> deleteAccount(String token);
}
