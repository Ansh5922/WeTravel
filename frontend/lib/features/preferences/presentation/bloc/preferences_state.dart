import 'package:equatable/equatable.dart';
import '../../domain/entities/preferences_entity.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object?> get props => [];
}

class PreferencesInitialState extends PreferencesState {}

class PreferencesLoadingState extends PreferencesState {}

class PreferencesLoadedState extends PreferencesState {
  final PreferencesEntity preferences;
  final String? successMessage;

  const PreferencesLoadedState({
    required this.preferences,
    this.successMessage,
  });

  @override
  List<Object?> get props => [preferences, successMessage];
}

class PreferencesErrorState extends PreferencesState {
  final String message;

  const PreferencesErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
