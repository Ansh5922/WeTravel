import 'package:equatable/equatable.dart';

/// Sealed base event hierarchy for Profile BLoC events.
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to fetch the user's travel preferences profile.
class ProfileFetchRequested extends ProfileEvent {
  final String token;

  const ProfileFetchRequested({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Event triggered to update profile & travel preference attributes.
class ProfileUpdateRequested extends ProfileEvent {
  final String token;
  final String? fullName;
  final String? username;
  final String? phone;
  final String? travelStyle;
  final String? dietaryPreference;
  final double? budget;
  final String? budgetTier;
  final String? pacePreference;
  final Map<String, dynamic>? healthConstraints;
  final Map<String, dynamic>? climateSensitivities;
  final String? rawPreferenceNotes;

  const ProfileUpdateRequested({
    required this.token,
    this.fullName,
    this.username,
    this.phone,
    this.travelStyle,
    this.dietaryPreference,
    this.budget,
    this.budgetTier,
    this.pacePreference,
    this.healthConstraints,
    this.climateSensitivities,
    this.rawPreferenceNotes,
  });

  @override
  List<Object?> get props => [
        token,
        fullName,
        username,
        phone,
        travelStyle,
        dietaryPreference,
        budget,
        budgetTier,
        pacePreference,
        healthConstraints,
        climateSensitivities,
        rawPreferenceNotes,
      ];
}

/// Event triggered to permanently delete user account.
class ProfileDeleteAccountRequested extends ProfileEvent {
  final String token;

  const ProfileDeleteAccountRequested({required this.token});

  @override
  List<Object?> get props => [token];
}
