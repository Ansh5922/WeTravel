import 'package:equatable/equatable.dart';

/// Clean Architecture Domain Entity representing user travel preferences profile.
class ProfileEntity extends Equatable {
  final String? id;
  final String? userId;
  final String? travelStyle;
  final String? dietaryPreference;
  final double? budget;
  final String? budgetTier;
  final String? pacePreference;
  final String? rawPreferenceNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    this.id,
    this.userId,
    this.travelStyle,
    this.dietaryPreference,
    this.budget,
    this.budgetTier,
    this.pacePreference,
    this.rawPreferenceNotes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        travelStyle,
        dietaryPreference,
        budget,
        budgetTier,
        pacePreference,
        rawPreferenceNotes,
        createdAt,
        updatedAt,
      ];
}
