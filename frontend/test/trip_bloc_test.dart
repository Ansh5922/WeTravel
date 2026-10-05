import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/trips/data/models/trip_model.dart';
import 'package:frontend/features/trips/domain/entities/trip_entity.dart';
import 'package:frontend/features/trips/domain/repositories/trip_repository.dart';
import 'package:frontend/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:frontend/features/trips/domain/usecases/get_group_consensus_usecase.dart';
import 'package:frontend/features/trips/domain/usecases/get_my_trips_usecase.dart';
import 'package:frontend/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:frontend/features/trips/domain/usecases/invite_trip_member_usecase.dart';
import 'package:frontend/features/trips/domain/usecases/join_trip_via_token_usecase.dart';
import 'package:frontend/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:frontend/features/trips/presentation/bloc/trip_event.dart';
import 'package:frontend/features/trips/presentation/bloc/trip_state.dart';

class FakeTripRepository implements TripRepository {
  List<TripEntity>? tripsToReturn;
  TripEntity? tripToReturn;
  ({String message, String? inviteToken, String? joinUrl})? inviteToReturn;
  GroupConsensusEntity? consensusToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<TripEntity>> getMyTrips({String? status}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return tripsToReturn ??
        [
          TripEntity(
            id: 'trip_1',
            name: 'Goa Trip 2026',
            createdBy: 'usr_1',
            status: 'planning',
            tripStartDate: DateTime(2026, 11, 1),
            tripEndDate: DateTime(2026, 11, 7),
            createdAt: DateTime.now(),
            members: const [
              TripGroupMemberEntity(
                id: 'mem_1',
                userId: 'usr_1',
                role: 'admin',
                email: 'rashi@wetravel.app',
                username: 'rashi',
                fullName: 'Rashi',
              )
            ],
          ),
        ];
  }

  @override
  Future<TripEntity> getTripDetails(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return tripToReturn ??
        TripEntity(
          id: tripId,
          name: 'Manali Expedition',
          createdBy: 'usr_1',
          status: 'confirmed',
          createdAt: DateTime.now(),
          members: const [
            TripGroupMemberEntity(
              id: 'mem_1',
              userId: 'usr_1',
              role: 'admin',
              email: 'rashi@wetravel.app',
              username: 'rashi',
              fullName: 'Rashi',
            )
          ],
        );
  }

  @override
  Future<TripEntity> createTrip({
    required String name,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? coverImageUrl,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return TripEntity(
      id: 'trip_new_1',
      name: name,
      createdBy: 'usr_1',
      status: 'planning',
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      coverImageUrl: coverImageUrl,
      createdAt: DateTime.now(),
      members: const [
        TripGroupMemberEntity(
          id: 'mem_1',
          userId: 'usr_1',
          role: 'admin',
          email: 'rashi@wetravel.app',
          username: 'rashi',
          fullName: 'Rashi',
        )
      ],
    );
  }

  @override
  Future<({String message, String? inviteToken, String? joinUrl})> inviteMember({
    required String tripId,
    required String type,
    String? friendId,
    String? email,
    String? phone,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return inviteToReturn ??
        (
          message: 'Invite sent successfully',
          inviteToken: 'token_abc_123',
          joinUrl: 'https://wetravel.app/join/token_abc_123',
        );
  }

  @override
  Future<TripEntity> joinViaToken(String token) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return TripEntity(
      id: 'trip_joined_1',
      name: 'Joined Group Trip',
      createdBy: 'usr_admin',
      status: 'planning',
      createdAt: DateTime.now(),
      members: const [
        TripGroupMemberEntity(
          id: 'mem_1',
          userId: 'usr_1',
          role: 'member',
          email: 'rashi@wetravel.app',
          username: 'rashi',
          fullName: 'Rashi',
        )
      ],
    );
  }

  @override
  Future<GroupConsensusEntity> getGroupConsensus(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return consensusToReturn ??
        GroupConsensusEntity(
          id: 'con_1',
          groupId: tripId,
          computedBudgetRange: 'Medium (\$500 - \$1500)',
          hardConstraints: const ['Vegan Food Required'],
          isLockedByAdmin: false,
        );
  }
}

void main() {
  group('TripModel JSON Parsing Tests', () {
    test('fromJson correctly parses full trip payload from backend', () {
      final json = {
        'id': 'trip_99',
        'name': 'Kerala Backwaters',
        'createdBy': 'usr_10',
        'status': 'planning',
        'coverImageUrl': 'https://images.unsplash.com/photo-kerala',
        'createdAt': '2026-09-15T00:00:00.000Z',
        'members': [
          {
            'id': 'mem_10',
            'userId': 'usr_10',
            'role': 'admin',
            'email': 'priya@example.com',
            'user': {'username': 'priya', 'fullName': 'Priya Sharma'}
          }
        ]
      };

      final model = TripModel.fromJson(json);

      expect(model.id, 'trip_99');
      expect(model.name, 'Kerala Backwaters');
      expect(model.status, 'planning');
      expect(model.createdBy, 'usr_10');
      expect(model.members.length, 1);
      expect(model.members.first.fullName, 'Priya Sharma');
    });

    test('GroupConsensusModel.fromJson parses consensus stats correctly', () {
      final json = {
        'id': 'con_100',
        'groupId': 'trip_99',
        'computedBudgetRange': 'Luxury (\$2000+)',
        'hardConstraints': ['Pet Friendly'],
        'isLockedByAdmin': true,
      };

      final model = GroupConsensusModel.fromJson(json);

      expect(model.id, 'con_100');
      expect(model.groupId, 'trip_99');
      expect(model.computedBudgetRange, 'Luxury (\$2000+)');
      expect(model.hardConstraints, ['Pet Friendly']);
      expect(model.isLockedByAdmin, isTrue);
    });
  });

  group('TripBloc Unit Tests', () {
    late FakeTripRepository fakeRepository;
    late TripBloc tripBloc;

    setUp(() {
      fakeRepository = FakeTripRepository();
      tripBloc = TripBloc(
        createTripUseCase: CreateTripUseCase(fakeRepository),
        getMyTripsUseCase: GetMyTripsUseCase(fakeRepository),
        getTripDetailsUseCase: GetTripDetailsUseCase(fakeRepository),
        inviteTripMemberUseCase: InviteTripMemberUseCase(fakeRepository),
        joinTripViaTokenUseCase: JoinTripViaTokenUseCase(fakeRepository),
        getGroupConsensusUseCase: GetGroupConsensusUseCase(fakeRepository),
      );
    });

    tearDown(() {
      tripBloc.close();
    });

    test('initial state is TripInitialState', () {
      expect(tripBloc.state, isA<TripInitialState>());
    });

    test('TripsFetchRequested success emits MyTripsLoadedState', () async {
      tripBloc.add(const TripsFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(tripBloc.state, isA<MyTripsLoadedState>());
      final loaded = tripBloc.state as MyTripsLoadedState;
      expect(loaded.trips.length, 1);
      expect(loaded.trips.first.name, 'Goa Trip 2026');
    });

    test('TripDetailsRequested success emits TripDetailLoadedState', () async {
      tripBloc.add(const TripDetailsRequested('trip_55'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(tripBloc.state, isA<TripDetailLoadedState>());
      final loaded = tripBloc.state as TripDetailLoadedState;
      expect(loaded.trip.id, 'trip_55');
      expect(loaded.trip.name, 'Manali Expedition');
    });

    test('TripCreateRequested creates trip and emits TripCreatedState', () async {
      tripBloc.add(const TripCreateRequested(name: 'Rajasthan Royal Tour'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(tripBloc.state, isA<TripCreatedState>());
      final created = tripBloc.state as TripCreatedState;
      expect(created.trip.name, 'Rajasthan Royal Tour');
      expect(created.message, contains('created successfully'));
    });

    test('TripInviteMemberRequested emits TripInviteSentState', () async {
      tripBloc.add(const TripInviteMemberRequested(
        tripId: 'trip_1',
        type: 'email',
        email: 'friend@wetravel.app',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(tripBloc.state, isA<TripInviteSentState>());
      final invited = tripBloc.state as TripInviteSentState;
      expect(invited.message, contains('sent successfully'));
      expect(invited.inviteToken, 'token_abc_123');
    });

    test('TripJoinViaTokenRequested emits TripJoinedState', () async {
      tripBloc.add(const TripJoinViaTokenRequested('token_abc_123'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(tripBloc.state, isA<TripJoinedState>());
      final joined = tripBloc.state as TripJoinedState;
      expect(joined.trip.name, 'Joined Group Trip');
    });
  });
}
