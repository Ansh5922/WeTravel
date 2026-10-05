import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/home_trip.dart';
import '../../domain/usecases/get_home_trips_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeTripsUseCase getHomeTripsUseCase;

  HomeBloc({required this.getHomeTripsUseCase}) : super(HomeInitialState()) {
    on<HomeFetchRequested>(_onHomeFetchRequested);
    on<HomeSearchQueryChanged>(_onHomeSearchQueryChanged);
    on<HomeFilterStatusChanged>(_onHomeFilterStatusChanged);
  }

  Future<void> _onHomeFetchRequested(
    HomeFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    debugPrint('[HOME_BLOC] 📥 Event: HomeFetchRequested (filter: ${event.statusFilter})');
    emit(HomeLoadingState());

    try {
      final trips = await getHomeTripsUseCase(status: event.statusFilter);
      debugPrint('[HOME_BLOC] ✅ Fetch Success: Loaded ${trips.length} trip(s)');
      emit(HomeLoadedState(
        allTrips: trips,
        filteredTrips: trips,
        activeStatusFilter: 'All',
        searchQuery: '',
      ));
    } on ServerException catch (e) {
      debugPrint('[HOME_BLOC] ❌ Fetch Error: ${e.message}');
      emit(HomeErrorState(message: e.message));
    } catch (e) {
      debugPrint('[HOME_BLOC] 💥 Unexpected Error: $e');
      emit(HomeErrorState(message: 'Failed to load home trips: ${e.toString()}'));
    }
  }

  void _onHomeSearchQueryChanged(
    HomeSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    debugPrint('[HOME_BLOC] 🔍 Event: HomeSearchQueryChanged ("${event.query}")');
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      final query = event.query.trim().toLowerCase();
      final filtered = _filterTrips(currentState.allTrips, currentState.activeStatusFilter, query);

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredTrips: filtered,
      ));
    }
  }

  void _onHomeFilterStatusChanged(
    HomeFilterStatusChanged event,
    Emitter<HomeState> emit,
  ) {
    debugPrint('[HOME_BLOC] 🏷️ Event: HomeFilterStatusChanged ("${event.statusFilter}")');
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      final filtered = _filterTrips(currentState.allTrips, event.statusFilter, currentState.searchQuery.trim().toLowerCase());

      emit(currentState.copyWith(
        activeStatusFilter: event.statusFilter,
        filteredTrips: filtered,
      ));
    }
  }

  List<HomeTripEntity> _filterTrips(
    List<HomeTripEntity> trips,
    String statusFilter,
    String query,
  ) {
    return trips.where((trip) {
      final matchesQuery = query.isEmpty ||
          trip.title.toLowerCase().contains(query) ||
          trip.location.toLowerCase().contains(query);

      final matchesFilter = statusFilter == 'All' ||
          trip.statusLabel.toLowerCase() == statusFilter.toLowerCase();

      return matchesQuery && matchesFilter;
    }).toList();
  }
}
