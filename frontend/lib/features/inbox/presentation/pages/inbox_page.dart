import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/trip_invitation.dart';
import '../widgets/inbox_filter_chips.dart';
import '../widgets/inbox_header.dart';
import '../widgets/invitation_card.dart';

/// Inbox Page displaying trip invitations with interactive filtering,
/// live search, and accept/decline actions.
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late List<TripInvitation> _invitations;
  InboxFilterTab _selectedTab = InboxFilterTab.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeSort = 'newest'; // 'newest', 'oldest', 'destination', 'title'

  @override
  void initState() {
    super.initState();
    _invitations = List.from(TripInvitation.initialInvitations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _pendingCount =>
      _invitations.where((i) => i.status == InvitationStatus.pending).length;
  int get _acceptedCount =>
      _invitations.where((i) => i.status == InvitationStatus.accepted).length;
  int get _declinedCount =>
      _invitations.where((i) => i.status == InvitationStatus.declined).length;

  List<TripInvitation> get _filteredInvitations {
    final list = _invitations.where((inv) {
      // 1. Tab filter
      final matchesTab = switch (_selectedTab) {
        InboxFilterTab.all => true,
        InboxFilterTab.pending => inv.status == InvitationStatus.pending,
        InboxFilterTab.accepted => inv.status == InvitationStatus.accepted,
        InboxFilterTab.declined => inv.status == InvitationStatus.declined,
      };

      if (!matchesTab) return false;

      // 2. Search query filter
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return inv.title.toLowerCase().contains(q) ||
          inv.destination.toLowerCase().contains(q) ||
          inv.invitedBy.toLowerCase().contains(q);
    }).toList();

    if (_activeSort == 'oldest') {
      list.sort((a, b) => a.id.compareTo(b.id));
    } else if (_activeSort == 'destination') {
      list.sort((a, b) => a.destination.compareTo(b.destination));
    } else if (_activeSort == 'title') {
      list.sort((a, b) => a.title.compareTo(b.title));
    }
    return list;
  }

  void _acceptInvitation(TripInvitation invitation) {
    setState(() {
      final index = _invitations.indexWhere((i) => i.id == invitation.id);
      if (index != -1) {
        _invitations[index] =
            invitation.copyWith(status: InvitationStatus.accepted);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Joined "${invitation.title}"! Added to your Trips.',
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

  void _declineInvitation(TripInvitation invitation) {
    final originalStatus = invitation.status;

    setState(() {
      final index = _invitations.indexWhere((i) => i.id == invitation.id);
      if (index != -1) {
        _invitations[index] =
            invitation.copyWith(status: InvitationStatus.declined);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Declined invitation to "${invitation.title}".',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFFF59E0B),
          onPressed: () {
            setState(() {
              final index =
                  _invitations.indexWhere((i) => i.id == invitation.id);
              if (index != -1) {
                _invitations[index] =
                    invitation.copyWith(status: originalStatus);
              }
            });
          },
        ),
      ),
    );
  }

  void _openInvitationDetails(TripInvitation invitation) {
    context.push(RouteNames.invitationDetails, extra: invitation).then((_) {
      // Re-render when returning to reflect any accepted/declined updates
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredInvitations;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Column(
        children: [
          // ── Header with curved teal background and search ─────────────
          InboxHeader(
            pendingCount: _pendingCount,
            searchController: _searchController,
            onSearchChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            hasActiveFilter:
                _selectedTab != InboxFilterTab.all || _activeSort != 'newest',
            onFilterTap: () => _showFilterSheet(context),
            onScanTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Trip QR / Invite Code Scanner opening soon!',
                    style: GoogleFonts.inter(),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // ── Filter Chips Row ───────────────────────────────────────────
          InboxFilterChips(
            selectedTab: _selectedTab,
            onTabChanged: (tab) {
              setState(() {
                _selectedTab = tab;
              });
            },
            allCount: _invitations.length,
            pendingCount: _pendingCount,
            acceptedCount: _acceptedCount,
            declinedCount: _declinedCount,
          ),

          // ── Invitations List ───────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF004E64),
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 600));
                setState(() {});
              },
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 4,
                        bottom: 24,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final invitation = filtered[index];
                        return InvitationCard(
                          invitation: invitation,
                          onTap: () => _openInvitationDetails(invitation),
                          onAccept: () => _acceptInvitation(invitation),
                          onDecline: () => _declineInvitation(invitation),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF004E64).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                size: 34,
                color: Color(0xFF004E64),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No invitations found',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No invitations match "$_searchQuery". Try another keyword.'
                  : 'You have no invitations under this filter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                              color: isSelected ? const Color(0xFF004E64) : Colors.transparent,
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
                              color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
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
