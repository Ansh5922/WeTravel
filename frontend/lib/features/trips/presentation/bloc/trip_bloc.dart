import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/create_trip_usecase.dart';
import '../../domain/usecases/get_group_consensus_usecase.dart';
import '../../domain/usecases/get_my_trips_usecase.dart';
import '../../domain/usecases/get_trip_details_usecase.dart';
import '../../domain/usecases/invite_trip_member_usecase.dart';
import '../../domain/usecases/join_trip_via_token_usecase.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final CreateTripUseCase createTripUseCase;
  final GetMyTripsUseCase getMyTripsUseCase;
  final GetTripDetailsUseCase getTripDetailsUseCase;
  final InviteTripMemberUseCase inviteTripMemberUseCase;
  final JoinTripViaTokenUseCase joinTripViaTokenUseCase;
  final GetGroupConsensusUseCase getGroupConsensusUseCase;

  TripBloc({
    required this.createTripUseCase,
    required this.getMyTripsUseCase,
    required this.getTripDetailsUseCase,
    required this.inviteTripMemberUseCase,
    required this.joinTripViaTokenUseCase,
    required this.getGroupConsensusUseCase,
  }) : super(TripInitialState()) {
    on<TripsFetchRequested>(_onTripsFetchRequested);
    on<TripDetailsRequested>(_onTripDetailsRequested);
    on<TripCreateRequested>(_onTripCreateRequested);
    on<TripInviteMemberRequested>(_onTripInviteMemberRequested);
    on<TripJoinViaTokenRequested>(_onTripJoinViaTokenRequested);
    on<GroupConsensusRequested>(_onGroupConsensusRequested);
  }

  Future<void> _onTripsFetchRequested(
    TripsFetchRequested event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('[TRIP_BLOC] ✈️ Event: TripsFetchRequested (filter: ${event.statusFilter})');
    emit(TripLoadingState());

    try {
      final trips = await getMyTripsUseCase(status: event.statusFilter);
      debugPrint('[TRIP_BLOC] ✅ Fetch Success: Loaded ${trips.length} trip(s)');
      emit(MyTripsLoadedState(trips: trips));
    } on ServerException catch (e) {
      debugPrint('[TRIP_BLOC] ❌ Fetch Error: ${e.message}');
      emit(TripErrorState(message: e.message));
    } catch (e) {
      debugPrint('[TRIP_BLOC] 💥 Unexpected Fetch Error: $e');
      emit(TripErrorState(message: 'Failed to fetch trips: ${e.toString()}'));
    }
  }

  Future<void> _onTripDetailsRequested(
    TripDetailsRequested event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('[TRIP_BLOC] 📌 Event: TripDetailsRequested (tripId: ${event.tripId})');
    emit(TripLoadingState());

    try {
      final trip = await getTripDetailsUseCase(event.tripId);
      debugPrint('[TRIP_BLOC] ✅ Detail Success: "${trip.name}" with ${trip.members.length} member(s)');
      emit(TripDetailLoadedState(trip: trip));
    } on ServerException catch (e) {
      debugPrint('[TRIP_BLOC] ❌ Detail Error: ${e.message}');
      emit(TripErrorState(message: e.message));
    } catch (e) {
      debugPrint('[TRIP_BLOC] 💥 Unexpected Detail Error: $e');
      emit(TripErrorState(message: 'Failed to fetch trip details: ${e.toString()}'));
    }
  }

  Future<void> _onTripCreateRequested(
    TripCreateRequested event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('[TRIP_BLOC] ✨ Event: TripCreateRequested (name: "${event.name}")');
    emit(TripLoadingState());

    try {
      final trip = await createTripUseCase(
        name: event.name,
        tripStartDate: event.tripStartDate,
        tripEndDate: event.tripEndDate,
        coverImageUrl: event.coverImageUrl,
      );

      debugPrint('[TRIP_BLOC] 🎉 Trip Created! ID: ${trip.id}, Creator is Admin');
      emit(TripCreatedState(
        trip: trip,
        message: 'Trip "${trip.name}" created successfully. You are the admin.',
      ));
    } on ServerException catch (e) {
      debugPrint('[TRIP_BLOC] ❌ Create Error: ${e.message}');
      emit(TripErrorState(message: e.message));
    } catch (e) {
      debugPrint('[TRIP_BLOC] 💥 Unexpected Create Error: $e');
      emit(TripErrorState(message: 'Failed to create trip: ${e.toString()}'));
    }
  }

  Future<void> _onTripInviteMemberRequested(
    TripInviteMemberRequested event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('[TRIP_BLOC] 📩 Event: TripInviteMemberRequested (type: ${event.type}, tripId: ${event.tripId})');

    try {
      final result = await inviteTripMemberUseCase(
        tripId: event.tripId,
        type: event.type,
        friendId: event.friendId,
        email: event.email,
        phone: event.phone,
      );

      debugPrint('[TRIP_BLOC] ✅ Invite Sent! ${result.message}');
      emit(TripInviteSentState(
        message: result.message,
        inviteToken: result.inviteToken,
        joinUrl: result.joinUrl,
      ));
    } on ServerException catch (e) {
      debugPrint('[TRIP_BLOC] ❌ Invite Error: ${e.message}');
      emit(TripErrorState(message: e.message));
    } catch (e) {
      debugPrint('[TRIP_BLOC] 💥 Unexpected Invite Error: $e');
      emit(TripErrorState(message: 'Failed to send invite: ${e.toString()}'));
    }
  }

  Future<void> _onTripJoinViaTokenRequested(
    TripJoinViaTokenRequested event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('[TRIP_BLOC] 🔗 Event: TripJoinViaTokenRequested (token: ${event.token})');
    emit(TripLoadingState());

    try {
      final trip = await joinTripViaTokenUseCase(event.token);
      debugPrint('[TRIP_BLOC] 🎉 Joined Trip! "${trip.name}"');
      emit(TripJoinedState(trip: trip));
    } on ServerException catch (e) {
      debugPrint('[TRIP_BLOC] ❌ Join Error: ${e.message}');
      emit(TripErrorState(message: e.message));
    } catch (e) {
      debugPrint('[TRIP_BLOC] 💥 Unexpected Join Error: $e');
      emit(TripErrorState(message: 'Failed to join trip: ${e.toString()}'));
    }
  }

  Future<void> _onGroupConsensusRequested(
    GroupConsensusRequested event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('[TRIP_BLOC] 📊 Event: GroupConsensusRequested (tripId: ${event.tripId})');

    try {
      final consensus = await getGroupConsensusUseCase(event.tripId);
      debugPrint('[TRIP_BLOC] ✅ Consensus Loaded! Budget: ${consensus.computedBudgetRange}');

      if (state is TripDetailLoadedState) {
        final current = state as TripDetailLoadedState;
        emit(TripDetailLoadedState(trip: current.trip, consensus: consensus));
      }
    } on ServerException catch (e) {
      debugPrint('[TRIP_BLOC] ❌ Consensus Error: ${e.message}');
      // Non-fatal exception for detail screen
    } catch (e) {
      debugPrint('[TRIP_BLOC] 💥 Unexpected Consensus Error: $e');
    }
  }
}
