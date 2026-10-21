import 'trip_member.dart';

/// Model representing draft trip parameters passed across the trip creation wizard.
/// Fully matches backend fields:
/// - `name`: destination
/// - `tripStartDate`: startDate
/// - `tripEndDate`: endDate
/// - `coverImageUrl`: coverImageUrl
/// - Invites: friends (`friendId`), email (`email`), whatsapp (`phone`)
class TripReviewDraft {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String budget;
  final String tripStyle;
  final String? coverImageUrl;
  final List<TripMember> selectedMembers;
  final List<String> invitedEmails;
  final List<String> invitedPhones;
  final String? createdTripId;

  const TripReviewDraft({
    this.destination = '',
    required this.startDate,
    required this.endDate,
    this.budget = '₹20K – ₹50K',
    this.tripStyle = 'Vacation',
    this.coverImageUrl,
    this.selectedMembers = const [],
    this.invitedEmails = const [],
    this.invitedPhones = const [],
    this.createdTripId,
  });

  /// Total number of nights
  int get nights {
    final diff = endDate.difference(startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  /// Total number of days
  int get days => nights + 1;

  /// Formatted date range: e.g. "Oct 12–15 · 3 nights"
  String get formattedDates {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final startMonth = months[startDate.month - 1];
    final endMonth = months[endDate.month - 1];

    if (startDate.month == endDate.month) {
      return '$startMonth ${startDate.day}–${endDate.day} · $nights nights';
    } else {
      return '$startMonth ${startDate.day} – $endMonth ${endDate.day} · $nights nights';
    }
  }

  /// Formatted duration: e.g. "4 days"
  String get formattedDuration => '$days days';

  TripReviewDraft copyWith({
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? budget,
    String? tripStyle,
    String? coverImageUrl,
    List<TripMember>? selectedMembers,
    List<String>? invitedEmails,
    List<String>? invitedPhones,
    String? createdTripId,
  }) {
    return TripReviewDraft(
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      tripStyle: tripStyle ?? this.tripStyle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      invitedEmails: invitedEmails ?? this.invitedEmails,
      invitedPhones: invitedPhones ?? this.invitedPhones,
      createdTripId: createdTripId ?? this.createdTripId,
    );
  }

  /// Dynamic default based on upcoming dates
  factory TripReviewDraft.initial() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
    final end = start.add(const Duration(days: 3));
    return TripReviewDraft(
      destination: '',
      startDate: start,
      endDate: end,
      budget: '₹20K – ₹50K',
      tripStyle: 'Vacation',
      selectedMembers: const [],
      invitedEmails: const [],
      invitedPhones: const [],
    );
  }

  /// Standard default mock matching the wireframe specification
  factory TripReviewDraft.mockDefault() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
    final end = start.add(const Duration(days: 3));
    return TripReviewDraft(
      destination: 'Goa, India',
      startDate: start,
      endDate: end,
      budget: '₹20K – ₹50K',
      tripStyle: 'Beach + Food',
      selectedMembers: TripMember.initialSuggestedFriends.where((f) => f.isSelected).toList(),
      invitedEmails: const [],
      invitedPhones: const [],
    );
  }
}
