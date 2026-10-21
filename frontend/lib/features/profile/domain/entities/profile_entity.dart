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
  final int? age;
  final Map<String, dynamic>? healthConstraints;
  final Map<String, dynamic>? climateSensitivities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    this.id,
    this.userId,
    this.age,
    this.travelStyle,
    this.dietaryPreference,
    this.budget,
    this.budgetTier,
    this.pacePreference,
    this.healthConstraints,
    this.climateSensitivities,
    this.rawPreferenceNotes,
    this.createdAt,
    this.updatedAt,
  });

  ProfileEntity copyWith({
    String? id,
    String? userId,
    int? age,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    Map<String, dynamic>? healthConstraints,
    Map<String, dynamic>? climateSensitivities,
    String? rawPreferenceNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      age: age ?? this.age,
      travelStyle: travelStyle ?? this.travelStyle,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      budget: budget ?? this.budget,
      budgetTier: budgetTier ?? this.budgetTier,
      pacePreference: pacePreference ?? this.pacePreference,
      healthConstraints: healthConstraints ?? this.healthConstraints,
      climateSensitivities: climateSensitivities ?? this.climateSensitivities,
      rawPreferenceNotes: rawPreferenceNotes ?? this.rawPreferenceNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        age,
        travelStyle,
        dietaryPreference,
        budget,
        budgetTier,
        pacePreference,
        healthConstraints,
        climateSensitivities,
        rawPreferenceNotes,
        createdAt,
        updatedAt,
      ];
}
