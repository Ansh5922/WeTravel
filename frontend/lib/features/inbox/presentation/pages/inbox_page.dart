import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/we_travel_screen_header.dart';
import '../../../../core/widgets/we_travel_filter_chips.dart';
import '../../../../core/widgets/we_travel_search_bar.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../domain/entities/inbox_invite_entity.dart';
import '../../domain/entities/trip_invitation.dart';
import '../bloc/inbox_bloc.dart';
import '../bloc/inbox_event.dart';
import '../bloc/inbox_state.dart';
import '../widgets/inbox_filter_chips.dart';
import '../widgets/invitation_card.dart';

/// Inbox Page displaying trip invitations connected to backend via [InboxBloc].
/// Features interactive status filtering, live search, sort options,
/// accept/decline actions with instant state updates, and join-via-token capability.
class InboxPage extends StatefulWidget {
  final bool isEmbedded;

  const InboxPage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  InboxFilterTab _selectedTab = InboxFilterTab.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeSort = 'newest'; // 'newest', 'oldest', 'destination', 'title'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InboxBloc>().add(const InboxFetchRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _acceptInvite(String inviteId, String title) {
    context.read<InboxBloc>().add(InboxInviteAccepted(inviteId));
    // Also trigger TripsFetchRequested so "My Trips" is immediately updated
    context.read<TripBloc>().add(const TripsFetchRequested());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Joined "$title"! Added to your Trips.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004E64),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _declineInvite(String inviteId, String title) {
    context.read<InboxBloc>().add(InboxInviteDeclined(inviteId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Declined invitation to "$title".',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openInvitationDetails(TripInvitation invitation) {
    context.push(RouteNames.invitationDetails, extra: invitation).then((_) {
      if (mounted) {
        // Refresh inbox when returning to reflect any updates made in details page
        context.read<InboxBloc>().add(const InboxFetchRequested());
      }
    });
  }


  List<InboxInviteEntity> _filterAndSort(List<InboxInviteEntity> invites) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = invites.where((inv) {
      // 1. Status Filter
      final matchesTab = switch (_selectedTab) {
        InboxFilterTab.all => true,
        InboxFilterTab.pending => inv.status == InboxInviteStatus.pending,
        InboxFilterTab.accepted => inv.status == InboxInviteStatus.accepted,
        InboxFilterTab.declined => inv.status == InboxInviteStatus.rejected,
      };

      if (!matchesTab) return false;

      // 2. Search Query Filter
      if (query.isEmpty) return true;
      return inv.groupName.toLowerCase().contains(query) ||
          inv.inviterFullName.toLowerCase().contains(query) ||
          inv.inviterUsername.toLowerCase().contains(query);
    }).toList();

    // 3. Sorting
    if (_activeSort == 'oldest') {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    } else if (_activeSort == 'destination') {
      filtered.sort((a, b) => a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
    } else if (_activeSort == 'title') {
      filtered.sort((a, b) => a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
    } else {
      // Newest first by default
      filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InboxBloc, InboxState>(
          listener: (context, state) {
            if (state is InboxLoadedState && state.successMessage != null) {
              // Refresh trips in background
              context.read<TripBloc>().add(const TripsFetchRequested());
            }
          },
        ),
        BlocListener<TripBloc, TripState>(
          listener: (context, state) {
            if (state is TripJoinedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🎉 Successfully joined "${state.trip.name}"!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF004E64),
                ),
              );
              // Refresh both inbox and trips
              context.read<InboxBloc>().add(const InboxFetchRequested());
              context.read<TripBloc>().add(const TripsFetchRequested());
            } else if (state is TripErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<InboxBloc, InboxState>(
        builder: (context, state) {
          final allInvites =
              state is InboxLoadedState ? state.allInvites : <InboxInviteEntity>[];
          final displayedInvites = _filterAndSort(allInvites);

          final pendingCount = allInvites
              .where((i) => i.status == InboxInviteStatus.pending)
              .length;
          final acceptedCount = allInvites
              .where((i) => i.status == InboxInviteStatus.accepted)
              .length;
          final declinedCount = allInvites
              .where((i) => i.status == InboxInviteStatus.rejected)
              .length;

          final isLoading = state is InboxLoadingState && allInvites.isEmpty;

          final content = Column(
            children: [
              // ── 1. Unified Reusable Header (Scanner Icon Removed) ────────
              if (!widget.isEmbedded)
                const WeTravelScreenHeader(
                  title: 'Inbox',
                  showMenuButton: false,
                ),

              // ── 2. Fixed Search & Filter Section (Solid Background) ──────
              Container(
                color: const Color(0xFFFAF9F6),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    WeTravelSearchBar(
                      controller: _searchController,
                      hintText: 'Search trips, destinations, members...',
                      hasActiveFilter: _selectedTab != InboxFilterTab.all ||
                          _activeSort != 'newest',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      showFilterButton: false, // Commented out filter button for now
                    ),
                    const SizedBox(height: 10),
                    WeTravelFilterChips<InboxFilterTab>(
                      selectedValue: _selectedTab,
                      onSelected: (tab) {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      items: [
                        FilterChipItem(
                          value: InboxFilterTab.all,
                          label: 'All',
                          count: allInvites.length,
                        ),
                        FilterChipItem(
                          value: InboxFilterTab.pending,
                          label: 'Pending',
                          count: pendingCount,
                        ),
                        FilterChipItem(
                          value: InboxFilterTab.accepted,
                          label: 'Accepted',
                          count: acceptedCount,
                        ),
                        FilterChipItem(
                          value: InboxFilterTab.declined,
                          label: 'Declined',
                          count: declinedCount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 3. Invitations List Body with ClipRect ───────────────────
              Expanded(
                child: ClipRect(
                  child: RefreshIndicator(
                    color: const Color(0xFF004E64),
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      context
                          .read<InboxBloc>()
                          .add(const InboxFetchRequested());
                      await Future.delayed(
                          const Duration(milliseconds: 600));
                    },
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              widget.isEmbedded ? 96 : 24,
                            ),
                            itemCount: 3,
                            itemBuilder: (context, index) =>
                                _buildSkeletonInviteCard(),
                          );
                        }

                        if (state is InboxErrorState && allInvites.isEmpty) {
                          return _buildErrorState(state.message);
                        }

                        if (displayedInvites.isEmpty) {
                          return _buildEmptyState(allInvites.isEmpty);
                        }

                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            widget.isEmbedded ? 96 : 24,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: displayedInvites.length,
                          itemBuilder: (context, index) {
                            final invite = displayedInvites[index];
                            final tripInvitation =
                                TripInvitation.fromInboxInvite(invite);

                            return InvitationCard(
                              invitation: tripInvitation,
                              onTap: () =>
                                  _openInvitationDetails(tripInvitation),
                              onAccept:
                                  invite.status == InboxInviteStatus.pending
                                      ? () => _acceptInvite(
                                            invite.id,
                                            tripInvitation.title,
                                          )
                                      : null,
                              onDecline:
                                  invite.status == InboxInviteStatus.pending
                                      ? () => _declineInvite(
                                            invite.id,
                                            tripInvitation.title,
                                          )
                                      : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );

          if (widget.isEmbedded) {
            return Container(
              color: const Color(0xFFFAF9F6),
              child: content,
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFAF9F6),
            body: content,
          );
        },
      ),
    );
  }

  Widget _buildSkeletonInviteCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Container(
        height: 380,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load invitations',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                context.read<InboxBloc>().add(const InboxFetchRequested());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004E64),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFF004E64).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                size: 36,
                color: Color(0xFF004E64),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isCompletelyEmpty
                  ? 'Your inbox is clear'
                  : 'No matching invitations found',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompletelyEmpty
                  ? 'When friends invite you to join their trips, your invitations will show up here.'
                  : (_searchQuery.isNotEmpty
                      ? 'No invitations match "$_searchQuery".'
                      : 'No invitations found under the selected filter.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (isCompletelyEmpty)
              ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.createTrip),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Plan Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004E64),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedTab = InboxFilterTab.all;
                    _activeSort = 'newest';
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF004E64),
                  side: const BorderSide(color: Color(0xFF004E64)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter & Sort Invitations',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (_selectedTab != InboxFilterTab.all ||
                            _activeSort != 'newest')
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedTab = InboxFilterTab.all;
                                _activeSort = 'newest';
                              });
                              setState(() {});
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'STATUS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        {'label': 'All', 'tab': InboxFilterTab.all},
                        {'label': 'Pending', 'tab': InboxFilterTab.pending},
                        {'label': 'Accepted', 'tab': InboxFilterTab.accepted},
                        {'label': 'Declined', 'tab': InboxFilterTab.declined},
                      ].map((item) {
                        final tab = item['tab'] as InboxFilterTab;
                        final isSelected = _selectedTab == tab;
                        return ChoiceChip(
                          label: Text(item['label'] as String),
                          selected: isSelected,
                          selectedColor: const Color(0xFF004E64),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF004E64)
                                  : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedTab = tab;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'SORT BY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        {'label': 'Newest First', 'value': 'newest'},
                        {'label': 'Oldest First', 'value': 'oldest'},
                        {'label': 'Destination (A–Z)', 'value': 'destination'},
                        {'label': 'Title (A–Z)', 'value': 'title'},
                      ].map((sortItem) {
                        final isSelected = _activeSort == sortItem['value'];
                        return ChoiceChip(
                          label: Text(sortItem['label']!),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _activeSort = sortItem['value']!;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
