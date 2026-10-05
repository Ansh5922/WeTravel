import 'package:equatable/equatable.dart';
import '../../domain/entities/inbox_invite_entity.dart';

abstract class InboxState extends Equatable {
  const InboxState();

  @override
  List<Object?> get props => [];
}

class InboxInitialState extends InboxState {}

class InboxLoadingState extends InboxState {}

class InboxLoadedState extends InboxState {
  final List<InboxInviteEntity> allInvites;
  final List<InboxInviteEntity> filteredInvites;
  final String activeTab; // 'all', 'pending', 'accepted', 'declined'
  final String searchQuery;
  final String? successMessage;
  final bool isActionLoading;

  const InboxLoadedState({
    required this.allInvites,
    required this.filteredInvites,
    this.activeTab = 'all',
    this.searchQuery = '',
    this.successMessage,
    this.isActionLoading = false,
  });

  int get pendingCount =>
      allInvites.where((i) => i.status == InboxInviteStatus.pending).length;
  int get acceptedCount =>
      allInvites.where((i) => i.status == InboxInviteStatus.accepted).length;
  int get declinedCount =>
      allInvites.where((i) => i.status == InboxInviteStatus.rejected).length;

  InboxLoadedState copyWith({
    List<InboxInviteEntity>? allInvites,
    List<InboxInviteEntity>? filteredInvites,
    String? activeTab,
    String? searchQuery,
    String? successMessage,
    bool? isActionLoading,
  }) {
    return InboxLoadedState(
      allInvites: allInvites ?? this.allInvites,
      filteredInvites: filteredInvites ?? this.filteredInvites,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: successMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        allInvites,
        filteredInvites,
        activeTab,
        searchQuery,
        successMessage,
        isActionLoading,
      ];
}

class InboxErrorState extends InboxState {
  final String message;

  const InboxErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
