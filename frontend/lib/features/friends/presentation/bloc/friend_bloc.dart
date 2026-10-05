import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/friend_usecases.dart';
import 'friend_event.dart';
import 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final GetFriendsUseCase getFriendsUseCase;
  final GetPendingFriendRequestsUseCase getPendingFriendRequestsUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final RespondFriendRequestUseCase respondFriendRequestUseCase;

  FriendBloc({
    required this.getFriendsUseCase,
    required this.getPendingFriendRequestsUseCase,
    required this.sendFriendRequestUseCase,
    required this.respondFriendRequestUseCase,
  }) : super(FriendInitialState()) {
    on<FriendsFetchRequested>(_onFriendsFetchRequested);
    on<FriendRequestsFetchRequested>(_onFriendRequestsFetchRequested);
    on<FriendSendRequestRequested>(_onFriendSendRequestRequested);
    on<FriendRespondRequestRequested>(_onFriendRespondRequestRequested);
  }

  Future<void> _onFriendsFetchRequested(
    FriendsFetchRequested event,
    Emitter<FriendState> emit,
  ) async {
    debugPrint('[FRIEND_BLOC] 👥 Event: FriendsFetchRequested');
    emit(FriendLoadingState());

    try {
      final friends = await getFriendsUseCase();
      final requests = await getPendingFriendRequestsUseCase();

      debugPrint('[FRIEND_BLOC] ✅ Loaded ${friends.length} friend(s) and ${requests.length} pending request(s)');
      emit(FriendsLoadedState(friends: friends, pendingRequests: requests));
    } on ServerException catch (e) {
      debugPrint('[FRIEND_BLOC] ❌ Fetch Error: ${e.message}');
      emit(FriendErrorState(message: e.message));
    } catch (e) {
      debugPrint('[FRIEND_BLOC] 💥 Unexpected Fetch Error: $e');
      emit(FriendErrorState(message: 'Failed to fetch friends: ${e.toString()}'));
    }
  }

  Future<void> _onFriendRequestsFetchRequested(
    FriendRequestsFetchRequested event,
    Emitter<FriendState> emit,
  ) async {
    debugPrint('[FRIEND_BLOC] 📩 Event: FriendRequestsFetchRequested');

    try {
      final requests = await getPendingFriendRequestsUseCase();
      debugPrint('[FRIEND_BLOC] ✅ Loaded ${requests.length} pending request(s)');

      if (state is FriendsLoadedState) {
        final current = state as FriendsLoadedState;
        emit(current.copyWith(pendingRequests: requests));
      } else {
        final friends = await getFriendsUseCase();
        emit(FriendsLoadedState(friends: friends, pendingRequests: requests));
      }
    } on ServerException catch (e) {
      debugPrint('[FRIEND_BLOC] ❌ Requests Error: ${e.message}');
      emit(FriendErrorState(message: e.message));
    } catch (e) {
      debugPrint('[FRIEND_BLOC] 💥 Unexpected Requests Error: $e');
      emit(FriendErrorState(message: 'Failed to fetch pending requests: ${e.toString()}'));
    }
  }

  Future<void> _onFriendSendRequestRequested(
    FriendSendRequestRequested event,
    Emitter<FriendState> emit,
  ) async {
    debugPrint('[FRIEND_BLOC] 🤝 Event: FriendSendRequestRequested -> username: ${event.username}');

    try {
      await sendFriendRequestUseCase(event.username);
      debugPrint('[FRIEND_BLOC] ✅ Friend request sent to "${event.username}"');

      final friends = await getFriendsUseCase();
      final requests = await getPendingFriendRequestsUseCase();

      emit(FriendsLoadedState(
        friends: friends,
        pendingRequests: requests,
        successMessage: 'Friend request sent to ${event.username}.',
      ));
    } on ServerException catch (e) {
      debugPrint('[FRIEND_BLOC] ❌ Send Request Error: ${e.message}');
      emit(FriendErrorState(message: e.message));
    } catch (e) {
      debugPrint('[FRIEND_BLOC] 💥 Unexpected Send Request Error: $e');
      emit(FriendErrorState(message: 'Failed to send request: ${e.toString()}'));
    }
  }

  Future<void> _onFriendRespondRequestRequested(
    FriendRespondRequestRequested event,
    Emitter<FriendState> emit,
  ) async {
    debugPrint('[FRIEND_BLOC] ✏️ Event: FriendRespondRequestRequested -> id: ${event.friendshipId}, action: ${event.action}');

    try {
      await respondFriendRequestUseCase(event.friendshipId, event.action);
      debugPrint('[FRIEND_BLOC] ✅ Friend request ${event.action}ed successfully');

      final friends = await getFriendsUseCase();
      final requests = await getPendingFriendRequestsUseCase();

      emit(FriendsLoadedState(
        friends: friends,
        pendingRequests: requests,
        successMessage: 'Friend request ${event.action}ed.',
      ));
    } on ServerException catch (e) {
      debugPrint('[FRIEND_BLOC] ❌ Respond Error: ${e.message}');
      emit(FriendErrorState(message: e.message));
    } catch (e) {
      debugPrint('[FRIEND_BLOC] 💥 Unexpected Respond Error: $e');
      emit(FriendErrorState(message: 'Failed to respond to request: ${e.toString()}'));
    }
  }
}
