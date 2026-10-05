import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Sealed base state hierarchy for Profile BLoC states.
sealed class ProfileState extends Equatable {
  const ProfileState();

  bool get isInitial => this is ProfileInitialState;
  bool get isLoading => this is ProfileLoadingState;
  bool get isLoaded => this is ProfileLoadedState;
  bool get isError => this is ProfileErrorState;

  ProfileEntity? get profile =>
      this is ProfileLoadedState ? (this as ProfileLoadedState).profile : null;
  UserEntity? get updatedUser =>
      this is ProfileLoadedState ? (this as ProfileLoadedState).user : null;
  String? get successMessage =>
      this is ProfileLoadedState ? (this as ProfileLoadedState).message : null;
  String? get errorMessage =>
      this is ProfileErrorState ? (this as ProfileErrorState).message : null;

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

/// Loading state emitted during HTTP operations.
class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

/// Loaded state containing current profile, updated user entity, and optional status message.
class ProfileLoadedState extends ProfileState {
  @override
  final ProfileEntity profile;
  final UserEntity? user;
  final String? message;

  const ProfileLoadedState({
    required this.profile,
    this.user,
    this.message,
  });

  ProfileLoadedState copyWith({
    ProfileEntity? profile,
    UserEntity? user,
    String? message,
  }) {
    return ProfileLoadedState(
      profile: profile ?? this.profile,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [profile, user, message];
}

/// Error state emitted on network/server/validation failure.
class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
