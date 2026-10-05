import 'package:equatable/equatable.dart';
import '../../domain/entities/home_trip.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<HomeTripEntity> allTrips;
  final List<HomeTripEntity> filteredTrips;
  final String activeStatusFilter; // 'All', 'Upcoming', 'Planning', 'Ongoing', 'Completed'
  final String searchQuery;

  const HomeLoadedState({
    required this.allTrips,
    required this.filteredTrips,
    this.activeStatusFilter = 'All',
    this.searchQuery = '',
  });

  HomeLoadedState copyWith({
    List<HomeTripEntity>? allTrips,
    List<HomeTripEntity>? filteredTrips,
    String? activeStatusFilter,
    String? searchQuery,
  }) {
    return HomeLoadedState(
      allTrips: allTrips ?? this.allTrips,
      filteredTrips: filteredTrips ?? this.filteredTrips,
      activeStatusFilter: activeStatusFilter ?? this.activeStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allTrips, filteredTrips, activeStatusFilter, searchQuery];
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
