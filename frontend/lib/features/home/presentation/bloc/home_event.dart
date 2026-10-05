import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeFetchRequested extends HomeEvent {
  final String? statusFilter;

  const HomeFetchRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class HomeSearchQueryChanged extends HomeEvent {
  final String query;

  const HomeSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class HomeFilterStatusChanged extends HomeEvent {
  final String statusFilter; // 'All', 'Upcoming', 'Planning', 'Ongoing', 'Completed'

  const HomeFilterStatusChanged(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}
