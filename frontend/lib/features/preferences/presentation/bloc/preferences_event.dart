import 'package:equatable/equatable.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];
}

class PreferencesFetchRequested extends PreferencesEvent {}

class PreferencesUpdateRequested extends PreferencesEvent {
  final String? travelStyle;
  final String? dietaryPreference;
  final double? budget;
  final String? budgetTier;
  final String? pacePreference;
  final String? rawPreferenceNotes;

  const PreferencesUpdateRequested({
    this.travelStyle,
    this.dietaryPreference,
    this.budget,
    this.budgetTier,
    this.pacePreference,
    this.rawPreferenceNotes,
  });

  @override
  List<Object?> get props => [
        travelStyle,
        dietaryPreference,
        budget,
        budgetTier,
        pacePreference,
        rawPreferenceNotes,
      ];
}
