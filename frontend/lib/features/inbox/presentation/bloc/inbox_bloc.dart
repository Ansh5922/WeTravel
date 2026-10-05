import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/inbox_invite_entity.dart';
import '../../domain/usecases/get_my_invites_usecase.dart';
import '../../domain/usecases/respond_to_invite_usecase.dart';
import 'inbox_event.dart';
import 'inbox_state.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final GetMyInvitesUseCase getMyInvitesUseCase;
  final RespondToInviteUseCase respondToInviteUseCase;

  InboxBloc({
    required this.getMyInvitesUseCase,
    required this.respondToInviteUseCase,
  }) : super(InboxInitialState()) {
    on<InboxFetchRequested>(_onInboxFetchRequested);
    on<InboxInviteAccepted>(_onInboxInviteAccepted);
    on<InboxInviteDeclined>(_onInboxInviteDeclined);
    on<InboxFilterTabChanged>(_onInboxFilterTabChanged);
    on<InboxSearchQueryChanged>(_onInboxSearchQueryChanged);
  }

  Future<void> _onInboxFetchRequested(
    InboxFetchRequested event,
    Emitter<InboxState> emit,
  ) async {
    debugPrint('[INBOX_BLOC] 📥 Event: InboxFetchRequested');
    emit(InboxLoadingState());

    try {
      final invites = await getMyInvitesUseCase();
      debugPrint('[INBOX_BLOC] ✅ Fetch Success: Loaded ${invites.length} invite(s)');
      emit(InboxLoadedState(
        allInvites: invites,
        filteredInvites: invites,
        activeTab: 'all',
        searchQuery: '',
      ));
    } on ServerException catch (e) {
      debugPrint('[INBOX_BLOC] ❌ Fetch Error: ${e.message}');
      emit(InboxErrorState(message: e.message));
    } catch (e) {
      debugPrint('[INBOX_BLOC] 💥 Unexpected Error: $e');
      emit(InboxErrorState(message: 'Failed to load trip invites: ${e.toString()}'));
    }
  }

  Future<void> _onInboxInviteAccepted(
    InboxInviteAccepted event,
    Emitter<InboxState> emit,
  ) async {
    debugPrint('[INBOX_BLOC] 👍 Event: InboxInviteAccepted (inviteId: ${event.inviteId})');
    await _handleInviteResponse(event.inviteId, 'accept', InboxInviteStatus.accepted, emit);
  }

  Future<void> _onInboxInviteDeclined(
    InboxInviteDeclined event,
    Emitter<InboxState> emit,
  ) async {
    debugPrint('[INBOX_BLOC] 👎 Event: InboxInviteDeclined (inviteId: ${event.inviteId})');
    await _handleInviteResponse(event.inviteId, 'reject', InboxInviteStatus.rejected, emit);
  }

  Future<void> _handleInviteResponse(
    String inviteId,
    String action,
    InboxInviteStatus targetStatus,
    Emitter<InboxState> emit,
  ) async {
    if (state is! InboxLoadedState) return;
    final currentState = state as InboxLoadedState;

    emit(currentState.copyWith(isActionLoading: true));

    try {
      final successMsg = await respondToInviteUseCase(inviteId: inviteId, action: action);
      debugPrint('[INBOX_BLOC] ✅ Respond Success: $successMsg');

      final updatedList = currentState.allInvites.map((inv) {
        if (inv.id == inviteId) {
          return inv.copyWith(status: targetStatus);
        }
        return inv;
      }).toList();

      final filtered = _filterInvites(
        updatedList,
        currentState.activeTab,
        currentState.searchQuery.trim().toLowerCase(),
      );

      emit(currentState.copyWith(
        allInvites: updatedList,
        filteredInvites: filtered,
        successMessage: successMsg,
        isActionLoading: false,
      ));
    } on ServerException catch (e) {
      debugPrint('[INBOX_BLOC] ❌ Respond Error: ${e.message}');
      emit(currentState.copyWith(isActionLoading: false));
    } catch (e) {
      debugPrint('[INBOX_BLOC] 💥 Unexpected Respond Error: $e');
      emit(currentState.copyWith(isActionLoading: false));
    }
  }

  void _onInboxFilterTabChanged(
    InboxFilterTabChanged event,
    Emitter<InboxState> emit,
  ) {
    debugPrint('[INBOX_BLOC] 🏷️ Event: InboxFilterTabChanged ("${event.tab}")');
    if (state is InboxLoadedState) {
      final currentState = state as InboxLoadedState;
      final filtered = _filterInvites(
        currentState.allInvites,
        event.tab,
        currentState.searchQuery.trim().toLowerCase(),
      );

      emit(currentState.copyWith(
        activeTab: event.tab,
        filteredInvites: filtered,
      ));
    }
  }

  void _onInboxSearchQueryChanged(
    InboxSearchQueryChanged event,
    Emitter<InboxState> emit,
  ) {
    debugPrint('[INBOX_BLOC] 🔍 Event: InboxSearchQueryChanged ("${event.query}")');
    if (state is InboxLoadedState) {
      final currentState = state as InboxLoadedState;
      final query = event.query.trim().toLowerCase();
      final filtered = _filterInvites(currentState.allInvites, currentState.activeTab, query);

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredInvites: filtered,
      ));
    }
  }

  List<InboxInviteEntity> _filterInvites(
    List<InboxInviteEntity> invites,
    String tab,
    String query,
  ) {
    return invites.where((inv) {
      final matchesTab = switch (tab.toLowerCase()) {
        'all' => true,
        'pending' => inv.status == InboxInviteStatus.pending,
        'accepted' => inv.status == InboxInviteStatus.accepted,
        'declined' || 'rejected' => inv.status == InboxInviteStatus.rejected,
        _ => true,
      };

      if (!matchesTab) return false;

      if (query.isEmpty) return true;
      return inv.groupName.toLowerCase().contains(query) ||
          inv.inviterFullName.toLowerCase().contains(query) ||
          inv.inviterUsername.toLowerCase().contains(query);
    }).toList();
  }
}
