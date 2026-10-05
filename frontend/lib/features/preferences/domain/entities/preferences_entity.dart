import 'package:equatable/equatable.dart';

class PreferencesEntity extends Equatable {
  final String? id;
  final String? travelStyle;
  final String? dietaryPreference;
  final double? budget;
  final String? budgetTier;
  final String? pacePreference;
  final String? rawPreferenceNotes;

  const PreferencesEntity({
    this.id,
    this.travelStyle,
    this.dietaryPreference,
    this.budget,
    this.budgetTier,
    this.pacePreference,
    this.rawPreferenceNotes,
  });

  PreferencesEntity copyWith({
    String? id,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  }) {
    return PreferencesEntity(
      id: id ?? this.id,
      travelStyle: travelStyle ?? this.travelStyle,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      budget: budget ?? this.budget,
      budgetTier: budgetTier ?? this.budgetTier,
      pacePreference: pacePreference ?? this.pacePreference,
      rawPreferenceNotes: rawPreferenceNotes ?? this.rawPreferenceNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        travelStyle,
        dietaryPreference,
        budget,
        budgetTier,
        pacePreference,
        rawPreferenceNotes,
      ];
}
