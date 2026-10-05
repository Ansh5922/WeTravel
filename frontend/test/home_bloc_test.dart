import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/home/data/models/home_trip_model.dart';
import 'package:frontend/features/home/domain/entities/home_trip.dart';
import 'package:frontend/features/home/domain/repositories/home_repository.dart';
import 'package:frontend/features/home/domain/usecases/get_home_trips_usecase.dart';
import 'package:frontend/features/home/presentation/bloc/home_bloc.dart';
import 'package:frontend/features/home/presentation/bloc/home_event.dart';
import 'package:frontend/features/home/presentation/bloc/home_state.dart';

class FakeHomeRepository implements HomeRepository {
  List<HomeTripEntity>? tripsToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<HomeTripEntity>> getHomeTrips({String? status}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return tripsToReturn ??
        const [
          HomeTripEntity(
            id: 'trip_1',
            title: 'Goa Getaway',
            status: 'planning',
            statusLabel: 'Planning',
            dateText: '12 – 15 Oct 2026',
            memberCount: 4,
            location: 'Goa, India',
            members: [],
          ),
          HomeTripEntity(
            id: 'trip_2',
            title: 'Kerala Retreat',
            status: 'ongoing',
            statusLabel: 'Ongoing',
            dateText: '10 – 18 Oct 2026',
            memberCount: 2,
            location: 'Kerala, India',
            members: [],
          ),
        ];
  }
}

void main() {
  group('HomeTripModel JSON Parsing', () {
    test('fromJson correctly parses backend trip JSON', () {
      final json = {
        'id': 'trip_100',
        'name': 'Manali Expedition',
        'status': 'planning',
        'tripStartDate': '2026-11-01T00:00:00.000Z',
        'tripEndDate': '2026-11-07T00:00:00.000Z',
        'members': [
          {
            'id': 'm1',
            'userId': 'u1',
            'role': 'admin',
            'user': {'id': 'u1', 'username': 'alex', 'fullName': 'Alex Doe'}
          }
        ],
      };

      final model = HomeTripModel.fromJson(json);

      expect(model.id, 'trip_100');
      expect(model.title, 'Manali Expedition');
      expect(model.status, 'planning');
      expect(model.statusLabel, 'Planning');
      expect(model.memberCount, 1);
      expect(model.members.first.fullName, 'Alex Doe');
    });
  });

  group('HomeBloc Unit Tests', () {
    late FakeHomeRepository fakeRepository;
    late HomeBloc homeBloc;

    setUp(() {
      fakeRepository = FakeHomeRepository();
      homeBloc = HomeBloc(
        getHomeTripsUseCase: GetHomeTripsUseCase(fakeRepository),
      );
    });

    tearDown(() {
      homeBloc.close();
    });

    test('initial state is HomeInitialState', () {
      expect(homeBloc.state, isA<HomeInitialState>());
    });

    test('HomeFetchRequested success emits HomeLoadedState with trips', () async {
      homeBloc.add(const HomeFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(homeBloc.state, isA<HomeLoadedState>());
      final loaded = homeBloc.state as HomeLoadedState;
      expect(loaded.allTrips.length, 2);
      expect(loaded.filteredTrips.length, 2);
    });

    test('HomeFetchRequested failure emits HomeErrorState', () async {
      fakeRepository.exceptionToThrow = const ServerException('Server unavailable', 500);

      homeBloc.add(const HomeFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(homeBloc.state, isA<HomeErrorState>());
      expect((homeBloc.state as HomeErrorState).message, 'Server unavailable');
    });

    test('HomeSearchQueryChanged filters trips by title', () async {
      homeBloc.add(const HomeFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      homeBloc.add(const HomeSearchQueryChanged('Goa'));
      await Future.delayed(const Duration(milliseconds: 50));

      final loaded = homeBloc.state as HomeLoadedState;
      expect(loaded.filteredTrips.length, 1);
      expect(loaded.filteredTrips.first.title, 'Goa Getaway');
    });
  });
}
