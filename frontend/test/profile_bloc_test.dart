import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';
import 'package:frontend/features/profile/domain/entities/profile_entity.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:frontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_state.dart';

class FakeProfileRepository implements ProfileRepository {
  ProfileEntity? profileToReturn;
  UserEntity? userToReturn;
  String? updateMessage;
  Failure? failureToThrow;

  int getProfileCallCount = 0;
  int updateProfileCallCount = 0;

  @override
  Future<ProfileEntity> getProfile(String token) async {
    getProfileCallCount++;
    if (failureToThrow != null) throw failureToThrow!;
    return profileToReturn ??
        const ProfileEntity(
          id: 'prof_fake_1',
          travelStyle: 'Adventure',
          dietaryPreference: 'Vegan',
          budget: 250.0,
        );
  }

  @override
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
  }) async {
    updateProfileCallCount++;
    if (failureToThrow != null) throw failureToThrow!;
    final updated = ProfileEntity(
      id: 'prof_fake_1',
      travelStyle: travelStyle ?? 'Adventure',
      dietaryPreference: dietaryPreference ?? 'Vegan',
      budget: budget ?? 250.0,
      rawPreferenceNotes: rawPreferenceNotes,
    );
    return (
      profile: profileToReturn ?? updated,
      user: userToReturn ?? const UserEntity(id: 'usr_fake', email: 'test@wetravel.test'),
      message: updateMessage ?? 'Profile updated successfully.',
    );
  }
}

void main() {
  group('ProfileModel JSON Tests', () {
    test('fromJson correctly parses nested profile object', () {
      final json = {
        'status': 'success',
        'data': {
          'profile': {
            'id': 'prof_123',
            'userId': 'usr_456',
            'travelStyle': 'Cultural & Local',
            'dietaryPreference': 'Halal',
            'budget': 180.5,
            'pacePreference': 'Relaxed',
          },
        },
      };

      final model = ProfileModel.fromJson(json);

      expect(model.id, 'prof_123');
      expect(model.userId, 'usr_456');
      expect(model.travelStyle, 'Cultural & Local');
      expect(model.dietaryPreference, 'Halal');
      expect(model.budget, 180.5);
      expect(model.pacePreference, 'Relaxed');
    });

    test('toJson outputs non-null attributes', () {
      const model = ProfileModel(
        id: 'p1',
        travelStyle: 'Luxury',
        budget: 500.0,
      );

      final json = model.toJson();
      expect(json['id'], 'p1');
      expect(json['travelStyle'], 'Luxury');
      expect(json['budget'], 500.0);
      expect(json.containsKey('dietaryPreference'), isFalse);
    });
  });

  group('ProfileBloc Unit Tests', () {
    late FakeProfileRepository fakeRepository;
    late ProfileBloc profileBloc;

    setUp(() {
      fakeRepository = FakeProfileRepository();
      profileBloc = ProfileBloc(
        getProfileUseCase: GetProfileUseCase(fakeRepository),
        updateProfileUseCase: UpdateProfileUseCase(fakeRepository),
      );
    });

    tearDown(() {
      profileBloc.close();
    });

    test('initial state is ProfileInitialState', () {
      expect(profileBloc.state, isA<ProfileInitialState>());
    });

    test('ProfileFetchRequested emits ProfileLoadingState then ProfileLoadedState', () async {
      profileBloc.add(const ProfileFetchRequested(token: 'valid_jwt'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(profileBloc.state, isA<ProfileLoadedState>());
      final loaded = profileBloc.state as ProfileLoadedState;
      expect(loaded.profile.travelStyle, 'Adventure');
      expect(fakeRepository.getProfileCallCount, 1);
    });

    test('ProfileFetchRequested failure emits ProfileErrorState', () async {
      fakeRepository.failureToThrow = const ServerFailure('Database unreachable.', 500);

      profileBloc.add(const ProfileFetchRequested(token: 'valid_jwt'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(profileBloc.state, isA<ProfileErrorState>());
      expect((profileBloc.state as ProfileErrorState).message, 'Database unreachable.');
    });

    test('ProfileUpdateRequested emits ProfileLoadedState with updated profile', () async {
      profileBloc.add(
        const ProfileUpdateRequested(
          token: 'valid_jwt',
          travelStyle: 'Relaxed',
          dietaryPreference: 'Vegetarian',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(profileBloc.state, isA<ProfileLoadedState>());
      final loaded = profileBloc.state as ProfileLoadedState;
      expect(loaded.profile.travelStyle, 'Relaxed');
      expect(loaded.profile.dietaryPreference, 'Vegetarian');
      expect(fakeRepository.updateProfileCallCount, 1);
    });
  });
}
