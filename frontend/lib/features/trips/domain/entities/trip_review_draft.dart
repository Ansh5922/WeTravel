import 'trip_member.dart';

/// Model representing draft trip parameters passed from Create Trip to Review Trip.
class TripReviewDraft {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String budget;
  final String tripStyle;
  final List<TripMember> selectedMembers;

  const TripReviewDraft({
    this.destination = 'Goa, India',
    required this.startDate,
    required this.endDate,
    this.budget = '₹20k–₹30k',
    this.tripStyle = 'Beach + Food',
    this.selectedMembers = const [],
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
    List<TripMember>? selectedMembers,
  }) {
    return TripReviewDraft(
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      tripStyle: tripStyle ?? this.tripStyle,
      selectedMembers: selectedMembers ?? this.selectedMembers,
    );
  }

  /// Standard default mock matching the wireframe specification
  factory TripReviewDraft.mockDefault() {
    return TripReviewDraft(
      destination: 'Goa, India',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 15),
      budget: '₹20k–₹30k',
      tripStyle: 'Beach + Food',
      selectedMembers: TripMember.initialSuggestedFriends.where((f) => f.isSelected).toList(),
    );
  }
}

